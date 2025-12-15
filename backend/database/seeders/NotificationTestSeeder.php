<?php

namespace Database\Seeders;

use App\Models\Election;
use App\Models\Notification;
use App\Models\User;
use App\Services\NotificationService;
use Illuminate\Database\Seeder;
use Carbon\Carbon;

class NotificationTestSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $this->command->info('Creating test notifications...');

        // Get a student user
        $student = User::whereHas('roles', function ($query) {
            $query->where('name', 'student');
        })->first();

        if (!$student) {
            $this->command->error('No student user found. Please create a student user first.');
            return;
        }

        $this->command->info("Creating notifications for user: {$student->name} (ID: {$student->id})");

        // Create test notifications
        $notifications = [
            [
                'type' => 'new_election',
                'title' => 'New Election Available',
                'message' => '2025 Student Government Elections is now open for voting',
                'icon' => 'bell',
                'color' => 'text-blue-600',
                'href' => '/dashboard/elections/1',
                'urgent' => true,
            ],
            [
                'type' => 'upcoming',
                'title' => 'Election Starting Soon',
                'message' => 'Spring 2025 Elections starts in 24 hours',
                'icon' => 'clock',
                'color' => 'text-amber-600',
                'href' => '/dashboard/elections/2',
                'urgent' => true,
            ],
            [
                'type' => 'closing_soon',
                'title' => 'Election Closing Soon',
                'message' => '2025 Student Government Elections closes in 6 hours - Don\'t forget to vote!',
                'icon' => 'alert-circle',
                'color' => 'text-red-600',
                'href' => '/dashboard/vote/1',
                'urgent' => true,
            ],
            [
                'type' => 'vote_confirmed',
                'title' => 'Vote Confirmed',
                'message' => 'Your vote in 2025 Student Government Elections has been recorded',
                'icon' => 'check-circle',
                'color' => 'text-green-600',
                'href' => '/dashboard/vote/history',
                'urgent' => false,
            ],
        ];

        foreach ($notifications as $index => $notifData) {
            Notification::create([
                'user_id' => $student->id,
                'type' => $notifData['type'],
                'title' => $notifData['title'],
                'message' => $notifData['message'],
                'icon' => $notifData['icon'],
                'color' => $notifData['color'],
                'href' => $notifData['href'],
                'urgent' => $notifData['urgent'],
                'is_read' => $index >= 2, // First 2 are unread, last 2 are read
                'read_at' => $index >= 2 ? now() : null,
                'metadata' => ['test' => true, 'election_id' => $index + 1],
                'created_at' => now()->subHours(3 - $index), // Stagger creation times
            ]);
        }

        $this->command->info('✅ Created 4 test notifications (2 unread, 2 read)');
        $this->command->info('   - 1 urgent unread (New Election)');
        $this->command->info('   - 1 urgent unread (Closing Soon)');
        $this->command->info('   - 1 read (Upcoming)');
        $this->command->info('   - 1 read (Vote Confirmed)');
    }
}
