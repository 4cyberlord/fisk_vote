<?php

namespace App\Filament\Widgets;

use App\Models\Vote;
use Filament\Widgets\ChartWidget;
use Illuminate\Support\Carbon;

class VotingActivityChartWidget extends ChartWidget
{
    protected ?string $heading = 'Voting Activity (Last 30 Days)';

    protected static ?int $sort = 3;

    protected function getData(): array
    {
        $startDate = now()->subDays(30);
        $endDate = now();

        // Get votes grouped by date for the last 30 days
        $votes = Vote::whereBetween('voted_at', [$startDate, $endDate])
            ->selectRaw('DATE(voted_at) as date, COUNT(*) as count')
            ->groupBy('date')
            ->orderBy('date')
            ->get();

        // Create array of all dates in range
        $dates = [];
        $counts = [];
        $currentDate = $startDate->copy();

        while ($currentDate <= $endDate) {
            $dateKey = $currentDate->format('Y-m-d');
            $dates[] = $currentDate->format('M j');
            
            $voteCount = $votes->firstWhere('date', $dateKey);
            $counts[] = $voteCount ? $voteCount->count : 0;
            
            $currentDate->addDay();
        }

        return [
            'datasets' => [
                [
                    'label' => 'Votes Cast',
                    'data' => $counts,
                    'backgroundColor' => 'rgba(59, 130, 246, 0.1)',
                    'borderColor' => 'rgb(59, 130, 246)',
                    'fill' => true,
                ],
            ],
            'labels' => $dates,
        ];
    }

    protected function getType(): string
    {
        return 'line';
    }

    protected function getOptions(): array
    {
        return [
            'scales' => [
                'y' => [
                    'beginAtZero' => true,
                    'ticks' => [
                        'stepSize' => 1,
                    ],
                ],
            ],
        ];
    }
}

