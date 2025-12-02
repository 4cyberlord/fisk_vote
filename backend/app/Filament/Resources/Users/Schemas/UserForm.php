<?php

namespace App\Filament\Resources\Users\Schemas;

use App\Models\Department;
use App\Models\Major;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class UserForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Personal Information')
                    ->schema([
                        TextInput::make('first_name')
                            ->label('First Name')
                            ->required()
                            ->maxLength(255),

                        TextInput::make('middle_initial')
                            ->label('Middle Initial')
                            ->maxLength(1)
                            ->placeholder('M'),

                        TextInput::make('last_name')
                            ->label('Last Name')
                            ->required()
                            ->maxLength(255),
                    ])
                    ->columns(3),

                Section::make('Student Information')
                    ->schema([
                        TextInput::make('student_id')
                            ->label('Student ID')
                            ->required()
                            ->unique(ignoreRecord: true)
                            ->rules(['regex:/^\d+$/'])
                            ->validationMessages([
                                'unique' => 'This Student ID is already taken. Each student must have a unique ID.',
                                'regex' => 'Student ID must contain only numbers.',
                            ])
                            ->helperText('Numbers only (leading zeros preserved). Must be unique.')
                            ->maxLength(255),

                        TextInput::make('university_email')
                            ->label('University Email')
                            ->email()
                            ->required()
                            ->unique(ignoreRecord: true)
                            ->helperText('Official university email address'),

                        TextInput::make('personal_email')
                            ->label('Personal Email')
                            ->email()
                            ->helperText('Optional personal email address'),
                    ])
                    ->columns(2),

                Section::make('Academic Information')
                    ->schema([
                        Select::make('department')
                            ->label('Department')
                            ->options(Department::query()->pluck('name', 'name'))
                            ->searchable()
                            ->preload()
                            ->createOptionForm([
                                TextInput::make('name')
                                    ->label('Department Name')
                                    ->required()
                                    ->unique('departments', 'name')
                                    ->maxLength(255),
                            ])
                            ->createOptionUsing(function (array $data): string {
                                $department = Department::create($data);
                                return $department->name;
                            })
                            ->helperText('Select a department or create a new one'),

                        Select::make('major')
                            ->label('Major')
                            ->options(Major::query()->pluck('name', 'name'))
                            ->required()
                            ->searchable()
                            ->preload()
                            ->createOptionForm([
                                TextInput::make('name')
                                    ->label('Major/Minor Name')
                                    ->required()
                                    ->unique('majors', 'name')
                                    ->maxLength(255),
                            ])
                            ->createOptionUsing(function (array $data): string {
                                $major = Major::create($data);
                                return $major->name;
                            })
                            ->helperText('Select a major/minor or create a new one'),

                        Select::make('class_level')
                            ->label('Class Level')
                            ->required()
                            ->options([
                                'Freshman' => 'Freshman',
                                'Sophomore' => 'Sophomore',
                                'Junior' => 'Junior',
                                'Senior' => 'Senior',
                            ])
                            ->native(false),
                    ])
                    ->columns(2),

                Section::make('Status Information')
                    ->schema([
                        Select::make('enrollment_status')
                            ->label('Enrollment Status')
                            ->required()
                            ->default('Active')
                            ->options([
                                'Active' => 'Active',
                                'Suspended' => 'Suspended',
                                'Graduated' => 'Graduated',
                            ])
                            ->native(false),

                        Select::make('student_type')
                            ->label('Student Type')
                            ->required()
                            ->options([
                                'Undergraduate' => 'Undergraduate',
                                'Graduate' => 'Graduate',
                                'Transfer' => 'Transfer',
                                'International' => 'International',
                            ])
                            ->native(false),

                        TextInput::make('citizenship_status')
                            ->label('Citizenship Status')
                            ->maxLength(255),
                    ])
                    ->columns(2),

                Section::make('Account Information')
                    ->schema([
                        TextInput::make('password')
                            ->label('Password')
                            ->password()
                            ->hidden()
                            ->dehydrated(false)
                            ->validatedWhenNotDehydrated(false)
                            ->default('Fisk123'),

                        TextInput::make('temporary_password')
                            ->label('Temporary Password')
                            ->hidden()
                            ->dehydrated(false)
                            ->validatedWhenNotDehydrated(false)
                            ->default('Fisk123'),
                    ])
                    ->columns(2)
                    ->hidden(),
            ]);
    }
}
