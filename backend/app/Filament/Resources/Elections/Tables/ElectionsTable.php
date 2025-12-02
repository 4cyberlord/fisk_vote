<?php

namespace App\Filament\Resources\Elections\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class ElectionsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('title')
                    ->label('Election Title')
                    ->searchable()
                    ->sortable()
                    ->weight('bold')
                    ->limit(50),

                TextColumn::make('type')
                    ->label('Type')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'single' => 'primary',
                        'multiple' => 'info',
                        'referendum' => 'success',
                        'ranked' => 'warning',
                        'poll' => 'gray',
                        default => 'gray',
                    })
                    ->sortable(),

                TextColumn::make('status')
                    ->label('Status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'draft' => 'gray',
                        'active' => 'success',
                        'closed' => 'danger',
                        'archived' => 'warning',
                        default => 'gray',
                    })
                    ->sortable(),

                TextColumn::make('start_time')
                    ->label('Start Time')
                    ->dateTime()
                    ->sortable(),

                TextColumn::make('end_time')
                    ->label('End Time')
                    ->dateTime()
                    ->sortable(),

                IconColumn::make('is_universal')
                    ->label('Universal')
                    ->boolean()
                    ->toggleable(isToggledHiddenByDefault: true),

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
                SelectFilter::make('type')
                    ->label('Election Type')
                    ->options([
                        'single' => 'Single Choice',
                        'multiple' => 'Multiple Choice',
                        'referendum' => 'Referendum',
                        'ranked' => 'Ranked Choice',
                        'poll' => 'Poll',
                    ]),

                SelectFilter::make('status')
                    ->label('Status')
                    ->options([
                        'draft' => 'Draft',
                        'active' => 'Active',
                        'closed' => 'Closed',
                        'archived' => 'Archived',
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
            ->emptyStateHeading('No elections yet')
            ->emptyStateDescription('Create your first election to get started.')
            ->emptyStateIcon('heroicon-o-clipboard-document-check');
    }
}
