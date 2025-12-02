<?php

namespace App\Filament\Student\Pages;

use App\Models\Election;
use Filament\Actions\Action;
use Filament\Pages\Page;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Concerns\InteractsWithTable;
use Filament\Tables\Contracts\HasTable;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Contracts\Support\Htmlable;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class ActiveElections extends Page implements HasTable
{
    use InteractsWithTable;

    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-clipboard-document-check';

    protected static ?string $navigationLabel = 'Elections';

    protected static string|\UnitEnum|null $navigationGroup = null;

    protected static ?int $navigationSort = 2;

    protected static bool $shouldRegisterNavigation = true;

    protected string $view = 'filament.student.pages.active-elections';

    public function getTitle(): string | Htmlable
    {
        return 'Active Elections';
    }

    public function getHeading(): string | Htmlable
    {
        return 'Active Elections';
    }

    public function getSubheading(): string | Htmlable | null
    {
        return 'View and participate in elections you are eligible for';
    }

    public function table(Table $table): Table
    {
        $user = auth()->user();

        return $table
            ->query(
                Election::query()
                    ->where('status', '!=', 'draft')
                    ->where(function (Builder $query) use ($user) {
                        // Universal elections
                        $query->where('is_universal', true);

                        // Department-based eligibility
                        if ($user->department) {
                            $query->orWhereJsonContains('eligible_groups->departments', $user->department);
                        }

                        // Class level-based eligibility
                        if ($user->class_level) {
                            $query->orWhereJsonContains('eligible_groups->class_levels', $user->class_level);
                        }

                        // Manual user ID list
                        $query->orWhereJsonContains('eligible_groups->manual', $user->id);

                        // Organization-based eligibility (check if user belongs to any eligible org)
                        $userOrgIds = $user->organizations->pluck('id')->toArray();
                        if (!empty($userOrgIds)) {
                            foreach ($userOrgIds as $orgId) {
                                $query->orWhereJsonContains('eligible_groups->organizations', $orgId);
                            }
                        }
                    })
                    ->orderBy('start_time', 'desc')
            )
            ->columns([
                TextColumn::make('title')
                    ->label('Election Title')
                    ->searchable()
                    ->sortable()
                    ->weight('bold')
                    ->description(fn (Election $record): string => $record->description ? Str::limit($record->description, 100) : 'No description'),

                TextColumn::make('voting_window')
                    ->label('Voting Window')
                    ->state(function (Election $record) {
                        if (!$record->start_time || !$record->end_time) {
                            return 'Not set';
                        }

                        try {
                            $now = now();
                            $startTime = $record->start_time instanceof \Carbon\Carbon
                                ? $record->start_time
                                : \Carbon\Carbon::parse($record->start_time);
                            $endTime = $record->end_time instanceof \Carbon\Carbon
                                ? $record->end_time
                                : \Carbon\Carbon::parse($record->end_time);

                            // If election hasn't started yet
                            if ($now->lt($startTime)) {
                                $daysUntilStart = (int) $now->diffInDays($startTime);
                                $hoursUntilStart = (int) ($now->diffInHours($startTime) % 24);

                                if ($daysUntilStart > 0) {
                                    return "Starts in {$daysUntilStart} day" . ($daysUntilStart !== 1 ? 's' : '');
                                } else {
                                    return "Starts in {$hoursUntilStart} hour" . ($hoursUntilStart !== 1 ? 's' : '');
                                }
                            }

                            // If election has ended
                            if ($now->gt($endTime)) {
                                $daysSinceEnd = (int) $endTime->diffInDays($now);
                                $hoursSinceEnd = (int) $endTime->diffInHours($now);
                                $minutesSinceEnd = (int) $endTime->diffInMinutes($now);

                                if ($daysSinceEnd >= 1) {
                                    return "Ended {$daysSinceEnd} day" . ($daysSinceEnd !== 1 ? 's' : '') . " ago";
                                } else if ($hoursSinceEnd >= 1) {
                                    return "Ended {$hoursSinceEnd} hour" . ($hoursSinceEnd !== 1 ? 's' : '') . " ago";
                                } else if ($minutesSinceEnd >= 1) {
                                    return "Ended {$minutesSinceEnd} minute" . ($minutesSinceEnd !== 1 ? 's' : '') . " ago";
                                } else {
                                    return "Just ended";
                                }
                            }

                            // Election is currently active - calculate days remaining
                            $daysRemaining = (int) $now->diffInDays($endTime, false);
                            $hoursRemaining = (int) ($now->diffInHours($endTime, false) % 24);

                            if ($daysRemaining > 0) {
                                return "{$daysRemaining} day" . ($daysRemaining !== 1 ? 's' : '') . " remaining";
                            } else if ($hoursRemaining > 0) {
                                return "{$hoursRemaining} hour" . ($hoursRemaining !== 1 ? 's' : '') . " remaining";
                            } else {
                                return "Less than 1 hour remaining";
                            }
                        } catch (\Exception $e) {
                            Log::error('Voting window calculation error: ' . $e->getMessage(), [
                                'election_id' => $record->id,
                                'start_time' => $record->start_time,
                                'end_time' => $record->end_time,
                            ]);
                            return 'Invalid date';
                        }
                    })
                    ->badge()
                    ->color(function (Election $record) {
                        if (!$record->start_time || !$record->end_time) {
                            return 'gray';
                        }

                        try {
                            $now = now();
                            $startTime = $record->start_time instanceof \Carbon\Carbon
                                ? $record->start_time
                                : \Carbon\Carbon::parse($record->start_time);
                            $endTime = $record->end_time instanceof \Carbon\Carbon
                                ? $record->end_time
                                : \Carbon\Carbon::parse($record->end_time);

                            // Not started yet
                            if ($now->lt($startTime)) {
                                return 'info';
                            }

                            // Ended
                            if ($now->gt($endTime)) {
                                return 'gray';
                            }

                            // Active - color based on urgency
                            $daysRemaining = $now->diffInDays($endTime, false);
                            if ($daysRemaining <= 1) {
                                return 'danger'; // Less than 1 day - urgent
                            } else if ($daysRemaining <= 3) {
                                return 'warning'; // 2-3 days - warning
                            } else {
                                return 'success'; // More than 3 days - good
                            }
                        } catch (\Exception $e) {
                            return 'gray';
                        }
                    })
                    ->sortable(query: function (Builder $query, string $direction): Builder {
                        return $query->orderBy('end_time', $direction);
                    }),

                TextColumn::make('current_status')
                    ->label('Status')
                    ->badge()
                    ->formatStateUsing(fn (Election $record): string => $record->current_status)
                    ->color(fn (Election $record): string => match($record->current_status) {
                        'Open' => 'success',
                        'Upcoming' => 'info',
                        'Closed' => 'gray',
                        default => 'gray',
                    }),

                TextColumn::make('your_status')
                    ->label('Your Status')
                    ->state(function (Election $record) {
                        $user = auth()->user();
                        if (!$user) {
                            return 'Not logged in';
                        }

                        try {
                            return $record->hasUserVoted($user) ? 'Voted' : 'Not Voted';
                        } catch (\Exception $e) {
                            Log::error('Your status calculation error: ' . $e->getMessage(), [
                                'election_id' => $record->id,
                                'user_id' => $user->id,
                            ]);
                            return 'Error';
                        }
                    })
                    ->badge()
                    ->color(function (Election $record): string {
                        $user = auth()->user();
                        if (!$user) {
                            return 'gray';
                        }

                        try {
                            return $record->hasUserVoted($user) ? 'success' : 'warning';
                        } catch (\Exception $e) {
                            return 'gray';
                        }
                    }),

                TextColumn::make('positions_count')
                    ->label('Positions')
                    ->counts('positions')
                    ->badge()
                    ->color('info'),
            ])
            ->filters([
                SelectFilter::make('status')
                    ->label('Election Status')
                    ->options([
                        'Open' => 'Open',
                        'Upcoming' => 'Upcoming',
                        'Closed' => 'Closed',
                    ])
                    ->query(function (Builder $query, array $data): Builder {
                        $now = now();
                        return match($data['value'] ?? null) {
                            'Open' => $query->where('status', 'active')
                                ->where('start_time', '<=', $now)
                                ->where('end_time', '>=', $now),
                            'Upcoming' => $query->where('start_time', '>', $now),
                            'Closed' => $query->where(function (Builder $q) use ($now) {
                                $q->where('status', 'closed')
                                    ->orWhere('status', 'archived')
                                    ->orWhere('end_time', '<', $now);
                            }),
                            default => $query,
                        };
                    }),

                SelectFilter::make('voted')
                    ->label('Vote Status')
                    ->options([
                        'voted' => 'Voted',
                        'not_voted' => 'Not Voted',
                    ])
                    ->query(function (Builder $query, array $data): Builder {
                        $user = auth()->user();
                        if (!$user) {
                            return $query;
                        }

                        return match($data['value'] ?? null) {
                            'voted' => $query->whereHas('votes', function (Builder $q) use ($user) {
                                $q->where('voter_id', $user->id);
                            }),
                            'not_voted' => $query->whereDoesntHave('votes', function (Builder $q) use ($user) {
                                $q->where('voter_id', $user->id);
                            }),
                            default => $query,
                        };
                    }),
            ])
            ->actions([
                Action::make('view')
                    ->label('View Details')
                    ->icon('heroicon-o-eye')
                    ->color('primary')
                    ->url(fn (Election $record): string => \App\Filament\Student\Pages\ElectionDetails::getUrl(['election' => $record->id])),
            ])
            ->defaultSort('start_time', 'desc')
            ->emptyStateHeading('No elections available')
            ->emptyStateDescription('There are currently no elections you are eligible to participate in.')
            ->emptyStateIcon('heroicon-o-clipboard-document-check');
    }
}

