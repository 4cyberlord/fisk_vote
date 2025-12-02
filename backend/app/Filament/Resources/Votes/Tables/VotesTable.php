<?php

namespace App\Filament\Resources\Votes\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class VotesTable
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

                TextColumn::make('position.name')
                    ->label('Position')
                    ->searchable()
                    ->sortable(),

                TextColumn::make('voter.name')
                    ->label('Voter')
                    ->searchable()
                    ->sortable()
                    ->weight('bold'),

                TextColumn::make('voter.student_id')
                    ->label('Student ID')
                    ->searchable()
                    ->sortable()
                    ->toggleable(),

                TextColumn::make('vote_data')
                    ->label('Vote Data')
                    ->formatStateUsing(fn ($state) => is_array($state) ? json_encode($state, JSON_PRETTY_PRINT) : $state)
                    ->limit(50)
                    ->tooltip(fn ($record) => json_encode($record->vote_data, JSON_PRETTY_PRINT))
                    ->toggleable(isToggledHiddenByDefault: true),

                TextColumn::make('token')
                    ->label('Token')
                    ->copyable()
                    ->limit(20)
                    ->tooltip(fn ($record) => $record->token)
                    ->toggleable(isToggledHiddenByDefault: true),

                TextColumn::make('voted_at')
                    ->label('Voted At')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(),

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

                SelectFilter::make('position_id')
                    ->label('Position')
                    ->relationship('position', 'name')
                    ->searchable()
                    ->preload(),

                SelectFilter::make('voter_id')
                    ->label('Voter')
                    ->relationship('voter', 'name')
                    ->searchable()
                    ->preload(),
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
            ->defaultSort('voted_at', 'desc')
            ->emptyStateHeading('No votes yet')
            ->emptyStateDescription('Votes will appear here once they are cast.')
            ->emptyStateIcon('heroicon-o-check-circle');
    }
}
