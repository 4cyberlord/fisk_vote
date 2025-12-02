<?php

namespace App\Filament\Pages;

use App\Models\Election;
use App\Services\ElectionResultsService;
use Filament\Actions\Action;
use Filament\Pages\Page;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Concerns\InteractsWithTable;
use Filament\Tables\Contracts\HasTable;
use Filament\Tables\Table;

class ElectionResults extends Page implements HasTable
{
    use InteractsWithTable;

    protected static string | \BackedEnum | null $navigationIcon = 'heroicon-o-chart-bar-square';

    protected string $view = 'filament.pages.election-results';

    protected static ?string $navigationLabel = 'Election Results';

    protected static string | \UnitEnum | null $navigationGroup = 'Voting';

    protected static ?int $navigationSort = 3;

    public function table(Table $table): Table
    {
        return $table
            ->query(
                Election::query()
                    ->where(function ($query) {
                        $query->where('status', 'closed')
                            ->orWhere('end_time', '<', now());
                    })
                    ->latest('end_time')
            )
            ->columns([
                TextColumn::make('title')
                    ->label('Election')
                    ->searchable()
                    ->sortable()
                    ->weight('bold')
                    ->limit(40),

                TextColumn::make('type')
                    ->label('Type')
                    ->badge()
                    ->color('info')
                    ->formatStateUsing(fn (string $state): string => ucfirst($state)),

                TextColumn::make('end_time')
                    ->label('Ended')
                    ->dateTime()
                    ->sortable()
                    ->since(),

                TextColumn::make('votes_count')
                    ->label('Total Votes')
                    ->counts('votes')
                    ->sortable()
                    ->alignCenter(),

                TextColumn::make('current_status')
                    ->label('Status')
                    ->badge()
                    ->color('gray')
                    ->formatStateUsing(fn (string $state): string => $state),
            ])
            ->actions([
                Action::make('view_results')
                    ->label('View Results')
                    ->icon('heroicon-o-chart-bar')
                    ->color('success')
                    ->modalHeading(fn (Election $record) => "Results: {$record->title}")
                    ->modalDescription(fn (Election $record) => "Election ended on " . $record->end_time->format('F j, Y \a\t g:i A'))
                    ->modalContent(fn (Election $record) => view('filament.pages.election-results-modal', [
                        'results' => app(ElectionResultsService::class)->calculateElectionResults($record),
                    ]))
                    ->modalWidth('5xl')
                    ->modalSubmitAction(false)
                    ->modalCancelActionLabel('Close'),
            ])
            ->defaultSort('end_time', 'desc')
            ->heading('Closed Elections - Results Available');
    }
}
