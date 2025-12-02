<?php

namespace Database\Factories;

use App\Models\Department;
use App\Models\Major;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\User>
 */
class UserFactory extends Factory
{
    /**
     * The current password being used by the factory.
     */
    protected static ?string $password;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $firstName = fake()->firstName();
        $lastName = fake()->lastName();
        $middleInitial = fake()->optional(0.3)->randomLetter();
        $name = $middleInitial
            ? "{$firstName} {$middleInitial}. {$lastName}"
            : "{$firstName} {$lastName}";

        $studentId = 'FISK' . fake()->unique()->numerify('####');
        $universityEmail = strtolower($firstName . '.' . $lastName . '@my.fisk.edu');

        // Ensure unique email
        $counter = 1;
        while (\App\Models\User::where('university_email', $universityEmail)->exists()) {
            $universityEmail = strtolower($firstName . '.' . $lastName . $counter . '@my.fisk.edu');
            $counter++;
        }

        return [
            'name' => $name,
            'first_name' => $firstName,
            'last_name' => $lastName,
            'middle_initial' => $middleInitial,
            'student_id' => $studentId,
            'email' => $universityEmail,
            'university_email' => $universityEmail,
            'personal_email' => fake()->unique()->safeEmail(),
            'phone_number' => fake()->phoneNumber(),
            'address' => fake()->address(),
            'department' => fake()->randomElement([
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
            ]),
            'major' => fake()->randomElement([
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
            ]),
            'class_level' => fake()->randomElement(['Freshman', 'Sophomore', 'Junior', 'Senior']),
            'enrollment_status' => fake()->randomElement(['Active', 'Suspended', 'Graduated']),
            'student_type' => fake()->randomElement(['Undergraduate', 'Graduate', 'Transfer', 'International']),
            'citizenship_status' => fake()->randomElement(['US Citizen', 'International', 'Permanent Resident']),
            'email_verified_at' => now(),
            'password' => static::$password ??= Hash::make('password'),
            'remember_token' => Str::random(10),
        ];
    }

    /**
     * Indicate that the model's email address should be unverified.
     */
    public function unverified(): static
    {
        return $this->state(fn (array $attributes) => [
            'email_verified_at' => null,
        ]);
    }
}
