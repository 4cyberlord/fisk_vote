<?php

namespace App\Filament\Resources\ElectionPositions\Schemas;

use Filament\Infolists\Components\IconEntry;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class ElectionPositionInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Basic Information')
                    ->schema([
                        TextEntry::make('election.title')
                            ->label('Election')
                            ->weight('bold'),

                        TextEntry::make('name')
                            ->label('Position Name')
                            ->weight('bold')
                            ->size('lg'),

                        TextEntry::make('description')
                            ->label('Description')
                            ->placeholder('No description provided')
                            ->columnSpanFull(),
                    ])
                    ->columns(2),

                Section::make('Position Type Settings')
                    ->schema([
                        TextEntry::make('type')
                            ->label('Position Type')
                            ->badge()
                            ->color(fn (string $state): string => match ($state) {
                                'single' => 'primary',
                                'multiple' => 'info',
                                'ranked' => 'warning',
                                default => 'gray',
                            }),

                        TextEntry::make('max_selection')
                            ->label('Max Selections')
                            ->numeric()
                            ->placeholder('N/A')
                            ->visible(fn ($record) => $record->type === 'multiple'),

                        TextEntry::make('ranking_levels')
                            ->label('Ranking Levels')
                            ->numeric()
                            ->placeholder('N/A')
                            ->visible(fn ($record) => $record->type === 'ranked'),
                    ])
                    ->columns(3)
                    ->collapsible(),

                Section::make('Voting Options')
                    ->schema([
                        IconEntry::make('allow_abstain')
                            ->label('Allow Abstention')
                            ->boolean()
                            ->trueIcon('heroicon-o-check-circle')
                            ->falseIcon('heroicon-o-x-circle')
                            ->trueColor('success')
                            ->falseColor('gray'),
                    ])
                    ->collapsible(),

                Section::make('Timestamps')
                    ->schema([
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
