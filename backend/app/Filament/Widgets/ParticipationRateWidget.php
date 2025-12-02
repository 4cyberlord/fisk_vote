<?php

namespace App\Filament\Widgets;

use App\Models\Election;
use App\Models\User;
use App\Models\Vote;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class ParticipationRateWidget extends BaseWidget
{
    protected static ?int $sort = 4;

    protected function getStats(): array
    {
        $totalStudents = User::whereHas('roles', function ($query) {
            $query->where('name', 'student');
        })->count();

        // Get active elections
        $activeElections = Election::where('status', 'active')
            ->where('start_time', '<=', now())
            ->where('end_time', '>=', now())
            ->get();

        $stats = [];

        if ($activeElections->count() > 0) {
            foreach ($activeElections->take(3) as $election) {
                $totalEligible = User::whereHas('roles', function ($query) {
                    $query->where('name', 'student');
                })->get()->filter(function ($user) use ($election) {
                    return $election->isEligibleForUser($user);
                })->count();

                $votesCast = Vote::where('election_id', $election->id)->distinct('voter_id')->count('voter_id');
                
                $participationRate = $totalEligible > 0 
                    ? round(($votesCast / $totalEligible) * 100, 1) 
                    : 0;

                $title = strlen($election->title) > 25 ? substr($election->title, 0, 25) . '...' : $election->title;

                $stats[] = Stat::make($title, "{$participationRate}%")
                    ->description("{$votesCast} / {$totalEligible} eligible voters")
                    ->descriptionIcon('heroicon-m-chart-pie')
                    ->color($participationRate >= 50 ? 'success' : ($participationRate >= 25 ? 'warning' : 'danger'));
            }
        }

        // If no active elections or less than 3, show overall participation
        if (count($stats) < 3) {
            $totalVotes = Vote::distinct('voter_id')->count('voter_id');
            $overallRate = $totalStudents > 0 
                ? round(($totalVotes / $totalStudents) * 100, 1) 
                : 0;

            $stats[] = Stat::make('Overall Participation', "{$overallRate}%")
                ->description("{$totalVotes} / {$totalStudents} students have voted")
                ->descriptionIcon('heroicon-m-chart-pie')
                ->color($overallRate >= 50 ? 'success' : ($overallRate >= 25 ? 'warning' : 'danger'));
        }

        return $stats;
    }
}

