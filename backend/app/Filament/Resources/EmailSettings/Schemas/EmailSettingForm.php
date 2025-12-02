<?php

namespace App\Filament\Resources\EmailSettings\Schemas;

use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class EmailSettingForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                // Email Service Selection
                Section::make('Email Service Provider')
                    ->description('Choose your email service provider. You can switch between services at any time.')
                    ->schema([
                        Select::make('email_service')
                            ->label('Email Service')
                            ->options([
                                'smtp' => 'SMTP (Standard Email Server)',
                                'mailtrap' => 'Mailtrap (Email Testing & Sending)',
                            ])
                            ->default('smtp')
                            ->required()
                            ->native(false)
                            ->live()
                            ->columnSpanFull()
                            ->helperText('Select the email service you want to use for sending emails. SMTP is for standard email servers, while Mailtrap is great for testing and production sending.')
                            ->placeholder('Select an email service...'),
                    ])
                    ->icon('heroicon-o-envelope')
                    ->collapsible()
                    ->collapsed(false),

                // SMTP Configuration (shown only when SMTP is selected)
                Section::make('SMTP Server Configuration')
                    ->description('Configure your SMTP server connection settings. These credentials will be encrypted for security.')
                    ->schema([
                        TextInput::make('smtp_host')
                            ->label('SMTP Host')
                            ->maxLength(255)
                            ->placeholder('smtp.gmail.com')
                            ->required(fn ($get) => $get('email_service') === 'smtp')
                            ->visible(fn ($get) => $get('email_service') === 'smtp')
                            ->helperText('Enter your SMTP server hostname (e.g., smtp.gmail.com, smtp.outlook.com)')
                            ->columnSpanFull(),

                        TextInput::make('smtp_port')
                            ->label('SMTP Port')
                            ->numeric()
                            ->default(587)
                            ->minValue(1)
                            ->maxValue(65535)
                            ->required(fn ($get) => $get('email_service') === 'smtp')
                            ->visible(fn ($get) => $get('email_service') === 'smtp')
                            ->helperText('Common ports: 587 (TLS), 465 (SSL), 25 (unencrypted)')
                            ->columnSpanFull(),

                        Select::make('encryption_type')
                            ->label('Encryption Type')
                            ->options([
                                'tls' => 'TLS (Recommended)',
                                'ssl' => 'SSL',
                                'none' => 'None (Not Recommended)',
                            ])
                            ->default('tls')
                            ->required(fn ($get) => $get('email_service') === 'smtp')
                            ->visible(fn ($get) => $get('email_service') === 'smtp')
                            ->native(false)
                            ->helperText('Choose the encryption method for your SMTP connection')
                            ->columnSpanFull(),

                        TextInput::make('smtp_username')
                            ->label('SMTP Username')
                            ->maxLength(255)
                            ->placeholder('your-email@example.com')
                            ->visible(fn ($get) => $get('email_service') === 'smtp')
                            ->helperText('Your email address or SMTP username')
                            ->columnSpanFull(),

                        TextInput::make('smtp_password')
                            ->label('SMTP Password')
                            ->password()
                            ->maxLength(255)
                            ->placeholder('Enter your SMTP password')
                            ->helperText('Leave blank to keep existing password. The password will be encrypted when saved.')
                            ->dehydrated(fn ($state) => filled($state))
                            ->visible(fn ($get) => $get('email_service') === 'smtp')
                            ->columnSpanFull(),
                    ])
                    ->collapsible()
                    ->icon('heroicon-o-server')
                    ->visible(fn ($get) => $get('email_service') === 'smtp'),

                // Mailtrap Configuration (shown only when Mailtrap is selected)
                Section::make('Mailtrap Configuration')
                    ->description('Configure your Mailtrap API settings for email testing and sending. Get your API key from https://mailtrap.io/api-tokens')
                    ->schema([
                        TextInput::make('mailtrap_api_key')
                            ->label('Mailtrap API Key')
                            ->maxLength(255)
                            ->placeholder('Enter your Mailtrap API token')
                            ->required(fn ($get) => $get('email_service') === 'mailtrap')
                            ->visible(fn ($get) => $get('email_service') === 'mailtrap')
                            ->helperText('Your Mailtrap API token. The API key will be encrypted when saved. You can view and edit it here.')
                            ->columnSpanFull(),

                        Toggle::make('mailtrap_use_sandbox')
                            ->label('Enable Sandbox Mode')
                            ->helperText('Sandbox mode: Test emails safely (no real delivery). Production mode: Send real emails to actual recipients. For production, ensure your domain is verified in Mailtrap and your API key has production permissions.')
                            ->default(true)
                            ->visible(fn ($get) => $get('email_service') === 'mailtrap')
                            ->live()
                            ->columnSpanFull()
                            ->inline(false),

                        TextInput::make('mailtrap_inbox_id')
                            ->label('Sandbox Inbox ID')
                            ->numeric()
                            ->placeholder('Enter your Mailtrap inbox ID')
                            ->helperText('Required only when sandbox mode is enabled. Find this in your Mailtrap inbox settings.')
                            ->required(fn ($get) => 
                                $get('email_service') === 'mailtrap' && 
                                $get('mailtrap_use_sandbox') === true
                            )
                            ->visible(fn ($get) => 
                                $get('email_service') === 'mailtrap' && 
                                $get('mailtrap_use_sandbox') === true
                            )
                            ->columnSpanFull(),
                    ])
                    ->collapsible()
                    ->icon('heroicon-o-shield-check')
                    ->visible(fn ($get) => $get('email_service') === 'mailtrap'),

                // Notification Preferences Section
                Section::make('Notification Preferences')
                    ->description('Configure automated email notifications for administrators and voters')
                    ->schema([
                        Toggle::make('send_daily_summary_to_admins')
                            ->label('Daily Summary to Administrators')
                            ->helperText('Send a daily summary email to administrators with voting activity statistics and important updates')
                            ->default(false)
                            ->columnSpanFull()
                            ->inline(false),

                        Toggle::make('send_voting_activity_alerts')
                            ->label('Real-time Voting Activity Alerts')
                            ->helperText('Send immediate email alerts to administrators when significant voting activity or milestones are reached')
                            ->default(false)
                            ->columnSpanFull()
                            ->inline(false),

                        Toggle::make('notify_users_when_election_opens')
                            ->label('Election Opening Notifications')
                            ->helperText('Automatically send email notifications to all eligible voters when a new election becomes available')
                            ->default(true)
                            ->columnSpanFull()
                            ->inline(false),

                        Toggle::make('notify_eligible_voters_before_election_ends')
                            ->label('Election Closing Reminders')
                            ->helperText('Send reminder emails to eligible voters who haven\'t voted yet, 1 hour before the election closes')
                            ->default(true)
                            ->columnSpanFull()
                            ->inline(false),
                    ])
                    ->icon('heroicon-o-bell')
                    ->collapsible()
                    ->collapsed(false),

                // Email Templates Section
                Section::make('Email Templates')
                    ->description('Customize email templates for various system notifications. Use placeholders to personalize messages.')
                    ->schema([
                        Textarea::make('voter_registration_email')
                            ->label('Voter Registration Email')
                            ->rows(5)
                            ->placeholder('Welcome {name}!

Thank you for registering to vote in our election system. Your student ID is {student_id}.

Please verify your email address to complete your registration.

Best regards,
Election Committee')
                            ->helperText('Available placeholders: {name}, {email}, {student_id}')
                            ->columnSpanFull(),

                        Textarea::make('email_verification')
                            ->label('Email Verification')
                            ->rows(5)
                            ->placeholder('Hello {name},

Please verify your email address by clicking the link below:

{verification_link}

This link will expire in 24 hours.

If you did not request this verification, please ignore this email.')
                            ->helperText('Available placeholders: {name}, {verification_link}')
                            ->columnSpanFull(),

                        Textarea::make('password_reset')
                            ->label('Password Reset')
                            ->rows(5)
                            ->placeholder('Hello {name},

You requested to reset your password. Click the link below to create a new password:

{reset_link}

This link will expire in 1 hour.

If you did not request a password reset, please ignore this email.')
                            ->helperText('Available placeholders: {name}, {reset_link}')
                            ->columnSpanFull(),

                        Textarea::make('election_announcement')
                            ->label('Election Announcement')
                            ->rows(5)
                            ->placeholder('Hello {name},

A new election "{election_title}" is now open!

Election Date: {election_date}

Please log in to cast your vote. Your participation is important!

Best regards,
Election Committee')
                            ->helperText('Available placeholders: {election_title}, {election_date}, {name}')
                            ->columnSpanFull(),

                        Textarea::make('upcoming_election_reminder')
                            ->label('Upcoming Election Reminder')
                            ->rows(5)
                            ->placeholder('Hello {name},

This is a reminder that the election "{election_title}" is coming up soon.

Election Date: {election_date}

Don\'t forget to cast your vote!

Best regards,
Election Committee')
                            ->helperText('Available placeholders: {election_title}, {election_date}, {name}')
                            ->columnSpanFull(),

                        Textarea::make('thank_you_for_voting')
                            ->label('Thank You for Voting')
                            ->rows(5)
                            ->placeholder('Hello {name},

Thank you for participating in the "{election_title}" election!

Your vote has been recorded successfully. We appreciate your participation in the democratic process.

Best regards,
Election Committee')
                            ->helperText('Available placeholders: {name}, {election_title}')
                            ->columnSpanFull(),

                        Textarea::make('result_announcement_email')
                            ->label('Result Announcement Email')
                            ->rows(5)
                            ->placeholder('Hello {name},

The results for "{election_title}" are now available!

View the results here: {results_link}

Thank you for your participation in this election.

Best regards,
Election Committee')
                            ->helperText('Available placeholders: {name}, {election_title}, {results_link}')
                            ->columnSpanFull(),
                    ])
                    ->icon('heroicon-o-document-text')
                    ->collapsible()
                    ->collapsed(true),
            ]);
    }
}
