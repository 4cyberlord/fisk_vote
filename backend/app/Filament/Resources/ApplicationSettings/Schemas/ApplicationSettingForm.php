<?php

namespace App\Filament\Resources\ApplicationSettings\Schemas;

use Filament\Forms\Components\ColorPicker;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\TagsInput;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class ApplicationSettingForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                // Basic Information Section
                Section::make('Basic Information')
                    ->schema([
                        TextInput::make('system_name')
                            ->label('System Name')
                            ->required()
                            ->maxLength(255)
                            ->default('Fisk Voting System')
                            ->columnSpanFull(),

                        TextInput::make('system_short_name')
                            ->label('System Short Name')
                            ->required()
                            ->maxLength(50)
                            ->default('FVS')
                            ->columnSpan(1),

                        TextInput::make('university_name')
                            ->label('University Name')
                            ->required()
                            ->maxLength(255)
                            ->default('Fisk University')
                            ->columnSpan(1),

                        Textarea::make('system_description')
                            ->label('System Description')
                            ->rows(4)
                            ->columnSpanFull(),
                    ])
                    ->columns(2)
                    ->collapsible()
                    ->icon('heroicon-o-information-circle'),

                // Contact Information Section
                Section::make('Contact Information')
                    ->schema([
                        TextInput::make('voting_platform_contact_email')
                            ->label('Platform Contact Email')
                            ->email()
                            ->maxLength(255)
                            ->columnSpan(1),

                        TextInput::make('voting_support_email')
                            ->label('Support Email')
                            ->email()
                            ->maxLength(255)
                            ->columnSpan(1),

                        TextInput::make('support_phone_number')
                            ->label('Support Phone Number')
                            ->tel()
                            ->maxLength(50)
                            ->columnSpanFull(),
                    ])
                    ->columns(2)
                    ->collapsible()
                    ->icon('heroicon-o-envelope'),

                // Branding Section
                Section::make('Branding & Appearance')
                    ->schema([
                        FileUpload::make('university_logo_url')
                            ->label('University Logo')
                            ->image()
                            ->directory('settings/logos')
                            ->visibility('public')
                            ->imageEditor()
                            ->columnSpanFull(),

                        FileUpload::make('secondary_logo_url')
                            ->label('Secondary Logo')
                            ->image()
                            ->directory('settings/logos')
                            ->visibility('public')
                            ->imageEditor()
                            ->columnSpanFull(),

                        FileUpload::make('login_page_background_image_url')
                            ->label('Login Page Background Image')
                            ->image()
                            ->directory('settings/backgrounds')
                            ->visibility('public')
                            ->imageEditor()
                            ->columnSpanFull(),

                        ColorPicker::make('primary_color')
                            ->label('Primary Color')
                            ->default('#3B82F6')
                            ->columnSpan(1),

                        ColorPicker::make('secondary_color')
                            ->label('Secondary Color')
                            ->default('#8B5CF6')
                            ->columnSpan(1),

                        Select::make('dashboard_theme')
                            ->label('Dashboard Theme')
                            ->options([
                                'light' => 'Light',
                                'dark' => 'Dark',
                                'auto' => 'Auto (System Preference)',
                            ])
                            ->default('auto')
                            ->required()
                            ->native(false)
                            ->columnSpanFull(),
                    ])
                    ->columns(2)
                    ->collapsible()
                    ->icon('heroicon-o-paint-brush'),

                // Localization Section
                Section::make('Localization & Time Settings')
                    ->schema([
                        Select::make('default_timezone')
                            ->label('Default Timezone')
                            ->options([
                                'America/Chicago' => 'Central Time (America/Chicago)',
                                'America/New_York' => 'Eastern Time (America/New_York)',
                                'America/Denver' => 'Mountain Time (America/Denver)',
                                'America/Los_Angeles' => 'Pacific Time (America/Los_Angeles)',
                                'America/Phoenix' => 'Arizona Time (America/Phoenix)',
                                'America/Anchorage' => 'Alaska Time (America/Anchorage)',
                                'Pacific/Honolulu' => 'Hawaii Time (Pacific/Honolulu)',
                                'UTC' => 'UTC (Coordinated Universal Time)',
                            ])
                            ->default('America/Chicago')
                            ->required()
                            ->searchable()
                            ->columnSpanFull(),

                        Select::make('date_format')
                            ->label('Date Format')
                            ->options([
                                'MM/DD/YYYY' => 'MM/DD/YYYY',
                                'DD/MM/YYYY' => 'DD/MM/YYYY',
                                'YYYY-MM-DD' => 'YYYY-MM-DD',
                            ])
                            ->default('MM/DD/YYYY')
                            ->required()
                            ->native(false)
                            ->columnSpan(1),

                        Select::make('time_format')
                            ->label('Time Format')
                            ->options([
                                '12-hour' => '12-hour (e.g., 3:45 PM)',
                                '24-hour' => '24-hour (e.g., 15:45)',
                            ])
                            ->default('12-hour')
                            ->required()
                            ->native(false)
                            ->columnSpan(1),

                        TextInput::make('default_language')
                            ->label('Default Language Code')
                            ->default('en')
                            ->maxLength(10)
                            ->helperText('ISO language code (e.g., en, es, fr)')
                            ->columnSpanFull(),

                        TagsInput::make('additional_languages')
                            ->label('Additional Languages')
                            ->placeholder('Enter language codes (e.g., es, fr, de)')
                            ->helperText('Add additional supported languages. Press Enter after each code.')
                            ->columnSpanFull(),
                    ])
                    ->columns(2)
                    ->collapsible()
                    ->icon('heroicon-o-globe-alt'),
            ]);
    }
}
