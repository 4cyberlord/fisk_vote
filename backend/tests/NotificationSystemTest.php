<?php

namespace Tests;

use App\Models\Election;
use App\Models\Notification;
use App\Models\User;
use App\Models\Vote;
use App\Services\NotificationService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class NotificationSystemTest extends TestCase
{
    use RefreshDatabase;

    public function test_notification_created_when_election_opens(): void
    {
        // Create a student user
        $student = User::factory()->create();
        $student->assignRole('student');

        // Create an election that just opened
        $election = Election::factory()->create([
            'status' => 'active',
            'start_time' => now()->subMinutes(30), // Started 30 minutes ago
            'end_time' => now()->addDays(5),
        ]);

        // Manually trigger notification (simulating observer)
        NotificationService::notifyElectionOpened($election);

        // Assert notification was created
        $notification = Notification::where('user_id', $student->id)
            ->where('type', 'new_election')
            ->first();

        $this->assertNotNull($notification);
        $this->assertEquals('New Election Available', $notification->title);
        $this->assertTrue($notification->urgent);
        $this->assertFalse($notification->is_read);
    }

    public function test_notification_created_when_vote_is_cast(): void
    {
        // Create a student user
        $student = User::factory()->create();
        $student->assignRole('student');

        // Create an election
        $election = Election::factory()->create([
            'status' => 'active',
            'start_time' => now()->subDay(),
            'end_time' => now()->addDays(5),
        ]);

        // Create a vote
        $vote = Vote::factory()->create([
            'election_id' => $election->id,
            'voter_id' => $student->id,
        ]);

        // Manually trigger notification (simulating observer)
        NotificationService::notifyVoteConfirmed($student, $election);

        // Assert notification was created
        $notification = Notification::where('user_id', $student->id)
            ->where('type', 'vote_confirmed')
            ->first();

        $this->assertNotNull($notification);
        $this->assertEquals('Vote Confirmed', $notification->title);
        $this->assertFalse($notification->urgent);
    }

    public function test_notification_marked_as_read(): void
    {
        // Create a student user
        $student = User::factory()->create();
        $student->assignRole('student');

        // Create a notification
        $notification = Notification::factory()->create([
            'user_id' => $student->id,
            'is_read' => false,
        ]);

        // Mark as read
        $notification->markAsRead();

        // Assert it's marked as read
        $this->assertTrue($notification->fresh()->is_read);
        $this->assertNotNull($notification->fresh()->read_at);
    }
}
