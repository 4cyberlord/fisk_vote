<?php

namespace App\Filament\Resources\ElectionCandidates\Schemas;

use App\Models\ElectionPosition;
use App\Models\User;
use Filament\Forms\Components\SpatieMediaLibraryFileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Components\Utilities\Get;
use Filament\Schemas\Schema;
use Illuminate\Contracts\Database\Eloquent\Builder;

class ElectionCandidateForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Candidate Selection')
                    ->description('Select the student who will be running as a candidate')
                    ->schema([
                        Select::make('user_id')
                            ->label('Candidate')
                            ->relationship(
                                'user',
                                'name',
                                modifyQueryUsing: fn (Builder $query) => $query
                                    ->whereHas('roles', function ($q) {
                                        $q->where('name', 'Student');
                                    })
                                    ->orderBy('name')
                                    ->limit(10000) // High limit to ensure all students are available
                            )
                            ->required()
                            ->searchable()
                            ->preload()
                            ->getSearchResultsUsing(fn (string $search): array => 
                                User::query()
                                    ->whereHas('roles', function ($q) {
                                        $q->where('name', 'Student');
                                    })
                                    ->where(function ($query) use ($search) {
                                        $query->where('name', 'like', "%{$search}%")
                                            ->orWhere('first_name', 'like', "%{$search}%")
                                            ->orWhere('last_name', 'like', "%{$search}%")
                                            ->orWhere('student_id', 'like', "%{$search}%")
                                            ->orWhere('email', 'like', "%{$search}%");
                                    })
                                    ->orderBy('name')
                                    ->limit(500)
                                    ->get()
                                    ->mapWithKeys(fn ($user) => [
                                        $user->id => "{$user->name} ({$user->student_id})"
                                    ])
                                    ->toArray()
                            )
                            ->getOptionLabelFromRecordUsing(fn ($record) => "{$record->name} ({$record->student_id})")
                            ->helperText('Search and select the student/user who is running as a candidate. Note: Each candidate can only run once per position per election.')
                            ->columnSpanFull(),
                    ]),

                Section::make('Election & Position')
                    ->description('Select which election and position this candidate is running for')
                    ->schema([
                        Select::make('election_id')
                            ->label('Election')
                            ->relationship('election', 'title')
                            ->required()
                            ->searchable()
                            ->preload()
                            ->live()
                            ->afterStateUpdated(fn (callable $set) => $set('position_id', null))
                            ->helperText('Select the election this candidate is participating in'),

                        Select::make('position_id')
                            ->label('Position')
                            ->options(fn (Get $get) => ElectionPosition::query()
                                ->where('election_id', $get('election_id'))
                                ->pluck('name', 'id'))
                            ->required()
                            ->searchable()
                            ->preload()
                            ->visible(fn (Get $get) => filled($get('election_id')))
                            ->helperText('Select the specific position this candidate is running for'),
                    ])
                    ->columns(2),

                Section::make('Candidate Profile')
                    ->description('Add profile information, photo, and campaign details')
                    ->schema([
                        SpatieMediaLibraryFileUpload::make('photo')
                            ->label('Candidate Photo')
                            ->collection('photo')
                            ->image()
                            ->conversion('thumb')
                            ->helperText('Upload a clear, front-facing candidate photo (JPG, PNG, or SVG). For best results, keep the file size under 1MB.')
                            ->columnSpanFull(),

                        TextInput::make('tagline')
                            ->label('Campaign Tagline')
                            ->maxLength(255)
                            ->placeholder('Enter a short, memorable tagline or slogan')
                            ->helperText('A brief tagline that represents the candidate\'s campaign')
                            ->columnSpanFull(),

                        Textarea::make('bio')
                            ->label('Biography / Campaign Statement')
                            ->rows(6)
                            ->placeholder('Enter the candidate\'s biography or campaign statement...')
                            ->helperText('A detailed biography or campaign statement from the candidate')
                            ->columnSpanFull(),
                    ]),

                Section::make('Approval & Status')
                    ->description('Manage the approval status of this candidate')
                    ->schema([
                        Toggle::make('approved')
                            ->label('Approve Candidate')
                            ->helperText('When approved, this candidate will appear in the election and be visible to voters')
                            ->default(false)
                            ->inline(false),
                    ])
                    ->collapsible(),
            ]);
    }
}
