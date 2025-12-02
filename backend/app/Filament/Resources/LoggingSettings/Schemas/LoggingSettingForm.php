<?php

namespace App\Filament\Resources\LoggingSettings\Schemas;

use Filament\Forms\Components\Radio;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Components\View;
use Filament\Schemas\Schema;

class LoggingSettingForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Logging Preferences')
                    ->description('Control what activity is captured within the application. Make sure your privacy policy reflects the settings you enable.')
                    ->schema([
                        Toggle::make('enable_activity_logs')
                            ->label('Enable Activity Logs')
                            ->inline(false)
                            ->helperText('Master switch that powers all activity logging features throughout the platform.')
                            ->required(),
                        Toggle::make('log_admin_actions')
                            ->label('Log Admin Actions')
                            ->inline(false)
                            ->helperText('Capture a secure audit trail of sensitive admin tasks such as role assignment or results certification.')
                            ->disabled(fn ($get) => ! $get('enable_activity_logs')),
                        Toggle::make('log_voter_logins')
                            ->label('Log Voter Logins')
                            ->inline(false)
                            ->helperText('Track successful and failed voter authentication events for security visibility.')
                            ->disabled(fn ($get) => ! $get('enable_activity_logs')),
                        Toggle::make('log_vote_submission_events')
                            ->label('Log Vote Submission Events')
                            ->inline(false)
                            ->helperText('Record anonymized vote submission metadata (never store ballot selections).')
                            ->disabled(fn ($get) => ! $get('enable_activity_logs')),
                        Toggle::make('log_ip_addresses')
                            ->label('Log IP Addresses')
                            ->inline(false)
                            ->helperText('Collect IP addresses for investigations. Ensure data retention complies with your institution’s privacy policy.')
                            ->disabled(fn ($get) => ! $get('enable_activity_logs')),
                    ])
                    ->columns(2)
                    ->collapsible()
                    ->collapsed(false)
                    ->icon('heroicon-o-clipboard-document-list'),

                Section::make('Log Retention')
                    ->description('Define how long system logs are retained before automated cleanup routines purge historical data.')
                    ->schema([
                        Radio::make('retention_period')
                            ->label('Retention Period')
                            ->options([
                                '30_days' => '30 Days',
                                '3_months' => '3 Months',
                                '1_year' => '1 Year',
                                'forever' => 'Forever (manual purge)',
                            ])
                            ->default('3_months')
                            ->inline(false)
                            ->helperText('Shorter retention reduces risk exposure. Forever retention requires a manual purge strategy.'),
                        View::make('filament.components.form.log-retention-note')
                            ->columnSpanFull()
                            ->visible(fn () => true),
                    ])
                    ->collapsible()
                    ->collapsed(false)
                    ->icon('heroicon-o-clock'),

                Section::make('Performance Monitoring')
                    ->description('Enable proactive monitoring that powers dashboards, alerts, and capacity planning.')
                    ->schema([
                        Toggle::make('enable_system_health_dashboard')
                            ->label('Enable System Health Dashboard')
                            ->inline(false)
                            ->helperText('Expose real-time status indicators within the admin panel.'),
                        Toggle::make('track_cpu_load')
                            ->label('Track CPU Load')
                            ->inline(false)
                            ->helperText('Collect CPU averages to identify performance degradation.'),
                        Toggle::make('track_database_queries')
                            ->label('Track Database Queries')
                            ->inline(false)
                            ->helperText('Monitor query volume & latency to catch database bottlenecks early.'),
                        Toggle::make('track_active_users')
                            ->label('Track Active Users')
                            ->inline(false)
                            ->helperText('Visualize concurrent usage to forecast capacity and licensing needs.'),
                        Toggle::make('track_vote_submission_rate')
                            ->label('Track Vote Submission Rate')
                            ->inline(false)
                            ->helperText('Surface spikes or drops in vote submissions to detect anomalies during elections.'),
                    ])
                    ->columns(2)
                    ->collapsible()
                    ->collapsed(true)
                    ->icon('heroicon-o-chart-bar-square'),

                Section::make('Error & Crash Handling')
                    ->description('Capture and respond to system failures automatically so teams can resolve issues quickly.')
                    ->schema([
                        Toggle::make('auto_email_admin_on_failure')
                            ->label('Auto Email Admin on System Failure')
                            ->inline(false)
                            ->helperText('Trigger immediate email alerts when critical exceptions occur. Configure recipients in Email & Notification Settings.'),
                        Toggle::make('store_crash_reports')
                            ->label('Store Crash Reports')
                            ->inline(false)
                            ->helperText('Persist crash dumps for forensic analysis. Remember to purge sensitive data after resolution.'),
                    ])
                    ->collapsible()
                    ->collapsed(true)
                    ->icon('heroicon-o-shield-exclamation'),

                Section::make('Operational Guidance')
                    ->schema([
                        View::make('filament.components.form.logging-guidance')
                            ->columnSpanFull()
                    ])
                    ->collapsible()
                    ->collapsed(true)
                    ->icon('heroicon-o-information-circle'),
            ]);
    }
}

