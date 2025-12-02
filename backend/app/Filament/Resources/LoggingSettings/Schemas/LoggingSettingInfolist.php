<?php

namespace App\Filament\Resources\LoggingSettings\Schemas;

use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class LoggingSettingInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Logging Preferences')
                    ->schema([
                        TextEntry::make('enable_activity_logs')
                            ->label('Activity Logs')
                            ->badge()
                            ->color(fn (bool $state): string => $state ? 'success' : 'gray')
                            ->formatStateUsing(fn (bool $state): string => $state ? 'Enabled' : 'Disabled'),

                        TextEntry::make('log_admin_actions')
                            ->label('Admin Actions')
                            ->badge()
                            ->color(fn (bool $state): string => $state ? 'success' : 'gray')
                            ->formatStateUsing(fn (bool $state): string => $state ? 'Logged' : 'Not Logged'),

                        TextEntry::make('log_voter_logins')
                            ->label('Voter Logins')
                            ->badge()
                            ->color(fn (bool $state): string => $state ? 'success' : 'gray')
                            ->formatStateUsing(fn (bool $state): string => $state ? 'Logged' : 'Not Logged'),

                        TextEntry::make('log_vote_submission_events')
                            ->label('Vote Submissions (Anonymized)')
                            ->badge()
                            ->color(fn (bool $state): string => $state ? 'success' : 'gray')
                            ->formatStateUsing(fn (bool $state): string => $state ? 'Captured' : 'Disabled'),

                        TextEntry::make('log_ip_addresses')
                            ->label('IP Addresses')
                            ->badge()
                            ->color(fn (bool $state): string => $state ? 'warning' : 'gray')
                            ->formatStateUsing(fn (bool $state): string => $state ? 'Captured (Review Privacy Policy)' : 'Not Captured')
                            ->columnSpan(2),
                    ])
                    ->columns(2)
                    ->collapsible()
                    ->collapsed(false)
                    ->icon('heroicon-o-clipboard-document-list'),

                Section::make('Log Retention')
                    ->schema([
                        TextEntry::make('retention_period')
                            ->label('Retention Period')
                            ->badge()
                            ->color(fn (string $state): string => match ($state) {
                                '30_days' => 'warning',
                                '3_months' => 'info',
                                '1_year' => 'success',
                                'forever' => 'gray',
                                default => 'gray',
                            })
                            ->formatStateUsing(fn (string $state): string => match ($state) {
                                '30_days' => '30 Days',
                                '3_months' => '3 Months',
                                '1_year' => '1 Year',
                                'forever' => 'Forever (Manual Cleanup)',
                                default => ucfirst(str_replace('_', ' ', $state)),
                            }),
                    ])
                    ->collapsible()
                    ->collapsed(false)
                    ->icon('heroicon-o-clock'),

                Section::make('Performance Monitoring')
                    ->schema([
                        TextEntry::make('enable_system_health_dashboard')
                            ->label('System Health Dashboard')
                            ->badge()
                            ->color(fn (bool $state): string => $state ? 'success' : 'gray')
                            ->formatStateUsing(fn (bool $state): string => $state ? 'Enabled' : 'Disabled'),

                        TextEntry::make('track_cpu_load')
                            ->label('CPU Load')
                            ->badge()
                            ->color(fn (bool $state): string => $state ? 'success' : 'gray')
                            ->formatStateUsing(fn (bool $state): string => $state ? 'Tracking' : 'Not Tracking'),

                        TextEntry::make('track_database_queries')
                            ->label('Database Queries')
                            ->badge()
                            ->color(fn (bool $state): string => $state ? 'success' : 'gray')
                            ->formatStateUsing(fn (bool $state): string => $state ? 'Tracking' : 'Not Tracking'),

                        TextEntry::make('track_active_users')
                            ->label('Active Users')
                            ->badge()
                            ->color(fn (bool $state): string => $state ? 'success' : 'gray')
                            ->formatStateUsing(fn (bool $state): string => $state ? 'Tracking' : 'Not Tracking'),

                        TextEntry::make('track_vote_submission_rate')
                            ->label('Vote Submission Rate')
                            ->badge()
                            ->color(fn (bool $state): string => $state ? 'success' : 'gray')
                            ->formatStateUsing(fn (bool $state): string => $state ? 'Tracking' : 'Not Tracking')
                            ->columnSpan(2),
                    ])
                    ->columns(2)
                    ->collapsible()
                    ->collapsed(true)
                    ->icon('heroicon-o-chart-bar-square'),

                Section::make('Error & Crash Handling')
                    ->schema([
                        TextEntry::make('auto_email_admin_on_failure')
                            ->label('Email Alerts')
                            ->badge()
                            ->color(fn (bool $state): string => $state ? 'success' : 'gray')
                            ->formatStateUsing(fn (bool $state): string => $state ? 'Enabled' : 'Disabled'),

                        TextEntry::make('store_crash_reports')
                            ->label('Crash Reports')
                            ->badge()
                            ->color(fn (bool $state): string => $state ? 'success' : 'gray')
                            ->formatStateUsing(fn (bool $state): string => $state ? 'Stored' : 'Discarded'),
                    ])
                    ->collapsible()
                    ->collapsed(true)
                    ->icon('heroicon-o-shield-exclamation'),
            ]);
    }
}

