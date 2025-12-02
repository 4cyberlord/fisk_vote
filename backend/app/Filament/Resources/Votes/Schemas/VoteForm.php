<?php

namespace App\Filament\Resources\Votes\Schemas;

use App\Models\ElectionCandidate;
use App\Models\ElectionPosition;
use Filament\Forms\Components\CheckboxList;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Radio;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Components\Utilities\Get;
use Filament\Schemas\Schema;

class VoteForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Election & Position')
                    ->description('Select the election and position this vote is for')
                    ->schema([
                        Select::make('election_id')
                            ->label('Election')
                            ->relationship('election', 'title')
                            ->required()
                            ->searchable()
                            ->preload()
                            ->live()
                            ->afterStateUpdated(fn (callable $set) => $set('position_id', null)),

                        Select::make('position_id')
                            ->label('Position')
                            ->options(fn (Get $get) => ElectionPosition::query()
                                ->where('election_id', $get('election_id'))
                                ->pluck('name', 'id'))
                            ->required()
                            ->searchable()
                            ->preload()
                            ->live()
                            ->afterStateUpdated(fn (callable $set) => $set('vote_data', null))
                            ->visible(fn (Get $get) => filled($get('election_id'))),
                    ])
                    ->columns(2),

                Section::make('Voter Information')
                    ->description('The voter who cast this vote (defaults to currently logged-in user). Note: Each voter can only vote once per election.')
                    ->schema([
                        Select::make('voter_id')
                            ->label('Voter')
                            ->relationship('voter', 'name')
                            ->required()
                            ->searchable()
                            ->preload()
                            ->default(fn () => auth()->id())
                            ->getOptionLabelFromRecordUsing(fn ($record) => "{$record->name} ({$record->student_id})")
                            ->helperText(function (Get $get) {
                                $electionId = $get('election_id');
                                $voterId = $get('voter_id');
                                
                                if ($electionId && $voterId) {
                                    $hasVoted = \App\Models\Vote::where('election_id', $electionId)
                                        ->where('voter_id', $voterId)
                                        ->exists();
                                    
                                    if ($hasVoted) {
                                        return '⚠️ This voter has already cast a vote in this election. Each voter can only vote once per election.';
                                    }
                                }
                                
                                return 'Select the voter who cast this vote (defaults to currently logged-in user). Each voter can only vote once per election.';
                            })
                            ->live()
                            ->columnSpanFull(),
                    ]),

                // Single Choice Position
                Section::make('Cast Your Vote - Single Choice')
                    ->description('Select one candidate')
                    ->schema([
                        Radio::make('candidate_id')
                            ->label('Select Candidate')
                            ->options(function (Get $get) {
                                $positionId = $get('position_id');
                                if (!$positionId) {
                                    return [];
                                }

                                return ElectionCandidate::query()
                                    ->where('position_id', $positionId)
                                    ->where('approved', true)
                                    ->with('user')
                                    ->get()
                                    ->mapWithKeys(function ($candidate) {
                                        $label = $candidate->user->name;
                                        if ($candidate->tagline) {
                                            $label .= ' - ' . $candidate->tagline;
                                        }
                                        return [$candidate->id => $label];
                                    })
                                    ->toArray();
                            })
                            ->required(fn (Get $get) => self::isSingleChoicePosition($get))
                            ->visible(fn (Get $get) => self::isSingleChoicePosition($get))
                            ->helperText(fn (Get $get) => self::getAbstainHelperText($get))
                            ->columnSpanFull(),

                        Radio::make('abstain_single')
                            ->label('Abstain')
                            ->boolean()
                            ->default(false)
                            ->visible(fn (Get $get) => self::isSingleChoicePosition($get) && self::canAbstain($get))
                            ->helperText('Select this option to abstain from voting')
                            ->columnSpanFull(),
                    ])
                    ->visible(fn (Get $get) => self::isSingleChoicePosition($get)),

                // Multiple Choice Position
                Section::make('Cast Your Vote - Multiple Choice')
                    ->description(fn (Get $get) => self::getMultipleChoiceDescription($get))
                    ->schema([
                        CheckboxList::make('candidate_ids')
                            ->label('Select Candidates')
                            ->options(function (Get $get) {
                                $positionId = $get('position_id');
                                if (!$positionId) {
                                    return [];
                                }

                                return ElectionCandidate::query()
                                    ->where('position_id', $positionId)
                                    ->where('approved', true)
                                    ->with('user')
                                    ->get()
                                    ->mapWithKeys(function ($candidate) {
                                        $label = $candidate->user->name;
                                        if ($candidate->tagline) {
                                            $label .= ' - ' . $candidate->tagline;
                                        }
                                        return [$candidate->id => $label];
                                    })
                                    ->toArray();
                            })
                            ->required(fn (Get $get) => self::isMultipleChoicePosition($get))
                            ->visible(fn (Get $get) => self::isMultipleChoicePosition($get))
                            ->helperText(fn (Get $get) => self::getMultipleChoiceHelperText($get))
                            ->rules([
                                function (Get $get) {
                                    return function (string $attribute, $value, \Closure $fail) use ($get) {
                                        $positionId = $get('position_id');
                                        if (!$positionId) {
                                            return;
                                        }

                                        $position = ElectionPosition::find($positionId);
                                        if (!$position || $position->type !== 'multiple') {
                                            return;
                                        }

                                        $maxSelection = $position->max_selection;
                                        if ($maxSelection && is_array($value) && count($value) > $maxSelection) {
                                            $fail("You can only select up to {$maxSelection} candidate(s).");
                                        }
                                    };
                                },
                            ])
                            ->gridDirection('row')
                            ->columns(2)
                            ->columnSpanFull(),

                        Radio::make('abstain_multiple')
                            ->label('Abstain')
                            ->boolean()
                            ->default(false)
                            ->visible(fn (Get $get) => self::isMultipleChoicePosition($get) && self::canAbstain($get))
                            ->helperText('Select this option to abstain from voting')
                            ->columnSpanFull(),
                    ])
                    ->visible(fn (Get $get) => self::isMultipleChoicePosition($get)),

                // Ranked Choice Position
                Section::make('Cast Your Vote - Ranked Choice')
                    ->description(fn (Get $get) => self::getRankedChoiceDescription($get))
                    ->schema(function (Get $get) {
                        $positionId = $get('position_id');
                        if (!$positionId) {
                            return [];
                        }

                        $position = ElectionPosition::find($positionId);
                        if (!$position || $position->type !== 'ranked') {
                            return [];
                        }

                        $rankingLevels = $position->ranking_levels ?? 3;
                        $candidates = ElectionCandidate::query()
                            ->where('position_id', $positionId)
                            ->where('approved', true)
                            ->with('user')
                            ->get();

                        $candidateOptions = $candidates->mapWithKeys(function ($candidate) {
                            $label = $candidate->user->name;
                            if ($candidate->tagline) {
                                $label .= ' - ' . $candidate->tagline;
                            }
                            return [$candidate->id => $label];
                        })->toArray();

                        $fields = [];
                        for ($i = 1; $i <= $rankingLevels; $i++) {
                            $fields[] = Select::make("ranking_{$i}")
                                ->label("Rank #{$i}")
                                ->options($candidateOptions)
                                ->placeholder("Select candidate for rank #{$i}")
                                ->helperText("Choose your {$i}" . self::getOrdinalSuffix($i) . " choice")
                                ->columnSpanFull();
                        }

                        if (self::canAbstain($get)) {
                            $fields[] = Radio::make('abstain_ranked')
                                ->label('Abstain')
                                ->boolean()
                                ->default(false)
                                ->helperText('Select this option to abstain from voting')
                                ->columnSpanFull();
                        }

                        return $fields;
                    })
                    ->visible(fn (Get $get) => self::isRankedChoicePosition($get)),

                // Referendum Election
                Section::make('Cast Your Vote - Referendum')
                    ->description('Vote Yes or No on the referendum')
                    ->schema([
                        Radio::make('referendum_vote')
                            ->label('Your Vote')
                            ->options([
                                'yes' => 'Yes',
                                'no' => 'No',
                            ])
                            ->required(fn (Get $get) => self::isReferendumElection($get))
                            ->visible(fn (Get $get) => self::isReferendumElection($get))
                            ->helperText(fn (Get $get) => self::getReferendumHelperText($get))
                            ->columnSpanFull(),

                        Radio::make('abstain_referendum')
                            ->label('Abstain')
                            ->boolean()
                            ->default(false)
                            ->visible(fn (Get $get) => self::isReferendumElection($get) && self::canAbstainElection($get))
                            ->helperText('Select this option to abstain from voting')
                            ->columnSpanFull(),
                    ])
                    ->visible(fn (Get $get) => self::isReferendumElection($get)),

                // Hidden vote_data field that will be populated from the above fields
                TextInput::make('vote_data')
                    ->hidden()
                    ->dehydrated(false)
                    ->validatedWhenNotDehydrated(false),

                Section::make('Vote Metadata')
                    ->description('Vote timestamp information')
                    ->schema([
                        TextInput::make('token')
                            ->hidden()
                            ->dehydrated(false)
                            ->validatedWhenNotDehydrated(false),

                        DateTimePicker::make('voted_at')
                            ->label('Voted At')
                            ->helperText('Timestamp when the vote was cast (auto-set to current time if left empty)')
                            ->default(now())
                            ->required()
                            ->columnSpanFull(),
                    ])
                    ->collapsible(),
            ]);
    }

    /**
     * Check if position is single choice type
     */
    protected static function isSingleChoicePosition(Get $get): bool
    {
        $positionId = $get('position_id');
        if (!$positionId) {
            return false;
        }

        $position = ElectionPosition::find($positionId);
        return $position && $position->type === 'single';
    }

    /**
     * Check if position is multiple choice type
     */
    protected static function isMultipleChoicePosition(Get $get): bool
    {
        $positionId = $get('position_id');
        if (!$positionId) {
            return false;
        }

        $position = ElectionPosition::find($positionId);
        return $position && $position->type === 'multiple';
    }

    /**
     * Check if position is ranked choice type
     */
    protected static function isRankedChoicePosition(Get $get): bool
    {
        $positionId = $get('position_id');
        if (!$positionId) {
            return false;
        }

        $position = ElectionPosition::find($positionId);
        return $position && $position->type === 'ranked';
    }

    /**
     * Check if election is referendum type
     */
    protected static function isReferendumElection(Get $get): bool
    {
        $electionId = $get('election_id');
        if (!$electionId) {
            return false;
        }

        $election = \App\Models\Election::find($electionId);
        return $election && $election->type === 'referendum';
    }

    /**
     * Check if abstention is allowed for position
     */
    protected static function canAbstain(Get $get): bool
    {
        $positionId = $get('position_id');
        if (!$positionId) {
            return false;
        }

        $position = ElectionPosition::find($positionId);
        return $position && $position->allow_abstain;
    }

    /**
     * Check if abstention is allowed for election
     */
    protected static function canAbstainElection(Get $get): bool
    {
        $electionId = $get('election_id');
        if (!$electionId) {
            return false;
        }

        $election = \App\Models\Election::find($electionId);
        return $election && $election->allow_abstain;
    }

    /**
     * Get helper text for single choice with abstain option
     */
    protected static function getAbstainHelperText(Get $get): string
    {
        if (self::canAbstain($get)) {
            return 'Select one candidate or choose to abstain below.';
        }
        return 'Select one candidate.';
    }

    /**
     * Get description for multiple choice
     */
    protected static function getMultipleChoiceDescription(Get $get): string
    {
        $positionId = $get('position_id');
        if (!$positionId) {
            return 'Select multiple candidates';
        }

        $position = ElectionPosition::find($positionId);
        $max = $position->max_selection ?? 'multiple';
        return "Select up to {$max} candidate(s)";
    }

    /**
     * Get helper text for multiple choice
     */
    protected static function getMultipleChoiceHelperText(Get $get): string
    {
        $positionId = $get('position_id');
        if (!$positionId) {
            return 'Select one or more candidates.';
        }

        $position = ElectionPosition::find($positionId);
        $max = $position->max_selection ?? 'multiple';
        $text = "You can select up to {$max} candidate(s).";
        
        if (self::canAbstain($get)) {
            $text .= ' You can also choose to abstain below.';
        }
        
        return $text;
    }

    /**
     * Get description for ranked choice
     */
    protected static function getRankedChoiceDescription(Get $get): string
    {
        $positionId = $get('position_id');
        if (!$positionId) {
            return 'Rank candidates in order of preference';
        }

        $position = ElectionPosition::find($positionId);
        $levels = $position->ranking_levels ?? 3;
        return "Rank candidates in order of preference (1st, 2nd, 3rd, etc. up to {$levels} levels)";
    }

    /**
     * Get helper text for referendum
     */
    protected static function getReferendumHelperText(Get $get): string
    {
        if (self::canAbstainElection($get)) {
            return 'Vote Yes or No, or choose to abstain below.';
        }
        return 'Vote Yes or No on the referendum.';
    }

    /**
     * Get ordinal suffix (st, nd, rd, th)
     */
    protected static function getOrdinalSuffix(int $number): string
    {
        $ends = ['th', 'st', 'nd', 'rd', 'th', 'th', 'th', 'th', 'th', 'th'];
        if ((($number % 100) >= 11) && (($number % 100) <= 13)) {
            return 'th';
        }
        return $ends[$number % 10];
    }
}
