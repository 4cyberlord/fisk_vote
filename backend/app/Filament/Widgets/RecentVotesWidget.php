<?php

namespace App\Filament\Widgets;

use App\Models\Vote;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;

class RecentVotesWidget extends BaseWidget
{
    protected static ?int $sort = 5;

    protected int | string | array $columnSpan = 'full';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                Vote::query()
                    ->with(['election', 'voter'])
                    ->latest('voted_at')
                    ->limit(10)
            )
            ->columns([
                TextColumn::make('election.title')
                    ->label('Election')
                    ->searchable()
                    ->sortable()
                    ->limit(30),

                TextColumn::make('voter.name')
                    ->label('Voter')
                    ->searchable()
                    ->sortable(),

                TextColumn::make('voted_at')
                    ->label('Voted At')
                    ->dateTime()
                    ->sortable()
                    ->since(),

                TextColumn::make('election.current_status')
                    ->label('Status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'Open' => 'success',
                        'Upcoming' => 'info',
                        'Closed' => 'gray',
                        default => 'gray',
                    }),
            ])
            ->defaultSort('voted_at', 'desc');
    }
}

