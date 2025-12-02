<?php

namespace App\Filament\Student\Pages;

use App\Models\Election;
use Filament\Infolists\Components\TextEntry;
use Filament\Infolists\Concerns\InteractsWithInfolists;
use Filament\Infolists\Contracts\HasInfolists;
use Filament\Pages\Page;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Components\View;
use Filament\Schemas\Concerns\InteractsWithSchemas;
use Filament\Schemas\Contracts\HasSchemas;
use Filament\Schemas\Schema;
use Illuminate\Contracts\Support\Htmlable;

class ElectionDetails extends Page implements HasInfolists, HasSchemas
{
    use InteractsWithInfolists;
    use InteractsWithSchemas;

    public Election $election;

    protected string $view = 'filament.student.pages.election-details';

    protected static bool $shouldRegisterNavigation = false;

    protected static ?string $slug = 'elections/{election}';

    public static function getUrl(array $parameters = [], bool $isAbsolute = true, ?string $panel = null, ?\Illuminate\Database\Eloquent\Model $tenant = null): string
    {
        if (isset($parameters['election']) && $parameters['election'] instanceof Election) {
            $parameters['election'] = $parameters['election']->id;
        }
        return parent::getUrl($parameters, $isAbsolute, $panel, $tenant);
    }

    public function mount(int|Election $election): void
    {
        if ($election instanceof Election) {
            $this->election = $election->load([
                'positions.candidates.user',
                'positions.candidates' => function ($query) {
                    $query->where('approved', true);
                },
                'candidates' => function ($query) {
                    $query->where('approved', true)->with(['user', 'position']);
                }
            ]);
        } else {
            $this->election = Election::with([
                'positions.candidates.user',
                'positions.candidates' => function ($query) {
                    $query->where('approved', true);
                },
                'candidates' => function ($query) {
                    $query->where('approved', true)->with(['user', 'position']);
                }
            ])->findOrFail($election);
        }

        // Check eligibility
        if (!$this->election->isEligibleForUser(auth()->user())) {
            abort(403, 'You are not eligible to participate in this election.');
        }
    }

    public function getTitle(): string | Htmlable
    {
        return $this->election->title;
    }

    public function getHeading(): string | Htmlable
    {
        return $this->election->title;
    }

    public function getSubheading(): string | Htmlable | null
    {
        return 'Election details and information';
    }

