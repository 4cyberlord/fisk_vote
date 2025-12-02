<?php

namespace Database\Factories;

use App\Models\Election;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\ElectionPosition>
 */
class ElectionPositionFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $positions = [
            'President',
            'Vice President',
            'Secretary',
            'Treasurer',
            'Public Relations Officer',
            'Event Coordinator',
            'Academic Representative',
            'Social Media Manager',
            'Student Representative',
            'Class President',
        ];

        $type = fake()->randomElement(['single', 'multiple', 'ranked']);

        return [
            'election_id' => Election::factory(),
            'name' => fake()->randomElement($positions),
            'description' => fake()->sentence(),
            'type' => $type,
            'max_selection' => $type === 'multiple' ? fake()->numberBetween(2, 3) : null,
            'ranking_levels' => $type === 'ranked' ? fake()->numberBetween(3, 5) : null,
            'allow_abstain' => fake()->boolean(50),
        ];
    }
}
