<?php

namespace App\Filament\Widgets;

use App\Models\Election;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;
use Illuminate\Support\HtmlString;

class ActiveElectionsWidget extends BaseWidget
{
    protected static ?int $sort = 1;

    protected int | string | array $columnSpan = 'full';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                Election::query()
                    ->where('status', 'active')
                    ->where('start_time', '<=', now())
                    ->where('end_time', '>=', now())
                    ->latest('start_time')
                    ->limit(5)
            )
            ->columns([
                TextColumn::make('title')
                    ->label('Election')
                    ->searchable()
                    ->sortable()
                    ->limit(40)
                    ->weight('bold'),

                TextColumn::make('type')
                    ->label('Type')
                    ->badge()
                    ->color('info')
                    ->formatStateUsing(fn (string $state): string => ucfirst($state)),

                TextColumn::make('start_time')
                    ->label('Started')
                    ->dateTime()
                    ->sortable()
                    ->since(),

                TextColumn::make('end_time')
                    ->label('Ends')
                    ->dateTime()
                    ->sortable()
                    ->since(),

                TextColumn::make('votes_count')
                    ->label('Votes')
                    ->counts('votes')
                    ->sortable()
                    ->alignCenter(),

                TextColumn::make('current_status')
                    ->label('Status')
                    ->badge()
                    ->color('success')
                    ->formatStateUsing(fn (string $state): string => $state),
            ])
            ->defaultSort('start_time', 'desc')
            ->heading('Active Elections')
            ->description('Elections currently open for voting');
    }
}

