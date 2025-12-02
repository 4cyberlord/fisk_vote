<?php

namespace App\Filament\Widgets;

use App\Models\Election;
use Filament\Widgets\ChartWidget;

class ElectionStatusChartWidget extends ChartWidget
{
    protected ?string $heading = 'Election Status Distribution';

    protected static ?int $sort = 2;

    protected function getData(): array
    {
        $now = now();
        
        $open = Election::where('status', 'active')
            ->where('start_time', '<=', $now)
            ->where('end_time', '>=', $now)
            ->count();

        $upcoming = Election::where('status', 'active')
            ->where('start_time', '>', $now)
            ->count();

        $closed = Election::where(function ($query) use ($now) {
            $query->where('status', 'closed')
                ->orWhere('end_time', '<', $now);
        })->count();

        return [
            'datasets' => [
                [
                    'label' => 'Elections',
                    'data' => [$open, $upcoming, $closed],
                    'backgroundColor' => [
                        'rgb(34, 197, 94)',   // Green for Open
                        'rgb(59, 130, 246)',  // Blue for Upcoming
                        'rgb(107, 114, 128)', // Gray for Closed
                    ],
                ],
            ],
            'labels' => ['Open', 'Upcoming', 'Closed'],
        ];
    }

    protected function getType(): string
    {
        return 'doughnut';
    }
}

