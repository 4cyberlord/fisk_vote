<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Organization>
 */
class OrganizationFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $organizations = [
            'Student Government Association',
            'Black Student Union',
            'Computer Science Club',
            'Business Club',
            'Debate Team',
            'Choir',
            'Drama Club',
            'Sports Club',
            'Environmental Club',
            'Honor Society',
            'International Students Association',
            'Photography Club',
            'Music Society',
            'Volunteer Club',
            'Pre-Law Society',
        ];

        return [
            'name' => fake()->unique()->randomElement($organizations),
        ];
    }
}
