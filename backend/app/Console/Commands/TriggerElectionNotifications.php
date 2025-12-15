<?php

namespace App\Console\Commands;

use App\Models\Election;
use App\Services\NotificationService;
use Illuminate\Console\Command;
use Carbon\Carbon;

class TriggerElectionNotifications extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'notifications:trigger-election {election_id? : The ID of the election to trigger notifications for}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Manually trigger notifications for an active election';

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        $tz = config('app.timezone', 'America/Chicago');
        $electionId = $this->argument('election_id');

        if ($electionId) {
            $election = Election::find($electionId);
            if (!$election) {
                $this->error("Election with ID {$electionId} not found.");
                return 1;
            }
            $elections = collect([$election]);
        } else {
            // Get all active elections
            $elections = Election::where('status', 'active')->get();
        }

        if ($elections->isEmpty()) {
            $this->info('No active elections found.');
            return 0;
        }

        $nowTimestamp = time();
        $this->info("Processing {$elections->count()} election(s)... (Server time: " . Carbon::now($tz)->format('Y-m-d H:i:s T') . ")");

        foreach ($elections as $election) {
            $startTimestamp = $election->start_timestamp;
            $startTime = $startTimestamp ? Carbon::createFromTimestamp($startTimestamp, $tz) : null;

            $this->info("\nProcessing: {$election->title} (ID: {$election->id})");
            $this->info("  Status: {$election->status}");
            $this->info("  Start Time: " . ($startTime ? $startTime->format('Y-m-d H:i:s T') : 'N/A'));
            $this->info("  Current Status: {$election->current_status}");

            if ($election->status !== 'active') {
                $this->warn("  Skipping: Election is not active");
                continue;
            }

            if (!$startTimestamp) {
                $this->warn("  Skipping: No start time set");
                continue;
            }

            // Check if notifications already exist
            $existingNotifications = \App\Models\Notification::where('type', 'new_election')
                ->where('metadata->election_id', $election->id)
                ->count();

            if ($existingNotifications > 0) {
                $this->warn("  Notifications already exist ({$existingNotifications}). Use --force to recreate.");
                continue;
            }

            // If election already started, send "opened" notification
            if ($startTimestamp <= $nowTimestamp) {
                $this->info("  Election is OPEN - creating 'opened' notifications...");
                NotificationService::notifyElectionOpened($election);

                $created = \App\Models\Notification::where('type', 'new_election')
                    ->where('metadata->election_id', $election->id)
                    ->count();
                $this->info("  ✅ Created {$created} notification(s)");
            }
            // If election is starting soon (within 48 hours), send "upcoming" notification
            elseif ($startTimestamp > $nowTimestamp && $startTimestamp <= ($nowTimestamp + 172800)) {
                $hoursUntil = (int) ceil(($startTimestamp - $nowTimestamp) / 3600);
                $this->info("  Election starts in {$hoursUntil} hours - creating 'upcoming' notifications...");
                NotificationService::notifyElectionUpcoming($election, $hoursUntil);

                $created = \App\Models\Notification::where('type', 'upcoming')
                    ->where('metadata->election_id', $election->id)
                    ->count();
                $this->info("  ✅ Created {$created} notification(s)");
            } else {
                $this->warn("  Skipping: Election starts more than 48 hours from now");
            }
        }

        $this->info("\n✅ Done!");
        return 0;
    }
}
