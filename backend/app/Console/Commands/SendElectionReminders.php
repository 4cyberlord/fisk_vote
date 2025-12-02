<?php

namespace App\Console\Commands;

use App\Models\Election;
use App\Models\User;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Log;

class SendElectionReminders extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'elections:send-reminders {--hours=24 : Hours before election start to send reminder}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Send email reminders to eligible students for upcoming elections';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $hours = (int) $this->option('hours');
        $reminderTime = now()->addHours($hours);

        $this->info("Looking for elections starting within {$hours} hours...");

        // Find elections starting within the specified hours
        $elections = Election::where('start_time', '>=', now())
            ->where('start_time', '<=', $reminderTime)
            ->where('current_status', 'Upcoming')
            ->get();

        if ($elections->isEmpty()) {
            $this->info('No elections found that need reminders.');
            return 0;
        }

        $this->info("Found {$elections->count()} election(s) to send reminders for.");

        $totalSent = 0;

        foreach ($elections as $election) {
            $this->info("Processing election: {$election->title}");

            // Get all eligible users
            $eligibleUsers = User::whereHas('roles', function ($query) {
                $query->where('name', 'student');
            })->get()->filter(function ($user) use ($election) {
                return $election->isEligibleForUser($user);
            });

            $this->info("Found {$eligibleUsers->count()} eligible users.");

            foreach ($eligibleUsers as $user) {
                try {
                    // Check if user has already voted (shouldn't happen for upcoming, but check anyway)
                    if ($election->hasUserVoted($user)) {
                        continue;
                    }

                    // Send reminder email
                    Mail::send('emails.election-reminder', [
                        'user' => $user,
                        'election' => $election,
                    ], function ($message) use ($user, $election) {
                        $message->to($user->email, $user->name)
                            ->subject("Reminder: {$election->title} starts soon");
                    });

                    $totalSent++;
                } catch (\Exception $e) {
                    Log::error('Failed to send election reminder', [
                        'user_id' => $user->id,
                        'election_id' => $election->id,
                        'error' => $e->getMessage(),
                    ]);
                }
            }
        }

        $this->info("Sent {$totalSent} reminder email(s).");
        Log::info('Election reminders sent', [
            'elections_count' => $elections->count(),
            'emails_sent' => $totalSent,
        ]);

        return 0;
    }
}

