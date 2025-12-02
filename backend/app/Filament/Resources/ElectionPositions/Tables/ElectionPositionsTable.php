<?php

namespace App\Filament\Resources\ElectionPositions\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class ElectionPositionsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('election.title')
                    ->label('Election')
                    ->searchable()
                    ->sortable()
                    ->weight('bold'),

                TextColumn::make('name')
                    ->label('Position Name')
                    ->searchable()
                    ->sortable(),

                TextColumn::make('type')
                    ->label('Type')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'single' => 'primary',
                        'multiple' => 'info',
                        'ranked' => 'warning',
                        default => 'gray',
                    })
                    ->sortable(),

                TextColumn::make('max_selection')
                    ->label('Max Selections')
                    ->numeric()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),

                TextColumn::make('ranking_levels')
                    ->label('Ranking Levels')
                    ->numeric()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),

                TextColumn::make('allow_abstain')
                    ->label('Allow Abstain')
                    ->badge()
                    ->formatStateUsing(fn ($state) => $state ? 'Yes' : 'No')
                    ->color(fn ($state) => $state ? 'success' : 'gray')
                    ->sortable(),

                TextColumn::make('created_at')
                    ->label('Created')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),

                TextColumn::make('updated_at')
                    ->label('Updated')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                SelectFilter::make('election_id')
                    ->label('Election')
                    ->relationship('election', 'title')
                    ->searchable()
                    ->preload(),

                SelectFilter::make('type')
                    ->label('Position Type')
                    ->options([
                        'single' => 'Single Choice',
                        'multiple' => 'Multiple Choice',
                        'ranked' => 'Ranked Choice',
                    ]),
            ])
            ->recordActions([
                ViewAction::make(),
                EditAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ])
            ->defaultSort('created_at', 'desc')
            ->emptyStateHeading('No positions yet')
            ->emptyStateDescription('Create your first election position to get started.')
            ->emptyStateIcon('heroicon-o-briefcase');
    }
}
