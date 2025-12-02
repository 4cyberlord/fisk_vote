<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Department>
 */
class DepartmentFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $departments = [
            'Computer Science',
            'Business Administration',
            'Biology',
            'Chemistry',
            'Mathematics',
            'English',
            'History',
            'Political Science',
            'Psychology',
            'Sociology',
            'Physics',
            'Economics',
            'Education',
            'Engineering',
            'Fine Arts',
        ];

        return [
            'name' => fake()->unique()->randomElement($departments),
        ];
    }
}
