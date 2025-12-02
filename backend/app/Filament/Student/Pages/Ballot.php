<?php

namespace App\Filament\Student\Pages;

use App\Models\Election;
use App\Models\ElectionCandidate;
use App\Models\ElectionPosition;
use App\Models\Vote;
use Filament\Actions\Action;
use Filament\Forms\Components\Checkbox;
use Filament\Forms\Components\Radio;
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\Select;
use Filament\Forms\Concerns\InteractsWithForms;
use Filament\Forms\Contracts\HasForms;
use Filament\Forms\Form;
use Filament\Notifications\Notification;
use Filament\Pages\Page;
use Illuminate\Contracts\Support\Htmlable;
use Illuminate\Support\Facades\DB;

class Ballot extends Page implements HasForms
{
    use InteractsWithForms;

    public Election $election;
    public array $ballotData = [];
    public bool $hasVoted = false;

    protected string $view = 'filament.student.pages.ballot';

    protected static bool $shouldRegisterNavigation = false;

    protected static ?string $slug = 'elections/{election}/ballot';

    public static function getUrl(array $parameters = [], bool $isAbsolute = true, ?string $panel = null, ?\Illuminate\Database\Eloquent\Model $tenant = null): string
    {
        if (isset($parameters['election']) && $parameters['election'] instanceof Election) {
            $parameters['election'] = $parameters['election']->id;
        }
        return parent::getUrl($parameters, $isAbsolute, $panel, $tenant);
    }

    public function mount(int|Election $election): void
    {
        $user = auth()->user();
        
        if ($election instanceof Election) {
            $this->election = $election->load([
                'positions.candidates' => function ($query) {
                    $query->where('approved', true)->with('user');
                }
            ]);
        } else {
            $this->election = Election::with([
                'positions.candidates' => function ($query) {
                    $query->where('approved', true)->with('user');
                }
            ])->findOrFail($election);
        }

        // Check eligibility
        if (!$this->election->isEligibleForUser($user)) {
            abort(403, 'You are not eligible to participate in this election.');
        }

        // Check if election is open
        if ($this->election->current_status !== 'Open') {
            Notification::make()
                ->title('Election Not Open')
                ->body('This election is not currently open for voting.')
                ->warning()
                ->send();
            
            redirect(\App\Filament\Student\Pages\ElectionDetails::getUrl(['election' => $this->election->id]));
            return;
        }

        // Check if user has already voted
        $this->hasVoted = $this->election->hasUserVoted($user);

        if ($this->hasVoted) {
            // Load existing vote data for viewing
            $existingVote = Vote::where('election_id', $this->election->id)
                ->where('voter_id', $user->id)
                ->first();
            
            if ($existingVote) {
                $this->ballotData = $existingVote->vote_data ?? [];
            }
        } else {
            // Initialize empty ballot data
            foreach ($this->election->positions as $position) {
                $this->ballotData["position_{$position->id}"] = null;
            }
        }

        $this->form->fill($this->ballotData);
    }

    public function form(Form $form): Form
    {
        $schema = [];

        foreach ($this->election->positions as $position) {
            $candidates = $position->candidates->where('approved', true);
            $fieldKey = "position_{$position->id}";

            $positionSchema = match($position->type) {
                'single' => $this->getSingleChoiceField($position, $candidates, $fieldKey),
                'multiple' => $this->getMultipleChoiceField($position, $candidates, $fieldKey),
                'ranked' => $this->getRankedChoiceField($position, $candidates, $fieldKey),
                default => $this->getSingleChoiceField($position, $candidates, $fieldKey),
            };

            $schema[] = \Filament\Forms\Components\Section::make($position->name)
                ->description($position->description)
                ->schema([
                    $positionSchema,
                    ...($position->allow_abstain ? [
                        Checkbox::make("{$fieldKey}_abstain")
                            ->label('Abstain from this position')
                            ->helperText('Select this if you wish to abstain from voting for this position')
                            ->live()
                            ->afterStateUpdated(function ($state, $set, $get) use ($fieldKey) {
                                if ($state) {
                                    $set($fieldKey, null);
                                }
                            }),
                    ] : []),
                ])
                ->collapsible();
        }

        return $form
            ->schema($schema)
            ->statePath('ballotData')
            ->disabled($this->hasVoted);
    }

