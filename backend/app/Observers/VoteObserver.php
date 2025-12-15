<?php

namespace App\Observers;

use App\Models\Vote;
use App\Services\NotificationService;

class VoteObserver
{
    /**
     * Handle the Vote "created" event.
     */
    public function created(Vote $vote): void
    {
        // Load relationships if not already loaded
        if (!$vote->relationLoaded('voter')) {
            $vote->load('voter');
        }
        if (!$vote->relationLoaded('election')) {
            $vote->load('election');
        }

        // Get the voter and election
        $voter = $vote->voter;
        $election = $vote->election;

        if ($voter && $election) {
            // Create vote confirmation notification
            NotificationService::notifyVoteConfirmed($voter, $election);
            
            // Update the notification with vote_id
            $notification = \App\Models\Notification::where('user_id', $voter->id)
                ->where('type', 'vote_confirmed')
                ->where('metadata->election_id', $election->id)
                ->latest()
                ->first();
            
            if ($notification) {
                $metadata = $notification->metadata ?? [];
                $metadata['vote_id'] = $vote->id;
                $notification->update(['metadata' => $metadata]);
            }
        }
    }
}
