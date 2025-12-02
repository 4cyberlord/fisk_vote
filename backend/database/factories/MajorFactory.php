<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Major>
 */
class MajorFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $majors = [
            'Computer Science',
            'Business Management',
            'Biology',
            'Chemistry',
            'Mathematics',
            'English Literature',
            'History',
            'Political Science',
            'Psychology',
            'Sociology',
            'Physics',
            'Economics',
            'Elementary Education',
            'Mechanical Engineering',
            'Fine Arts',
            'Accounting',
            'Marketing',
            'Nursing',
            'Criminal Justice',
            'Communications',
        ];

        return [
            'name' => fake()->unique()->randomElement($majors),
        ];
    }
}
