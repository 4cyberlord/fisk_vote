<?php

namespace App\Filament\Widgets;

use App\Models\Election;
use App\Models\User;
use App\Models\Vote;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class StatsOverviewWidget extends BaseWidget
{
    protected function getStats(): array
    {
        $totalElections = Election::count();
        $activeElections = Election::where('status', 'active')
            ->where('start_time', '<=', now())
            ->where('end_time', '>=', now())
            ->count();
        $upcomingElections = Election::where('status', 'active')
            ->where('start_time', '>', now())
            ->count();
        $closedElections = Election::where(function ($query) {
            $query->where('status', 'closed')
                ->orWhere('end_time', '<', now());
        })->count();

        $totalStudents = User::whereHas('roles', function ($query) {
            $query->where('name', 'student');
        })->count();

        $totalVotes = Vote::count();
        $uniqueVoters = Vote::distinct('voter_id')->count('voter_id');
        $participationRate = $totalStudents > 0 
            ? round(($uniqueVoters / $totalStudents) * 100, 1) 
            : 0;

        $todayVotes = Vote::whereDate('voted_at', today())->count();
        $thisWeekVotes = Vote::whereBetween('voted_at', [now()->startOfWeek(), now()->endOfWeek()])->count();

        return [
            Stat::make('Total Elections', $totalElections)
                ->description('All elections in the system')
                ->descriptionIcon('heroicon-m-clipboard-document-check')
                ->color('primary')
                ->chart($this->getElectionTrendData()),

            Stat::make('Active Elections', $activeElections)
                ->description('Currently open for voting')
                ->descriptionIcon('heroicon-m-check-circle')
                ->color('success'),

            Stat::make('Upcoming Elections', $upcomingElections)
                ->description('Scheduled to start soon')
                ->descriptionIcon('heroicon-m-clock')
                ->color('info'),

            Stat::make('Total Students', $totalStudents)
                ->description('Registered students')
                ->descriptionIcon('heroicon-m-users')
                ->color('warning'),

            Stat::make('Total Votes Cast', $totalVotes)
                ->description("{$uniqueVoters} unique voters ({$participationRate}% participation)")
                ->descriptionIcon('heroicon-m-check-badge')
                ->color('success')
                ->chart($this->getVoteTrendData()),

            Stat::make('Votes Today', $todayVotes)
                ->description("{$thisWeekVotes} votes this week")
                ->descriptionIcon('heroicon-m-chart-bar')
                ->color('primary'),
        ];
    }

    protected function getElectionTrendData(): array
    {
        // Get election counts for the last 7 days
        $data = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = now()->subDays($i);
            $count = Election::whereDate('created_at', $date)->count();
            $data[] = $count;
        }
        return $data;
    }

    protected function getVoteTrendData(): array
    {
        // Get vote counts for the last 7 days
        $data = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = now()->subDays($i);
            $count = Vote::whereDate('voted_at', $date)->count();
            $data[] = $count;
        }
        return $data;
    }
}

