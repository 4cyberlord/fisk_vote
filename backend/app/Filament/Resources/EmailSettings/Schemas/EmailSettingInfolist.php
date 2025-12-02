<?php

namespace App\Filament\Resources\EmailSettings\Schemas;

use Filament\Infolists\Components\IconEntry;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class EmailSettingInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Email Server Configuration')
                    ->schema([
                        TextEntry::make('smtp_host')
                            ->label('SMTP Host')
                            ->icon('heroicon-o-server')
                            ->columnSpan(2),

                        TextEntry::make('smtp_port')
                            ->label('SMTP Port')
                            ->icon('heroicon-o-hashtag')
                            ->columnSpan(1),

                        TextEntry::make('encryption_type')
                            ->label('Encryption Type')
                            ->badge()
                            ->color(fn (string $state): string => match ($state) {
                                'tls' => 'success',
                                'ssl' => 'info',
                                'none' => 'gray',
                                default => 'gray',
                            })
                            ->columnSpan(1),

                        TextEntry::make('smtp_username')
                            ->label('Username')
                            ->icon('heroicon-o-user')
                            ->columnSpanFull(),

                        TextEntry::make('smtp_password')
                            ->label('Password')
                            ->formatStateUsing(fn ($state) => $state ? '••••••••' : 'Not set')
                            ->icon('heroicon-o-lock-closed')
                            ->columnSpanFull(),
                    ])
                    ->columns(3)
                    ->collapsible()
                    ->icon('heroicon-o-server'),

                Section::make('Email Templates')
                    ->schema([
                        TextEntry::make('voter_registration_email')
                            ->label('Voter Registration Email')
                            ->placeholder('Not configured')
                            ->columnSpanFull(),

                        TextEntry::make('email_verification')
                            ->label('Email Verification')
                            ->placeholder('Not configured')
                            ->columnSpanFull(),

                        TextEntry::make('password_reset')
                            ->label('Password Reset')
                            ->placeholder('Not configured')
                            ->columnSpanFull(),

                        TextEntry::make('election_announcement')
                            ->label('Election Announcement')
                            ->placeholder('Not configured')
                            ->columnSpanFull(),

                        TextEntry::make('upcoming_election_reminder')
                            ->label('Upcoming Election Reminder')
                            ->placeholder('Not configured')
                            ->columnSpanFull(),

                        TextEntry::make('thank_you_for_voting')
                            ->label('Thank You for Voting')
                            ->placeholder('Not configured')
                            ->columnSpanFull(),

                        TextEntry::make('result_announcement_email')
                            ->label('Result Announcement Email')
                            ->placeholder('Not configured')
                            ->columnSpanFull(),
                    ])
                    ->collapsible()
                    ->icon('heroicon-o-document-text'),

                Section::make('Notification Preferences')
                    ->schema([
                        IconEntry::make('send_daily_summary_to_admins')
                            ->label('Send Daily Summary to Admins')
                            ->boolean()
                            ->trueIcon('heroicon-o-check-circle')
                            ->falseIcon('heroicon-o-x-circle')
                            ->trueColor('success')
                            ->falseColor('gray')
                            ->columnSpan(1),

                        IconEntry::make('send_voting_activity_alerts')
                            ->label('Send Voting Activity Alerts')
                            ->boolean()
                            ->trueIcon('heroicon-o-check-circle')
                            ->falseIcon('heroicon-o-x-circle')
                            ->trueColor('success')
                            ->falseColor('gray')
                            ->columnSpan(1),

                        IconEntry::make('notify_users_when_election_opens')
                            ->label('Notify When Election Opens')
                            ->boolean()
                            ->trueIcon('heroicon-o-check-circle')
                            ->falseIcon('heroicon-o-x-circle')
                            ->trueColor('success')
                            ->falseColor('gray')
                            ->columnSpan(1),

                        IconEntry::make('notify_eligible_voters_before_election_ends')
                            ->label('Remind Voters Before Election Ends')
                            ->boolean()
                            ->trueIcon('heroicon-o-check-circle')
                            ->falseIcon('heroicon-o-x-circle')
                            ->trueColor('success')
                            ->falseColor('gray')
                            ->columnSpan(1),
                    ])
                    ->columns(2)
                    ->collapsible()
                    ->icon('heroicon-o-bell'),

                Section::make('Metadata')
                    ->schema([
                        TextEntry::make('created_at')
                            ->label('Created At')
                            ->dateTime()
                            ->columnSpan(1),

                        TextEntry::make('updated_at')
                            ->label('Last Updated')
                            ->dateTime()
                            ->columnSpan(2),
                    ])
                    ->columns(3)
                    ->collapsible()
                    ->collapsed(),
            ]);
    }
}
