<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Str;

class Vote extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'election_id',
        'position_id',
        'voter_id',
        'vote_data',
        'token',
        'voted_at',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected function casts(): array
    {
        return [
            'vote_data' => 'array',
            'voted_at' => 'datetime',
        ];
    }

    /**
     * Boot the model.
     */
    protected static function boot(): void
    {
        parent::boot();

        static::creating(function ($vote) {
            // Generate unique signed token if not provided
            if (empty($vote->token)) {
                $vote->token = static::generateSignedToken($vote);
            }

            // Set voted_at timestamp if not provided
            if (empty($vote->voted_at)) {
                $vote->voted_at = now();
            }
        });
    }

    /**
     * Get the election that this vote belongs to.
     */
    public function election(): BelongsTo
    {
        return $this->belongsTo(Election::class);
    }

    /**
     * Get the position that this vote is for.
     */
    public function position(): BelongsTo
    {
        return $this->belongsTo(ElectionPosition::class, 'position_id');
    }

    /**
     * Get the voter (user) who cast this vote.
     */
    public function voter(): BelongsTo
    {
        return $this->belongsTo(User::class, 'voter_id');
    }

    /**
     * Generate a signed, unique token for the vote.
     * This token is cryptographically signed using vote data, timestamp, and app secret.
     *
     * @param Vote $vote
     * @return string
     */
    protected static function generateSignedToken(Vote $vote): string
    {
        // Create a unique payload combining vote data
        $payload = [
            'election_id' => $vote->election_id,
            'position_id' => $vote->position_id,
            'voter_id' => $vote->voter_id,
            'vote_data' => $vote->vote_data,
            'timestamp' => now()->toIso8601String(),
            'random' => Str::random(32),
        ];

        // Create a hash of the payload with app secret
        $signature = hash_hmac('sha256', json_encode($payload), config('app.key'));

        // Combine payload hash with additional random string for uniqueness
        $token = $signature . Str::random(32);

        // Ensure token is exactly 64 characters (32 char hash + 32 char random)
        return substr($token, 0, 64);
    }
}