    protected function getSingleChoiceField(ElectionPosition $position, $candidates, string $fieldKey)
    {
        $options = [];
        foreach ($candidates as $candidate) {
            $options[$candidate->id] = $candidate->user->full_name;
        }

        return Radio::make($fieldKey)
            ->label('Select Candidate')
            ->options($options)
            ->descriptions(function () use ($candidates) {
                $descriptions = [];
                foreach ($candidates as $candidate) {
                    $desc = [];
                    if ($candidate->tagline) {
                        $desc[] = $candidate->tagline;
                    }
                    if ($candidate->bio) {
                        $desc[] = \Str::limit($candidate->bio, 100);
                    }
                    $descriptions[$candidate->id] = implode(' - ', $desc) ?: null;
                }
                return $descriptions;
            })
            ->required(!$position->allow_abstain)
            ->disabled($this->hasVoted)
            ->inline(false)
            ->columnSpanFull();
    }

    protected function getMultipleChoiceField(ElectionPosition $position, $candidates, string $fieldKey)
    {
        $options = [];
        foreach ($candidates as $candidate) {
            $options[$candidate->id] = $candidate->user->full_name;
        }

        return Checkbox::make($fieldKey)
            ->label('Select Candidates')
            ->options($options)
            ->descriptions(function () use ($candidates) {
                $descriptions = [];
                foreach ($candidates as $candidate) {
                    $desc = [];
                    if ($candidate->tagline) {
                        $desc[] = $candidate->tagline;
                    }
                    if ($candidate->bio) {
                        $desc[] = \Str::limit($candidate->bio, 100);
                    }
                    $descriptions[$candidate->id] = implode(' - ', $desc) ?: null;
                }
                return $descriptions;
            })
            ->required(!$position->allow_abstain)
            ->disabled($this->hasVoted)
            ->columns(2)
            ->helperText($position->max_selection 
                ? "You may select up to {$position->max_selection} candidate(s)."
                : 'You may select multiple candidates.')
            ->columnSpanFull();
    }

    protected function getRankedChoiceField(ElectionPosition $position, $candidates, string $fieldKey)
    {
        return Repeater::make($fieldKey)
            ->label('Rank Candidates')
            ->schema([
                Select::make('candidate_id')
                    ->label('Candidate')
                    ->options(function () use ($candidates) {
                        $options = [];
                        foreach ($candidates as $candidate) {
                            $options[$candidate->id] = $candidate->user->full_name;
                        }
                        return $options;
                    })
                    ->required()
                    ->disabled($this->hasVoted)
                    ->searchable(),
            ])
            ->defaultItems(0)
            ->reorderableWithButtons()
            ->addActionLabel('Add Candidate')
            ->disabled($this->hasVoted)
            ->helperText($position->ranking_levels 
                ? "Rank up to {$position->ranking_levels} candidates in order of preference."
                : 'Rank candidates in order of preference.')
            ->columnSpanFull();
    }

    public function getTitle(): string | Htmlable
    {
        return $this->hasVoted ? 'View Ballot' : 'Cast Your Vote';
    }

    public function getHeading(): string | Htmlable
    {
        return $this->hasVoted ? 'Your Ballot' : 'Cast Your Vote';
    }

    public function getSubheading(): string | Htmlable | null
    {
        return $this->hasVoted 
            ? 'This is your submitted ballot for ' . $this->election->title
            : 'Please review your selections carefully before submitting.';
    }

