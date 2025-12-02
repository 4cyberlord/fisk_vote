<?php

namespace App\Filament\Resources\ElectionCandidates\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\SpatieMediaLibraryImageColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class ElectionCandidatesTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                SpatieMediaLibraryImageColumn::make('photo')
                    ->label('Photo')
                    ->collection('photo')
                    ->conversion('thumb')
                    ->circular()
                    ->defaultImageUrl(url('/images/default-avatar.png'))
                    ->toggleable(),

                TextColumn::make('user.name')
                    ->label('Candidate')
                    ->searchable()
                    ->sortable()
                    ->weight('bold'),

                TextColumn::make('user.student_id')
                    ->label('Student ID')
                    ->searchable()
                    ->sortable()
                    ->toggleable(),

                TextColumn::make('election.title')
                    ->label('Election')
                    ->searchable()
                    ->sortable()
                    ->toggleable(),

                TextColumn::make('position.name')
                    ->label('Position')
                    ->searchable()
                    ->sortable(),

                TextColumn::make('tagline')
                    ->label('Tagline')
                    ->limit(30)
                    ->toggleable(isToggledHiddenByDefault: true),

                TextColumn::make('approved')
                    ->label('Approved')
                    ->badge()
                    ->formatStateUsing(fn ($state) => $state ? 'Approved' : 'Pending')
                    ->color(fn ($state) => $state ? 'success' : 'warning')
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

                SelectFilter::make('position_id')
                    ->label('Position')
                    ->relationship('position', 'name')
                    ->searchable()
                    ->preload(),

                SelectFilter::make('approved')
                    ->label('Approval Status')
                    ->options([
                        true => 'Approved',
                        false => 'Pending',
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
            ->emptyStateHeading('No candidates yet')
            ->emptyStateDescription('Create your first candidate to get started.')
            ->emptyStateIcon('heroicon-o-user-circle');
    }
}
