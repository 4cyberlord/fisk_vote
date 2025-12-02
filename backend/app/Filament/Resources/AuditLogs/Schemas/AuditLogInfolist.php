<?php

namespace App\Filament\Resources\AuditLogs\Schemas;

use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class AuditLogInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Action Information')
                    ->schema([
                        TextEntry::make('action_type')
                            ->label('Action Type')
                            ->badge()
                            ->color(fn (string $state): string => match($state) {
                                'created' => 'success',
                                'updated' => 'info',
                                'deleted' => 'danger',
                                'login.success' => 'success',
                                'login.failed' => 'danger',
                                'logout' => 'gray',
                                'vote.submitted' => 'success',
                                default => 'primary',
                            }),

                        TextEntry::make('action_description')
                            ->label('Description')
                            ->columnSpanFull(),

                        TextEntry::make('event_type')
                            ->label('Event Type')
                            ->badge()
                            ->color('info'),

                        TextEntry::make('status')
                            ->label('Status')
                            ->badge()
                            ->color(fn (string $state): string => match($state) {
                                'success' => 'success',
                                'failed' => 'danger',
                                'pending' => 'warning',
                                default => 'gray',
                            }),

                        TextEntry::make('created_at')
                            ->label('Date & Time')
                            ->formatStateUsing(fn ($state) => $state 
                                ? $state->format('F j, Y \a\t g:i A') . ' (' . $state->diffForHumans() . ')'
                                : 'N/A'),
                    ])
                    ->columns(2),

                Section::make('User Information')
                    ->schema([
                        TextEntry::make('user_name')
                            ->label('User Name')
                            ->default('System'),

                        TextEntry::make('user_email')
                            ->label('Email')
                            ->icon('heroicon-o-envelope')
                            ->default('N/A'),

                        TextEntry::make('user_role')
                            ->label('Role')
                            ->badge()
                            ->color('info')
                            ->default('N/A'),

                        TextEntry::make('user.name')
                            ->label('Current User Profile')
                            ->url(fn ($record) => $record->user ? route('filament.admin.resources.users.view', $record->user) : null)
                            ->openUrlInNewTab()
                            ->default('N/A'),
                    ])
                    ->columns(2)
                    ->collapsible(),

                Section::make('Resource Information')
                    ->schema([
                        TextEntry::make('resource_name')
                            ->label('Resource')
                            ->default('N/A'),

                        TextEntry::make('auditable_type')
                            ->label('Resource Type')
                            ->formatStateUsing(fn (?string $state): string => $state ? class_basename($state) : 'N/A'),

                        TextEntry::make('auditable_id')
                            ->label('Resource ID')
                            ->default('N/A'),
                    ])
                    ->columns(3)
                    ->collapsible()
                    ->visible(fn ($record) => $record->auditable_type !== null),

                Section::make('Changes')
                    ->schema([
                        TextEntry::make('changes_summary')
                            ->label('Summary')
                            ->columnSpanFull()
                            ->default('No changes recorded'),

                        TextEntry::make('old_values')
                            ->label('Old Values')
                            ->formatStateUsing(fn ($state) => $state ? json_encode($state, JSON_PRETTY_PRINT) : 'N/A')
                            ->columnSpan(1)
                            ->visible(fn ($record) => !empty($record->old_values))
                            ->copyable(),

                        TextEntry::make('new_values')
                            ->label('New Values')
                            ->formatStateUsing(fn ($state) => $state ? json_encode($state, JSON_PRETTY_PRINT) : 'N/A')
                            ->columnSpan(1)
                            ->visible(fn ($record) => !empty($record->new_values))
                            ->copyable(),
                    ])
                    ->columns(2)
                    ->collapsible()
                    ->visible(fn ($record) => !empty($record->old_values) || !empty($record->new_values)),

                Section::make('Request Context')
                    ->schema([
                        TextEntry::make('ip_address')
                            ->label('IP Address')
                            ->default('N/A'),

                        TextEntry::make('user_agent')
                            ->label('User Agent')
                            ->limit(50)
                            ->tooltip(fn ($record) => $record->user_agent)
                            ->default('N/A'),

                        TextEntry::make('request_url')
                            ->label('URL')
                            ->limit(50)
                            ->tooltip(fn ($record) => $record->request_url)
                            ->default('N/A'),

                        TextEntry::make('request_method')
                            ->label('HTTP Method')
                            ->badge()
                            ->color(fn (?string $state): string => match($state) {
                                'GET' => 'info',
                                'POST' => 'success',
                                'PUT' => 'warning',
                                'PATCH' => 'warning',
                                'DELETE' => 'danger',
                                default => 'gray',
                            })
                            ->default('N/A'),

                        TextEntry::make('session_id')
                            ->label('Session ID')
                            ->default('N/A'),
                    ])
                    ->columns(2)
                    ->collapsible()
                    ->visible(fn ($record) => $record->ip_address !== null),

                Section::make('Error Information')
                    ->schema([
                        TextEntry::make('error_message')
                            ->label('Error Message')
                            ->color('danger')
                            ->columnSpanFull(),
                    ])
                    ->collapsible()
                    ->visible(fn ($record) => $record->status === 'failed' && $record->error_message !== null),

                Section::make('Metadata')
                    ->schema([
                        TextEntry::make('metadata')
                            ->label('Additional Data')
                            ->formatStateUsing(fn ($state) => $state ? json_encode($state, JSON_PRETTY_PRINT) : 'N/A')
                            ->columnSpanFull()
                            ->copyable(),
                    ])
                    ->collapsible()
                    ->visible(fn ($record) => !empty($record->metadata)),
            ]);
    }
}
