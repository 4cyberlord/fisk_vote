<?php

namespace App\Observers;

use App\Models\Election;
use App\Services\NotificationService;
use Carbon\Carbon;

class ElectionObserver
{
    /**
     * Handle the Election "created" event.
     */
    public function created(Election $election): void
    {
        // If election is active, notify eligible users
        if ($election->status === 'active') {
            $nowTimestamp = time();
            $startTimestamp = $election->start_timestamp;

            if (!$startTimestamp) return;

            // If election is already started, send "opened" notification immediately
            if ($startTimestamp <= $nowTimestamp) {
                NotificationService::notifyElectionOpened($election);
            }
            // If election is starting within 48 hours, send "upcoming" notification
            elseif ($startTimestamp > $nowTimestamp && $startTimestamp <= ($nowTimestamp + 172800)) {
                $hoursUntil = (int) ceil(($startTimestamp - $nowTimestamp) / 3600);
                NotificationService::notifyElectionUpcoming($election, $hoursUntil);
            }
        }
    }

    /**
     * Handle the Election "updated" event.
     */
    public function updated(Election $election): void
    {
        $nowTimestamp = time();
        $startTimestamp = $election->start_timestamp;

        if (!$startTimestamp) return;

        // Check if election status changed to active
        if ($election->wasChanged('status') && $election->status === 'active') {
            // If election already started, send "opened" notification
            if ($startTimestamp <= $nowTimestamp) {
                NotificationService::notifyElectionOpened($election);
            }
            // If election is starting soon (within 48 hours), send "upcoming" notification
            elseif ($startTimestamp > $nowTimestamp && $startTimestamp <= ($nowTimestamp + 172800)) {
                $hoursUntil = (int) ceil(($startTimestamp - $nowTimestamp) / 3600);
                NotificationService::notifyElectionUpcoming($election, $hoursUntil);
            }
        }

        // Check if start_time changed and election is now active
        if ($election->wasChanged('start_time') && $election->status === 'active') {
            // If election just started (within last hour)
            if ($startTimestamp <= $nowTimestamp && $startTimestamp >= ($nowTimestamp - 3600)) {
                NotificationService::notifyElectionOpened($election);
            }
            // If election is starting soon (within 48 hours)
            elseif ($startTimestamp > $nowTimestamp && $startTimestamp <= ($nowTimestamp + 172800)) {
                $hoursUntil = (int) ceil(($startTimestamp - $nowTimestamp) / 3600);
                NotificationService::notifyElectionUpcoming($election, $hoursUntil);
            }
        }

        // Check if status changed to closed and notify about results
        if ($election->wasChanged('status') && $election->status === 'closed') {
            NotificationService::notifyResultsAvailable($election);
        }
    }

    /**
     * Handle the Election "deleted" event.
     */
    public function deleted(Election $election): void
    {
        // Optionally delete related notifications
        \App\Models\Notification::where('metadata->election_id', $election->id)->delete();
    }
}
