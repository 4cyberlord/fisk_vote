<?php

namespace App\Filament\Resources\Users\Schemas;

use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class UserInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Personal Information')
                    ->schema([
                        TextEntry::make('first_name')
                            ->label('First Name'),

                        TextEntry::make('last_name')
                            ->label('Last Name'),

                        TextEntry::make('middle_initial')
                            ->label('Middle Initial')
                            ->placeholder('-'),
                    ])
                    ->columns(3),

                Section::make('Student Information')
                    ->schema([
                        TextEntry::make('student_id')
                            ->label('Student ID')
                            ->weight('bold'),

                        TextEntry::make('university_email')
                            ->label('University Email')
                            ->copyable(),

                        TextEntry::make('personal_email')
                            ->label('Personal Email')
                            ->placeholder('-')
                            ->copyable(),
                    ])
                    ->columns(3),

                Section::make('Academic Information')
                    ->schema([
                        TextEntry::make('department')
                            ->label('Department')
                            ->placeholder('-'),

                        TextEntry::make('major')
                            ->label('Major'),

                        TextEntry::make('class_level')
                            ->label('Class Level')
                            ->badge()
                            ->color(fn (string $state): string => match ($state) {
                                'Freshman' => 'info',
                                'Sophomore' => 'success',
                                'Junior' => 'warning',
                                'Senior' => 'danger',
                                default => 'gray',
                            }),
                    ])
                    ->columns(3),

                Section::make('Status Information')
                    ->schema([
                        TextEntry::make('enrollment_status')
                            ->label('Enrollment Status')
                            ->badge()
                            ->color(fn (string $state): string => match ($state) {
                                'Active' => 'success',
                                'Suspended' => 'danger',
                                'Graduated' => 'gray',
                                default => 'gray',
                            }),

                        TextEntry::make('student_type')
                            ->label('Student Type')
                            ->badge()
                            ->color('primary'),

                        TextEntry::make('citizenship_status')
                            ->label('Citizenship Status')
                            ->placeholder('-'),
                    ])
                    ->columns(3),

                Section::make('Account Information')
                    ->schema([
                        TextEntry::make('temporary_password')
                            ->label('Temporary Password')
                            ->formatStateUsing(function ($state) {
                                if (empty($state)) {
                                    return '-';
                                }
                                try {
                                    return \Illuminate\Support\Facades\Crypt::decryptString($state);
                                } catch (\Exception $e) {
                                    // If decryption fails, return the state as-is (might be plain text from old records)
                                    return $state;
                                }
                            })
                            ->copyable(),

                        TextEntry::make('email_verified_at')
                            ->label('Email Verified At')
                            ->dateTime()
                            ->placeholder('Not verified'),

                        TextEntry::make('created_at')
                            ->label('Created At')
                            ->dateTime(),

                        TextEntry::make('updated_at')
                            ->label('Updated At')
                            ->dateTime(),
                    ])
                    ->columns(2)
                    ->collapsible(),
            ]);
    }
}
