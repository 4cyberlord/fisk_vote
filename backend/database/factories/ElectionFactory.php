<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use Carbon\Carbon;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Election>
 */
class ElectionFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $types = ['single', 'multiple', 'ranked'];
        $type = fake()->randomElement($types);
        
        $statuses = ['draft', 'active', 'closed', 'archived'];
        $status = fake()->randomElement($statuses);

        // Generate realistic dates based on status
        $now = now();
        $startTime = null;
        $endTime = null;

        if ($status === 'active') {
            // Active election: started in the past, ends in the future
            $startTime = $now->copy()->subDays(fake()->numberBetween(1, 10));
            $endTime = $now->copy()->addDays(fake()->numberBetween(1, 30));
        } elseif ($status === 'closed') {
            // Closed election: ended in the past
            $startTime = $now->copy()->subDays(fake()->numberBetween(31, 90));
            $endTime = $now->copy()->subDays(fake()->numberBetween(1, 30));
        } elseif ($status === 'draft') {
            // Draft: future dates
            $startTime = $now->copy()->addDays(fake()->numberBetween(1, 30));
            $endTime = $startTime->copy()->addDays(fake()->numberBetween(7, 14));
        } else {
            // Archived: old dates
            $startTime = $now->copy()->subDays(fake()->numberBetween(91, 180));
            $endTime = $startTime->copy()->addDays(fake()->numberBetween(7, 14));
        }

        $titles = [
            'Student Government Association Election',
            'Class Representative Election',
            'Student Council Election',
            'Honor Society Leadership Election',
            'Club President Election',
            'Graduate Student Council Election',
            'Residence Hall Council Election',
            'Academic Senate Election',
        ];

        return [
            'title' => fake()->randomElement($titles) . ' ' . fake()->year(),
            'description' => fake()->paragraphs(3, true),
            'type' => $type,
            'max_selection' => $type === 'multiple' ? fake()->numberBetween(2, 5) : null,
            'ranking_levels' => $type === 'ranked' ? fake()->numberBetween(3, 5) : null,
            'allow_write_in' => fake()->boolean(30),
            'allow_abstain' => fake()->boolean(40),
            'is_universal' => fake()->boolean(60),
            'eligible_groups' => function () {
                if (fake()->boolean(40)) {
                    return [
                        'departments' => fake()->randomElements([
                            'Computer Science',
                            'Business Administration',
                            'Biology',
                            'Chemistry',
                        ], fake()->numberBetween(1, 3)),
                        'class_levels' => fake()->randomElements([
                            'Freshman',
                            'Sophomore',
                            'Junior',
                            'Senior',
                        ], fake()->numberBetween(1, 3)),
                    ];
                }
                return null;
            },
            'start_time' => $startTime,
            'end_time' => $endTime,
            'status' => $status,
        ];
    }
}
