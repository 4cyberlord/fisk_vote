<?php

namespace App\Services;

use App\Models\Notification;
use App\Models\User;
use App\Models\Election;

class NotificationService
{
    /**
     * Create a notification for a user.
     */
    public static function create(
        User $user,
        string $type,
        string $title,
        string $message,
        ?string $href = null,
        bool $urgent = false,
        ?array $metadata = null
    ): Notification {
        // Map types to icons and colors
        $iconMap = [
            'new_election' => 'bell',
            'upcoming' => 'clock',
            'closing_soon' => 'alert-circle',
            'vote_confirmed' => 'check-circle',
            'results_available' => 'award',
        ];

        $colorMap = [
            'new_election' => 'text-blue-600',
            'upcoming' => 'text-amber-600',
            'closing_soon' => 'text-red-600',
            'vote_confirmed' => 'text-green-600',
            'results_available' => 'text-purple-600',
        ];

        return Notification::create([
            'user_id' => $user->id,
            'type' => $type,
            'title' => $title,
            'message' => $message,
            'icon' => $iconMap[$type] ?? 'bell',
            'color' => $colorMap[$type] ?? 'text-gray-600',
            'href' => $href,
            'urgent' => $urgent,
            'metadata' => $metadata,
        ]);
    }

    /**
     * Notify eligible users about a new election opening.
     */
    public static function notifyElectionOpened(Election $election): void
    {
        $eligibleUsers = User::whereHas('roles', function ($query) {
            $query->whereIn('name', ['Student', 'student']); // Handle both cases
        })->get()->filter(function ($user) use ($election) {
            return $election->isEligibleForUser($user) && !$election->hasUserVoted($user);
        });

        foreach ($eligibleUsers as $user) {
            self::create(
                $user,
                'new_election',
                'New Election Available',
                "{$election->title} is now open for voting",
                "/dashboard/elections/{$election->id}",
                true,
                ['election_id' => $election->id]
            );
        }
    }

    /**
     * Notify eligible users about an upcoming election.
     */
    public static function notifyElectionUpcoming(Election $election, int $hoursUntil): void
    {
        $eligibleUsers = User::whereHas('roles', function ($query) {
            $query->whereIn('name', ['Student', 'student']); // Handle both cases
        })->get()->filter(function ($user) use ($election) {
            return $election->isEligibleForUser($user) && !$election->hasUserVoted($user);
        });

        foreach ($eligibleUsers as $user) {
            self::create(
                $user,
                'upcoming',
                'Election Starting Soon',
                "{$election->title} starts in {$hoursUntil} hour" . ($hoursUntil !== 1 ? 's' : ''),
                "/dashboard/elections/{$election->id}",
                $hoursUntil <= 24,
                ['election_id' => $election->id, 'hours_until' => $hoursUntil]
            );
        }
    }

    /**
     * Notify eligible users about an election closing soon.
     */
    public static function notifyElectionClosingSoon(Election $election, int $hoursLeft): void
    {
        $eligibleUsers = User::whereHas('roles', function ($query) {
            $query->whereIn('name', ['Student', 'student']); // Handle both cases
        })->get()->filter(function ($user) use ($election) {
            return $election->isEligibleForUser($user) && !$election->hasUserVoted($user);
        });

        foreach ($eligibleUsers as $user) {
            self::create(
                $user,
                'closing_soon',
                'Election Closing Soon',
                "{$election->title} closes in {$hoursLeft} hour" . ($hoursLeft !== 1 ? 's' : '') . " - Don't forget to vote!",
                "/dashboard/vote/{$election->id}",
                true,
                ['election_id' => $election->id, 'hours_left' => $hoursLeft]
            );
        }
    }

    /**
     * Notify user about vote confirmation.
     */
    public static function notifyVoteConfirmed(User $user, Election $election): void
    {
        self::create(
            $user,
            'vote_confirmed',
            'Vote Confirmed',
            "Your vote in {$election->title} has been recorded",
            "/dashboard/vote/history",
            false,
            ['election_id' => $election->id, 'vote_id' => null] // Will be updated by VoteObserver
        );
    }

    /**
     * Notify users about election results being available.
     */
    public static function notifyResultsAvailable(Election $election): void
    {
        $voters = User::whereHas('votes', function ($query) use ($election) {
            $query->where('election_id', $election->id);
        })->get();

        foreach ($voters as $user) {
            self::create(
                $user,
                'results_available',
                'Election Results Available',
                "Results for {$election->title} are now available",
                "/dashboard/results/{$election->id}",
                false,
                ['election_id' => $election->id]
            );
        }
    }
}