    public function submit(): void
    {
        if ($this->hasVoted) {
            Notification::make()
                ->title('Already Voted')
                ->body('You have already submitted your vote for this election.')
                ->warning()
                ->send();
            return;
        }

        $data = $this->form->getState();
        $user = auth()->user();

        // Validate ballot
        $this->validateBallot($data);

        // Save votes for each position
        DB::transaction(function () use ($data, $user) {
            foreach ($this->election->positions as $position) {
                $fieldKey = "position_{$position->id}";
                $abstainKey = "{$fieldKey}_abstain";

                // Skip if abstained
                if (!empty($data[$abstainKey])) {
                    continue;
                }

                $voteValue = $data[$fieldKey] ?? null;
                if ($voteValue === null) {
                    continue;
                }

                // Prepare vote data based on position type
                $voteData = match($position->type) {
                    'single' => ['candidate_id' => $voteValue],
                    'multiple' => ['candidate_ids' => is_array($voteValue) ? $voteValue : [$voteValue]],
                    'ranked' => ['rankings' => $voteValue],
                    default => ['candidate_id' => $voteValue],
                };

                Vote::create([
                    'election_id' => $this->election->id,
                    'position_id' => $position->id,
                    'voter_id' => $user->id,
                    'vote_data' => $voteData,
                    'voted_at' => now(),
                ]);
            }

            // Log vote submission to audit log
            $auditLogService = app(\App\Services\AuditLogService::class);
            $auditLogService->logVoteSubmission(
                $this->election->id,
                $user->id,
                'success'
            );
        });

        Notification::make()
            ->title('Vote Submitted')
            ->body('Your vote has been successfully submitted. Thank you for participating!')
            ->success()
            ->persistent()
            ->send();

        $this->hasVoted = true;
        redirect(\App\Filament\Student\Pages\ElectionDetails::getUrl(['election' => $this->election->id]));
    }

    protected function validateBallot(array $data): void
    {
        foreach ($this->election->positions as $position) {
            $fieldKey = "position_{$position->id}";
            $abstainKey = "{$fieldKey}_abstain";

            // If abstained, skip validation
            if (!empty($data[$abstainKey])) {
                continue;
            }

            $voteValue = $data[$fieldKey] ?? null;

            if ($voteValue === null && !$position->allow_abstain) {
                throw \Illuminate\Validation\ValidationException::withMessages([
                    $fieldKey => "You must select a candidate for {$position->name} or abstain.",
                ]);
            }

            // Validate multiple choice max selection
            if ($position->type === 'multiple' && $position->max_selection) {
                $selectedCount = is_array($voteValue) ? count($voteValue) : ($voteValue ? 1 : 0);
                if ($selectedCount > $position->max_selection) {
                    throw \Illuminate\Validation\ValidationException::withMessages([
                        $fieldKey => "You can only select up to {$position->max_selection} candidate(s) for {$position->name}.",
                    ]);
                }
            }

            // Validate ranked choice levels
            if ($position->type === 'ranked' && $position->ranking_levels) {
                $rankedCount = is_array($voteValue) ? count($voteValue) : 0;
                if ($rankedCount > $position->ranking_levels) {
                    throw \Illuminate\Validation\ValidationException::withMessages([
                        $fieldKey => "You can only rank up to {$position->ranking_levels} candidate(s) for {$position->name}.",
                    ]);
                }
            }
        }
    }

    protected function getHeaderActions(): array
    {
        return [
            Action::make('back')
                ->label('Back to Details')
                ->icon('heroicon-o-arrow-left')
                ->color('gray')
                ->url(fn (): string => \App\Filament\Student\Pages\ElectionDetails::getUrl(['election' => $this->election->id])),
            
            ...(!$this->hasVoted ? [
                Action::make('submit')
                    ->label('Submit Vote')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->requiresConfirmation()
                    ->modalHeading('Confirm Your Vote')
                    ->modalDescription('Are you sure you want to submit your vote? This action cannot be undone.')
                    ->modalSubmitActionLabel('Yes, Submit My Vote')
                    ->action('submit'),
            ] : []),
        ];
    }
}