    public function schema(Schema $schema): Schema
    {
        $user = auth()->user();
        $hasVoted = $this->election->hasUserVoted($user);
        $isOpen = $this->election->current_status === 'Open';

        // Get vote record if exists
        $vote = null;
        if ($hasVoted) {
            $vote = \App\Models\Vote::where('election_id', $this->election->id)
                ->where('voter_id', $user->id)
                ->first();
        }

        return $schema
            ->record($this->election)
            ->components([
                Section::make('Election Information')
                    ->schema([
                        TextEntry::make('title')
                            ->label('Election Title')
                            ->size('lg')
                            ->weight('bold')
                            ->columnSpanFull(),

                        TextEntry::make('description')
                            ->label('Description')
                            ->html()
                            ->formatStateUsing(fn (?string $state): string => $state ?: '-')
                            ->placeholder('No description provided')
                            ->columnSpanFull(),

                        TextEntry::make('type')
                            ->label('Election Type')
                            ->formatStateUsing(fn (string $state): string => ucfirst($state))
                            ->badge()
                            ->color('info'),

                        TextEntry::make('voting_window')
                            ->label('Voting Window')
                            ->formatStateUsing(function () {
                                $start = $this->election->start_time->format('F j, Y \a\t g:i A');
                                $end = $this->election->end_time->format('F j, Y \a\t g:i A');
                                return "{$start} to {$end}";
                            })
                            ->columnSpanFull(),

                        TextEntry::make('start_time')
                            ->label('Start Time')
                            ->dateTime('F j, Y \a\t g:i A')
                            ->icon('heroicon-o-calendar')
                            ->color('info'),

                        TextEntry::make('end_time')
                            ->label('End Time')
                            ->dateTime('F j, Y \a\t g:i A')
                            ->icon('heroicon-o-calendar')
                            ->color('info'),

                        TextEntry::make('current_status')
                            ->label('Current Status')
                            ->formatStateUsing(fn (): string => $this->election->current_status)
                            ->badge()
                            ->color(fn (): string => match($this->election->current_status) {
                                'Open' => 'success',
                                'Upcoming' => 'info',
                                'Closed' => 'gray',
                                default => 'gray',
                            }),

                        TextEntry::make('status')
                            ->label('Election Status')
                            ->formatStateUsing(fn (string $state): string => ucfirst($state))
                            ->badge()
                            ->color(fn (string $state): string => match($state) {
                                'draft' => 'gray',
                                'active' => 'success',
                                'closed' => 'danger',
                                'archived' => 'warning',
                                default => 'gray',
                            }),

                        TextEntry::make('your_vote_status')
                            ->label('Your Vote Status')
                            ->formatStateUsing(function () use ($hasVoted, $vote): string {
                                if ($hasVoted && $vote && $vote->voted_at) {
                                    return 'Voted on ' . $vote->voted_at->format('M d, Y \a\t g:i A');
                                }
                                if ($hasVoted) {
                                    return 'Voted';
                                }
                                return '--';
                            })
                            ->badge()
                            ->color(function () use ($hasVoted): string {
                                if ($hasVoted) {
                                    return 'success';
                                }
                                return 'danger';
                            })
                            ->placeholder('--')
                            ->default('--'),
                    ])
                    ->columns(2),

                Section::make('Election Settings')
                    ->schema([
                        TextEntry::make('max_selection')
                            ->label('Maximum Selections')
                            ->formatStateUsing(fn (?int $state): string => $state ? (string)$state . ' candidate(s)' : '-')
                            ->visible(fn (): bool => $this->election->type === 'multiple')
                            ->helperText('Maximum number of candidates you can select'),

                        TextEntry::make('ranking_levels')
                            ->label('Ranking Levels')
                            ->formatStateUsing(fn (?int $state): string => $state ? (string)$state . ' level(s)' : '-')
                            ->visible(fn (): bool => $this->election->type === 'ranked')
                            ->helperText('Number of ranking levels allowed'),

                        TextEntry::make('allow_write_in')
                            ->label('Write-In Candidates Allowed')
                            ->formatStateUsing(fn (bool $state): string => $state ? 'Yes' : 'No')
                            ->badge()
                            ->color(fn (bool $state): string => $state ? 'success' : 'gray')
                            ->helperText('Whether you can write in your own candidate'),

                        TextEntry::make('allow_abstain')
                            ->label('Abstain Option Available')
                            ->formatStateUsing(fn (bool $state): string => $state ? 'Yes' : 'No')
                            ->badge()
                            ->color(fn (bool $state): string => $state ? 'success' : 'gray')
                            ->helperText('Whether you can abstain from voting'),
                    ])
                    ->columns(2)
                    ->collapsible(),

                Section::make('Eligibility Information')
                    ->schema([
                        TextEntry::make('is_universal')
                            ->label('Universal Election')
                            ->formatStateUsing(fn (bool $state): string => $state ? 'Yes - All students eligible' : 'No - Limited eligibility')
                            ->badge()
                            ->color(fn (bool $state): string => $state ? 'success' : 'info'),

                        TextEntry::make('eligibility_details')
                            ->label('Eligibility Details')
                            ->formatStateUsing(function () {
                                if ($this->election->is_universal) {
                                    return 'All students are eligible to vote in this election.';
                                }

                                $groups = $this->election->eligible_groups ?? [];

                                if (empty($groups)) {
                                    return '-';
                                }

                                $eligibility = [];

                                if (!empty($groups['departments']) && is_array($groups['departments'])) {
                                    $deptList = implode(', ', $groups['departments']);
                                    $eligibility[] = "Departments: {$deptList}";
                                }

                                if (!empty($groups['class_levels']) && is_array($groups['class_levels'])) {
                                    $classList = implode(', ', $groups['class_levels']);
                                    $eligibility[] = "Class Levels: {$classList}";
                                }

                                if (!empty($groups['organizations']) && is_array($groups['organizations'])) {
                                    $orgNames = \App\Models\Organization::whereIn('id', $groups['organizations'])
                                        ->pluck('name')
                                        ->toArray();
                                    if (!empty($orgNames)) {
                                        $orgList = implode(', ', $orgNames);
                                        $eligibility[] = "Organizations: {$orgList}";
                                    }
                                }

                                if (!empty($groups['manual']) && is_array($groups['manual'])) {
                                    $eligibility[] = 'Manually selected students (' . count($groups['manual']) . ' student' . (count($groups['manual']) !== 1 ? 's' : '') . ')';
                                }

                                return !empty($eligibility) ? implode("\n", $eligibility) : '-';
                            })
                            ->columnSpanFull()
                            ->visible(fn (): bool => !$this->election->is_universal),
                    ])
                    ->collapsible(),

                Section::make('Candidates')
                    ->schema([
                        View::make('filament.student.components.candidates-list')
                            ->viewData([
                                'election' => $this->election,
                            ])
                            ->columnSpanFull(),
                    ])
                    ->collapsible(),
            ]);
    }

    protected function getHeaderActions(): array
    {
        $hasVoted = $this->election->hasUserVoted(auth()->user());
        $isOpen = $this->election->current_status === 'Open';

        return [
            \Filament\Actions\Action::make('vote')
                ->label($hasVoted ? 'View Ballot' : 'Cast Vote')
                ->icon('heroicon-o-check-circle')
                ->color($hasVoted ? 'gray' : 'success')
                ->disabled(!$isOpen && !$hasVoted)
                ->url(fn (): string => \App\Filament\Student\Pages\Ballot::getUrl(['election' => $this->election->id]))
                ->visible($isOpen || $hasVoted),
        ];
    }
}

