<?php

namespace App\Console\Commands;

use App\Models\Election;
use App\Services\NotificationService;
use Illuminate\Console\Command;
use Carbon\Carbon;

class CheckElectionNotifications extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'notifications:check-elections';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Check for upcoming and closing elections and create notifications';

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        $tz = config('app.timezone', 'America/Chicago');
        $now = Carbon::now($tz);
        $oneDayFromNow = $now->copy()->addDay();
        $twoDaysFromNow = $now->copy()->addDays(2);

        $this->info("Checking for elections that need notifications... (Server time: {$now->format('Y-m-d H:i:s T')})");

        // Get active elections
        $elections = Election::where('status', 'active')->get();

        $notificationsCreated = 0;

        foreach ($elections as $election) {
            // Parse times in app timezone using timestamps for accuracy
            $startTimestamp = $election->start_timestamp;
            $endTimestamp = $election->end_timestamp;
            $nowTimestamp = $now->timestamp;

            if (!$startTimestamp || !$endTimestamp) continue;

            $startTime = Carbon::createFromTimestamp($startTimestamp, $tz);
            $endTime = Carbon::createFromTimestamp($endTimestamp, $tz);

            // Check if election just opened (within last hour)
            if ($startTimestamp <= $nowTimestamp && $startTimestamp >= ($nowTimestamp - 3600)) {
                $this->info("Election '{$election->title}' just opened - creating notifications");
                NotificationService::notifyElectionOpened($election);
                $notificationsCreated++;
            }

            // Check if election is upcoming (starting within 48 hours but not yet started)
            if ($startTimestamp > $nowTimestamp) {
                $hoursUntil = (int) ceil(($startTimestamp - $nowTimestamp) / 3600);

                // Only notify if it's exactly 24 or 48 hours away (to avoid duplicates)
                if ($hoursUntil === 24 || $hoursUntil === 48) {
                    $this->info("Election '{$election->title}' starting in {$hoursUntil} hours - creating notifications");
                    NotificationService::notifyElectionUpcoming($election, $hoursUntil);
                    $notificationsCreated++;
                }
            }

            // Check if election is closing soon (within 24 hours)
            if ($endTimestamp > $nowTimestamp && $endTimestamp <= ($nowTimestamp + 86400)) {
                $hoursLeft = (int) ceil(($endTimestamp - $nowTimestamp) / 3600);

                // Only notify if it's exactly 24, 12, 6, or 1 hour(s) away (to avoid duplicates)
                if (in_array($hoursLeft, [24, 12, 6, 1])) {
                    $this->info("Election '{$election->title}' closing in {$hoursLeft} hours - creating notifications");
                    NotificationService::notifyElectionClosingSoon($election, $hoursLeft);
                    $notificationsCreated++;
                }
            }
        }

        $this->info("Created notifications for {$notificationsCreated} election(s).");
        return 0;
    }
}
