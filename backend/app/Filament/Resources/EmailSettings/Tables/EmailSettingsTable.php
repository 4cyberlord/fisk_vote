<?php

namespace App\Filament\Resources\EmailSettings\Tables;

use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class EmailSettingsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('smtp_host')
                    ->label('SMTP Host')
                    ->searchable()
                    ->sortable()
                    ->weight('bold'),

                TextColumn::make('smtp_port')
                    ->label('Port')
                    ->numeric()
                    ->sortable(),

                TextColumn::make('encryption_type')
                    ->label('Encryption')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'tls' => 'success',
                        'ssl' => 'info',
                        'none' => 'gray',
                        default => 'gray',
                    })
                    ->sortable(),

                IconColumn::make('notify_users_when_election_opens')
                    ->label('Election Notifications')
                    ->boolean()
                    ->sortable(),

                IconColumn::make('notify_eligible_voters_before_election_ends')
                    ->label('Reminder Notifications')
                    ->boolean()
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
            ->emptyStateHeading('No email settings configured')
            ->emptyStateDescription('Click "Edit" to configure email and notification settings.')
            ->emptyStateIcon('heroicon-o-envelope');
    }
}
