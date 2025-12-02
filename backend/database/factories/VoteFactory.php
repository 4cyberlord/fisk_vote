<?php

namespace Database\Factories;

use App\Models\Election;
use App\Models\ElectionPosition;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Vote>
 */
class VoteFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $election = Election::factory()->create();
        $position = ElectionPosition::factory()->create(['election_id' => $election->id]);
        $voter = User::factory()->create();

        // Generate vote data based on position type
        $voteData = match($position->type) {
            'single' => ['candidate_id' => fake()->numberBetween(1, 10)],
            'multiple' => ['candidate_ids' => fake()->randomElements([1, 2, 3, 4, 5], fake()->numberBetween(1, 3))],
            'ranked' => ['rankings' => [
                ['candidate_id' => 1, 'rank' => 1],
                ['candidate_id' => 2, 'rank' => 2],
                ['candidate_id' => 3, 'rank' => 3],
            ]],
            default => ['candidate_id' => fake()->numberBetween(1, 10)],
        };

        return [
            'election_id' => $election->id,
            'position_id' => $position->id,
            'voter_id' => $voter->id,
            'vote_data' => $voteData,
            'token' => Str::random(32),
            'voted_at' => fake()->dateTimeBetween('-30 days', 'now'),
        ];
    }
}
