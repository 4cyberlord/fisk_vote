<?php

namespace App\Filament\Resources\Elections\Schemas;

use Filament\Infolists\Components\IconEntry;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class ElectionInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Basic Information')
                    ->schema([
                        TextEntry::make('title')
                            ->label('Election Title')
                            ->weight('bold'),

                TextEntry::make('description')
                            ->label('Description')
                            ->placeholder('No description provided')
                    ->columnSpanFull(),

                TextEntry::make('type')
                            ->label('Election Type')
                            ->badge()
                            ->color(fn (string $state): string => match ($state) {
                                'single' => 'primary',
                                'multiple' => 'info',
                                'referendum' => 'success',
                                'ranked' => 'warning',
                                'poll' => 'gray',
                                default => 'gray',
                            }),

                        TextEntry::make('status')
                            ->label('Status')
                            ->badge()
                            ->color(fn (string $state): string => match ($state) {
                                'draft' => 'gray',
                                'active' => 'success',
                                'closed' => 'danger',
                                'archived' => 'warning',
                                default => 'gray',
                            }),
                    ])
                    ->columns(2),

                Section::make('Advanced Settings')
                    ->schema([
                TextEntry::make('max_selection')
                            ->label('Max Selections')
                            ->placeholder('-')
                            ->visible(fn ($record) => $record && $record->type === 'multiple'),

                TextEntry::make('ranking_levels')
                            ->label('Ranking Levels')
                            ->placeholder('-')
                            ->visible(fn ($record) => $record && $record->type === 'ranked'),

                IconEntry::make('allow_write_in')
                            ->label('Allow Write-In')
                    ->boolean(),

                IconEntry::make('allow_abstain')
                            ->label('Allow Abstention')
                    ->boolean(),
                    ])
                    ->columns(4)
                    ->collapsible(),

                Section::make('Eligibility Settings')
                    ->schema([
                IconEntry::make('is_universal')
                            ->label('Universal Eligibility')
                    ->boolean(),

                        TextEntry::make('eligible_groups')
                            ->label('Eligible Groups')
                            ->formatStateUsing(function ($state) {
                                if (empty($state) || !is_array($state)) {
                                    return 'No specific eligibility groups set';
                                }
                                $groups = [];
                                if (!empty($state['departments'])) {
                                    $groups[] = 'Departments: ' . implode(', ', $state['departments']);
                                }
                                if (!empty($state['class_levels'])) {
                                    $groups[] = 'Class Levels: ' . implode(', ', $state['class_levels']);
                                }
                                if (!empty($state['organizations'])) {
                                    $groups[] = 'Organizations: ' . implode(', ', $state['organizations']);
                                }
                                if (!empty($state['manual'])) {
                                    $groups[] = 'Manual IDs: ' . implode(', ', $state['manual']);
                                }
                                return !empty($groups) ? implode(' | ', $groups) : 'No specific eligibility groups set';
                            })
                            ->visible(fn ($record) => $record && !$record->is_universal)
                            ->columnSpanFull(),
                    ])
                    ->collapsible(),

                Section::make('Timeline')
                    ->schema([
                TextEntry::make('start_time')
                            ->label('Start Time')
                    ->dateTime(),

                TextEntry::make('end_time')
                            ->label('End Time')
                    ->dateTime(),
                    ])
                    ->columns(2),

                Section::make('Metadata')
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
