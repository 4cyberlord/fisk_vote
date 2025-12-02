<?php

namespace App\Filament\Resources\LoggingSettings\Tables;

use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class LoggingSettingsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('retention_period')
                    ->label('Retention')
                    ->badge()
                    ->sortable()
                    ->formatStateUsing(fn (string $state) => match ($state) {
                        '30_days' => '30 Days',
                        '3_months' => '3 Months',
                        '1_year' => '1 Year',
                        'forever' => 'Forever',
                        default => ucfirst(str_replace('_', ' ', $state)),
                    }),

                IconColumn::make('enable_activity_logs')
                    ->label('Logging Enabled')
                    ->boolean()
                    ->toggleable(),

                IconColumn::make('enable_system_health_dashboard')
                    ->label('Health Dashboard')
                    ->boolean()
                    ->toggleable(),

                IconColumn::make('auto_email_admin_on_failure')
                    ->label('Failure Alerts')
                    ->boolean()
                    ->toggleable(),

                TextColumn::make('updated_at')
                    ->label('Last Updated')
                    ->dateTime()
                    ->sortable(),
            ])
            ->filters([])
            ->recordActions([
                ViewAction::make(),
                EditAction::make(),
            ])
            ->defaultSort('updated_at', 'desc')
            ->emptyStateHeading('Logs & Monitoring not configured')
            ->emptyStateDescription('Click "Create" to configure logging, monitoring, and retention policies.')
            ->emptyStateIcon('heroicon-o-chart-bar-square');
    }
}

