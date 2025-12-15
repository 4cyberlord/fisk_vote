<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Election extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'title',
        'description',
        'type',
        'max_selection',
        'ranking_levels',
        'allow_write_in',
        'allow_abstain',
        'is_universal',
        'eligible_groups',
        'start_time',
        'end_time',
        'status',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected function casts(): array
    {
        return [
            'allow_write_in' => 'boolean',
            'allow_abstain' => 'boolean',
            'is_universal' => 'boolean',
            'eligible_groups' => 'array',
            'start_time' => 'datetime',
            'end_time' => 'datetime',
        ];
    }

    /**
     * Get the positions for this election.
     */
    public function positions(): HasMany
    {
        return $this->hasMany(ElectionPosition::class);
    }

    /**
     * Get the candidates for this election.
     */
    public function candidates(): HasMany
    {
        return $this->hasMany(ElectionCandidate::class);
    }

    /**
     * Get the votes for this election.
     */
    public function votes(): HasMany
    {
        return $this->hasMany(Vote::class);
    }

    /**
     * Check if a user is eligible to vote in this election.
     */
    public function isEligibleForUser(?User $user): bool
    {
        if (!$user) {
            return false;
        }

        // If universal, all students are eligible
        if ($this->is_universal) {
            return true;
        }

        // Check eligible groups
        $eligibleGroups = $this->eligible_groups ?? [];

        // Check departments
        if (!empty($eligibleGroups['departments']) && is_array($eligibleGroups['departments'])) {
            if (in_array($user->department, $eligibleGroups['departments'])) {
                return true;
            }
        }

        // Check class levels
        if (!empty($eligibleGroups['class_levels']) && is_array($eligibleGroups['class_levels'])) {
            if (in_array($user->class_level, $eligibleGroups['class_levels'])) {
                return true;
            }
        }

        // Check organizations
        if (!empty($eligibleGroups['organizations']) && is_array($eligibleGroups['organizations'])) {
            $userOrganizationIds = $user->organizations->pluck('id')->toArray();
            if (array_intersect($userOrganizationIds, $eligibleGroups['organizations'])) {
                return true;
            }
        }

        // Check manual list (user IDs)
        if (!empty($eligibleGroups['manual']) && is_array($eligibleGroups['manual'])) {
            if (in_array($user->id, $eligibleGroups['manual'])) {
                return true;
            }
        }

        return false;
    }

    /**
     * Check if a user has voted in this election.
     */
    public function hasUserVoted(?User $user): bool
    {
        if (!$user) {
            return false;
        }

        return $this->votes()
            ->where('voter_id', $user->id)
            ->exists();
    }

    /**
     * Get the current status of the election (Open, Upcoming, Closed).
     * Uses Unix timestamps for timezone-agnostic comparison.
     */
    public function getCurrentStatusAttribute(): string
    {
        if ($this->status === 'closed' || $this->status === 'archived') {
            return 'Closed';
        }

        // Use Unix timestamps for comparison - completely timezone-agnostic
        $nowTimestamp = time();
        $startTimestamp = $this->start_time ? $this->start_time->timestamp : null;
        $endTimestamp = $this->end_time ? $this->end_time->timestamp : null;

        // Check if election hasn't started yet
        if ($startTimestamp && $startTimestamp > $nowTimestamp) {
            return 'Upcoming';
        }

        // Check if election has ended
        if ($endTimestamp && $endTimestamp < $nowTimestamp) {
            return 'Closed';
        }

        // Check if election is currently open
        if ($this->status === 'active' && $startTimestamp && $endTimestamp &&
            $startTimestamp <= $nowTimestamp && $endTimestamp >= $nowTimestamp) {
            return 'Open';
        }

        return 'Closed';
    }

    /**
     * Get start time as Unix timestamp
     */
    public function getStartTimestampAttribute(): ?int
    {
        return $this->start_time ? $this->start_time->timestamp : null;
    }

    /**
     * Get end time as Unix timestamp
     */
    public function getEndTimestampAttribute(): ?int
    {
        return $this->end_time ? $this->end_time->timestamp : null;
    }
}
