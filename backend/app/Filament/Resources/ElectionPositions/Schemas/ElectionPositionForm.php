<?php

namespace App\Filament\Resources\ElectionPositions\Schemas;

use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Components\Utilities\Get;
use Filament\Schemas\Schema;

class ElectionPositionForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Basic Information')
                    ->schema([
                        Select::make('election_id')
                            ->label('Election')
                            ->relationship('election', 'title')
                            ->required()
                            ->searchable()
                            ->preload()
                            ->helperText('Select the election this position belongs to'),

                        TextInput::make('name')
                            ->label('Position Name')
                            ->required()
                            ->maxLength(255)
                            ->helperText('Enter the name of the position (e.g., President, Vice President)'),

                        Textarea::make('description')
                            ->label('Description')
                            ->rows(3)
                            ->helperText('Optional description of the position'),
                    ])
                    ->columns(2),

                Section::make('Position Type Settings')
                    ->schema([
                        Select::make('type')
                            ->label('Position Type')
                            ->required()
                            ->default('single')
                            ->options([
                                'single' => 'Single Choice',
                                'multiple' => 'Multiple Choice',
                                'ranked' => 'Ranked Choice',
                            ])
                            ->native(false)
                            ->helperText('Select the voting type for this position')
                            ->live()
                            ->afterStateUpdated(fn ($state, callable $set) => $set('max_selection', null)),

                        TextInput::make('max_selection')
                            ->label('Max Selections')
                            ->numeric()
                            ->minValue(1)
                            ->visible(fn (Get $get) => $get('type') === 'multiple')
                            ->helperText('Maximum number of candidates voters can select')
                            ->required(fn (Get $get) => $get('type') === 'multiple'),

                        TextInput::make('ranking_levels')
                            ->label('Ranking Levels')
                            ->numeric()
                            ->minValue(1)
                            ->visible(fn (Get $get) => $get('type') === 'ranked')
                            ->helperText('Number of ranking levels for ranked-choice voting')
                            ->required(fn (Get $get) => $get('type') === 'ranked'),
                    ])
                    ->columns(3),

                Section::make('Voting Options')
                    ->schema([
                        Toggle::make('allow_abstain')
                            ->label('Allow Abstention')
                            ->helperText('If enabled, voters can intentionally abstain from voting for this position')
                            ->default(false),
                    ])
                    ->collapsible(),
            ]);
    }
}
