<?php

namespace App\Filament\Resources\ApplicationSettings\Schemas;

use Filament\Infolists\Components\ImageEntry;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class ApplicationSettingInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Basic Information')
                    ->schema([
                        TextEntry::make('system_name')
                            ->label('System Name')
                            ->weight('bold')
                            ->size('lg')
                            ->columnSpan(2),

                        TextEntry::make('system_short_name')
                            ->label('Short Name')
                            ->badge()
                            ->color('info')
                            ->columnSpan(1),

                        TextEntry::make('university_name')
                            ->label('University')
                            ->weight('bold')
                            ->columnSpan(1),

                        TextEntry::make('system_description')
                            ->label('Description')
                            ->placeholder('No description')
                            ->columnSpanFull(),
                    ])
                    ->columns(3)
                    ->collapsible(),

                Section::make('Contact Information')
                    ->schema([
                        TextEntry::make('voting_platform_contact_email')
                            ->label('Platform Email')
                            ->icon('heroicon-o-envelope')
                            ->copyable()
                            ->columnSpan(1),

                        TextEntry::make('voting_support_email')
                            ->label('Support Email')
                            ->icon('heroicon-o-envelope')
                            ->copyable()
                            ->columnSpan(1),

                        TextEntry::make('support_phone_number')
                            ->label('Support Phone')
                            ->icon('heroicon-o-phone')
                            ->copyable()
                            ->columnSpan(1),
                    ])
                    ->columns(3)
                    ->collapsible(),

                Section::make('Branding & Appearance')
                    ->schema([
                        ImageEntry::make('university_logo_url')
                            ->label('University Logo')
                            ->columnSpan(1),

                        ImageEntry::make('secondary_logo_url')
                            ->label('Secondary Logo')
                            ->columnSpan(1),

                        ImageEntry::make('login_page_background_image_url')
                            ->label('Login Background')
                            ->columnSpan(1),

                        TextEntry::make('primary_color')
                            ->label('Primary Color')
                            ->badge()
                            ->color('primary')
                            ->columnSpan(1),

                        TextEntry::make('secondary_color')
                            ->label('Secondary Color')
                            ->badge()
                            ->color('secondary')
                            ->columnSpan(1),

                        TextEntry::make('dashboard_theme')
                            ->label('Theme')
                            ->badge()
                            ->color(fn (string $state): string => match ($state) {
                                'light' => 'gray',
                                'dark' => 'dark',
                                'auto' => 'info',
                                default => 'gray',
                            })
                            ->columnSpan(1),
                    ])
                    ->columns(3)
                    ->collapsible(),

                Section::make('Localization & Time')
                    ->schema([
                        TextEntry::make('default_timezone')
                            ->label('Timezone')
                            ->icon('heroicon-o-clock')
                            ->columnSpan(1),

                        TextEntry::make('date_format')
                            ->label('Date Format')
                            ->icon('heroicon-o-calendar')
                            ->columnSpan(1),

                        TextEntry::make('time_format')
                            ->label('Time Format')
                            ->icon('heroicon-o-clock')
                            ->columnSpan(1),

                        TextEntry::make('default_language')
                            ->label('Default Language')
                            ->badge()
                            ->color('info')
                            ->icon('heroicon-o-language')
                            ->columnSpan(1),

                        TextEntry::make('additional_languages')
                            ->label('Additional Languages')
                            ->formatStateUsing(fn ($state) => is_array($state) && !empty($state) ? implode(', ', $state) : 'None')
                            ->badge()
                            ->color('gray')
                            ->columnSpan(2),
                    ])
                    ->columns(3)
                    ->collapsible(),

                Section::make('Metadata')
                    ->schema([
                        TextEntry::make('created_at')
                            ->label('Created')
                            ->dateTime()
                            ->columnSpan(1),

                        TextEntry::make('updated_at')
                            ->label('Updated')
                            ->dateTime()
                            ->columnSpan(2),
                    ])
                    ->columns(3)
                    ->collapsible()
                    ->collapsed(),
            ]);
    }
}
