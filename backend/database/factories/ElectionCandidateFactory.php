<?php

namespace Database\Factories;

use App\Models\Election;
use App\Models\ElectionPosition;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\ElectionCandidate>
 */
class ElectionCandidateFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $taglines = [
            'Building a Better Tomorrow',
            'Your Voice, Your Choice',
            'Together We Can Make a Difference',
            'Leadership with Integrity',
            'Empowering Students',
            'Transparency and Accountability',
            'Innovation and Progress',
            'Unity in Diversity',
            'Excellence in Action',
            'Student First',
        ];

        $bios = [
            'Dedicated student leader with a passion for serving the community.',
            'Experienced in student governance and committed to positive change.',
            'Advocate for student rights and academic excellence.',
            'Proven track record of leadership and community engagement.',
            'Committed to transparency, accountability, and student welfare.',
        ];

        return [
            'election_id' => Election::factory(),
            'position_id' => ElectionPosition::factory(),
            'user_id' => User::factory(),
            'photo_url' => 'https://i.pravatar.cc/400?img=' . fake()->numberBetween(1, 70), // Random avatar
            'tagline' => fake()->randomElement($taglines),
            'bio' => fake()->randomElement($bios),
            'manifesto' => fake()->paragraphs(5, true),
            'approved' => fake()->boolean(90), // 90% approved
        ];
    }
}
