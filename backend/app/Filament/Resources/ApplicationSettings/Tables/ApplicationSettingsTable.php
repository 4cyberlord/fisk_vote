<?php

namespace App\Filament\Resources\ApplicationSettings\Tables;

use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class ApplicationSettingsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('system_name')
                    ->label('System Name')
                    ->searchable()
                    ->sortable()
                    ->weight('bold'),

                TextColumn::make('university_name')
                    ->label('University')
                    ->searchable()
                    ->sortable(),

                TextColumn::make('default_timezone')
                    ->label('Timezone')
                    ->sortable()
                    ->toggleable(),

                TextColumn::make('dashboard_theme')
                    ->label('Theme')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'light' => 'gray',
                        'dark' => 'dark',
                        'auto' => 'info',
                        default => 'gray',
                    })
                    ->sortable(),

                TextColumn::make('updated_at')
                    ->label('Last Updated')
                    ->dateTime()
                    ->sortable(),
            ])
            ->filters([
                //
            ])
            ->recordActions([
                ViewAction::make(),
                EditAction::make(),
            ])
            ->defaultSort('updated_at', 'desc')
            ->emptyStateHeading('No settings configured')
            ->emptyStateDescription('Click "Edit" to configure application settings.')
            ->emptyStateIcon('heroicon-o-cog-6-tooth');
    }
}
