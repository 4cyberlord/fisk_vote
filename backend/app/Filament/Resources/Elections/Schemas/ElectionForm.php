<?php

namespace App\Filament\Resources\Elections\Schemas;

use App\Models\Department;
use App\Models\Organization;
use Filament\Forms\Components\CheckboxList;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TagsInput;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Components\Utilities\Get;
use Filament\Schemas\Schema;

class ElectionForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Basic Information')
                    ->schema([
                        TextInput::make('title')
                            ->label('Election Title')
                            ->required()
                            ->maxLength(255)
                            ->helperText('Enter a clear and descriptive title for this election'),

                        Textarea::make('description')
                            ->label('Description')
                            ->rows(4)
                            ->helperText('Optional description or instructions for voters'),
                    ])
                    ->columns(1),

                Section::make('Election Type')
                    ->schema([
                        Select::make('type')
                            ->label('Election Type')
                            ->required()
                            ->options([
                                'single' => 'Single Choice',
                                'multiple' => 'Multiple Choice',
                                'referendum' => 'Referendum',
                                'ranked' => 'Ranked Choice',
                                'poll' => 'Poll',
                            ])
                            ->native(false)
                            ->helperText('Select the type of election')
                            ->live()
                            ->afterStateUpdated(fn ($state, callable $set) => $set('max_selection', null)),
                    ]),

                Section::make('Advanced Type Settings')
                    ->schema([
                        TextInput::make('max_selection')
                            ->label('Max Selections')
                            ->numeric()
                            ->minValue(1)
                            ->visible(fn (Get $get) => in_array($get('type'), ['multiple']))
                            ->helperText('Maximum number of options voters can select')
                            ->required(fn (Get $get) => $get('type') === 'multiple'),

                        TextInput::make('ranking_levels')
                            ->label('Ranking Levels')
                            ->numeric()
                            ->minValue(1)
                            ->visible(fn (Get $get) => $get('type') === 'ranked')
                            ->helperText('Number of ranking levels for ranked-choice voting')
                            ->required(fn (Get $get) => $get('type') === 'ranked'),

                        Toggle::make('allow_write_in')
                            ->label('Allow Write-In Candidates')
                            ->helperText('Allow voters to write in their own candidates')
                            ->default(false),
                    ])
                    ->columns(3)
                    ->collapsible(),

                Section::make('Abstain Settings')
                    ->schema([
                        Toggle::make('allow_abstain')
                            ->label('Allow Abstention')
                            ->helperText('If enabled, voters can intentionally abstain from voting')
                            ->default(false),
                    ])
                    ->collapsible(),

                Section::make('Eligibility Settings')
                    ->schema([
                        Toggle::make('is_universal')
                            ->label('Universal Eligibility')
                            ->helperText('If enabled, all students are eligible to vote')
                            ->default(false)
                            ->live()
                            ->afterStateUpdated(fn ($state, callable $set) => $state ? $set('eligible_groups', null) : null),

                        Section::make('Eligible Groups')
                            ->schema([
                                CheckboxList::make('eligible_groups.departments')
                                    ->label('Departments')
                                    ->options(Department::query()->pluck('name', 'name'))
                                    ->searchable()
                                    ->gridDirection('row')
                                    ->columns(3)
                                    ->visible(fn (Get $get) => !$get('is_universal'))
                                    ->helperText('Select departments that are eligible to vote'),

                                CheckboxList::make('eligible_groups.class_levels')
                                    ->label('Class Levels')
                                    ->options([
                                        'Freshman' => 'Freshman',
                                        'Sophomore' => 'Sophomore',
                                        'Junior' => 'Junior',
                                        'Senior' => 'Senior',
                                    ])
                                    ->gridDirection('row')
                                    ->columns(4)
                                    ->visible(fn (Get $get) => !$get('is_universal'))
                                    ->helperText('Select class levels that are eligible to vote'),

                                CheckboxList::make('eligible_groups.organizations')
                                    ->label('Organizations')
                                    ->options(Organization::query()->pluck('name', 'name'))
                                    ->searchable()
                                    ->gridDirection('row')
                                    ->columns(3)
                                    ->visible(fn (Get $get) => !$get('is_universal'))
                                    ->helperText('Select organizations whose members are eligible to vote'),

                                TagsInput::make('eligible_groups.manual')
                                    ->label('Manual Student IDs')
                                    ->placeholder('Enter Student ID and press Enter')
                                    ->visible(fn (Get $get) => !$get('is_universal'))
                                    ->helperText('Manually add specific student IDs (one per line)'),
                            ])
                            ->visible(fn (Get $get) => !$get('is_universal'))
                            ->collapsible(),
                    ])
                    ->collapsible(),

                Section::make('Timeline')
                    ->schema([
                        DateTimePicker::make('start_time')
                            ->label('Start Time')
                            ->required()
                            ->displayFormat('M d, Y g:i A')
                            ->timezone(config('app.timezone', 'America/Chicago'))
                            ->helperText('When the election voting period begins'),

                        DateTimePicker::make('end_time')
                            ->label('End Time')
                            ->required()
                            ->displayFormat('M d, Y g:i A')
                            ->timezone(config('app.timezone', 'America/Chicago'))
                            ->helperText('When the election voting period ends')
                            ->after('start_time'),
                    ])
                    ->columns(2),

                Section::make('Status')
                    ->schema([
                        Select::make('status')
                            ->label('Election Status')
                            ->required()
                            ->default('draft')
                            ->options([
                                'draft' => 'Draft',
                                'active' => 'Active',
                                'closed' => 'Closed',
                                'archived' => 'Archived',
                            ])
                            ->native(false)
                            ->helperText('Current status of the election'),
                    ]),
            ]);
    }
}
