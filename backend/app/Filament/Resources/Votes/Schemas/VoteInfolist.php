<?php

namespace App\Filament\Resources\Votes\Schemas;

use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class VoteInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Election & Position')
                    ->schema([
                        TextEntry::make('election.title')
                            ->label('Election')
                            ->weight('bold'),

                        TextEntry::make('position.name')
                            ->label('Position')
                            ->weight('bold'),
                    ])
                    ->columns(2),

                Section::make('Voter Information')
                    ->schema([
                        TextEntry::make('voter.name')
                            ->label('Voter Name')
                            ->weight('bold')
                            ->size('lg'),

                        TextEntry::make('voter.student_id')
                            ->label('Student ID'),

                        TextEntry::make('voter.university_email')
                            ->label('University Email')
                            ->copyable(),
                    ])
                    ->columns(2),

                Section::make('Vote Data')
                    ->schema([
                        TextEntry::make('vote_data')
                            ->label('Vote Data')
                            ->formatStateUsing(fn ($state) => json_encode($state, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES))
                            ->copyable()
                            ->columnSpanFull(),
                    ]),

                Section::make('Vote Metadata')
                    ->schema([
                        TextEntry::make('token')
                            ->label('Vote Token')
                            ->copyable()
                            ->columnSpanFull(),

                        TextEntry::make('voted_at')
                            ->label('Voted At')
                            ->dateTime(),

                        TextEntry::make('created_at')
                            ->label('Created At')
                            ->dateTime(),

                        TextEntry::make('updated_at')
                            ->label('Updated At')
                            ->dateTime(),
                    ])
                    ->columns(3)
                    ->collapsible(),
            ]);
    }
}
