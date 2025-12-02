<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ElectionPosition extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'election_id',
        'name',
        'description',
        'type',
        'max_selection',
        'ranking_levels',
        'allow_abstain',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected function casts(): array
    {
        return [
            'allow_abstain' => 'boolean',
        ];
    }

    /**
     * Get the election that owns this position.
     */
    public function election(): BelongsTo
    {
        return $this->belongsTo(Election::class);
    }

    /**
     * Get the candidates for this position.
     */
    public function candidates(): HasMany
    {
        return $this->hasMany(ElectionCandidate::class, 'position_id');
    }
}
