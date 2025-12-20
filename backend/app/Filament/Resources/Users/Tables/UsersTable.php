<?php

namespace App\Filament\Resources\Users\Tables;

// use App\Services\VotingStatsService; // ARCHIVED
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
// use Illuminate\Support\Facades\DB; // ARCHIVED

class UsersTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('student_id')
                    ->label('Student ID')
                    ->searchable()
                    ->sortable()
                    ->weight('bold'),

                TextColumn::make('first_name')
                    ->label('First Name')
                    ->searchable()
                    ->sortable(),

                TextColumn::make('last_name')
                    ->label('Last Name')
                    ->searchable()
                    ->sortable(),

                TextColumn::make('university_email')
                    ->label('University Email')
                    ->searchable()
                    ->sortable()
                    ->copyable()
                    ->copyMessage('Email copied!'),

                TextColumn::make('major')
                    ->label('Major')
                    ->searchable()
                    ->sortable(),

                TextColumn::make('class_level')
                    ->label('Class Level')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'Freshman' => 'info',
                        'Sophomore' => 'success',
                        'Junior' => 'warning',
                        'Senior' => 'danger',
                        default => 'gray',
                    })
                    ->sortable(),

                TextColumn::make('enrollment_status')
                    ->label('Status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'Active' => 'success',
                        'Suspended' => 'danger',
                        'Graduated' => 'gray',
                        default => 'gray',
                    })
                    ->sortable(),

                TextColumn::make('student_type')
                    ->label('Type')
                    ->badge()
                    ->color('primary')
                    ->sortable(),

                // Voting Statistics Columns - ARCHIVED
                // TextColumn::make('elections_voted')
                //     ->label('Elections Voted')
                //     ->getStateUsing(function ($record) {
                //         return DB::table('votes')
                //             ->where('voter_id', $record->id)
                //             ->distinct('election_id')
                //             ->count('election_id');
                //     })
                //     ->numeric()
                //     ->badge()
                //     ->color('primary')
                //     ->sortable(query: function ($query, string $direction) {
                //         return $query->withCount(['votes as elections_voted_count' => function ($q) {
                //             $q->select(DB::raw('count(distinct election_id)'));
                //         }])->orderBy('elections_voted_count', $direction);
                //     })
                //     ->toggleable(),

                // TextColumn::make('campus_rank')
                //     ->label('Campus Rank')
                //     ->getStateUsing(function ($record) {
                //         $statsService = app(VotingStatsService::class);
                //         $stats = $statsService->calculateUserStats($record);
                //         return '#' . $stats['campus_rank'];
                //     })
                //     ->badge()
                //     ->color('warning')
                //     ->toggleable(),

                // TextColumn::make('percentile')
                //     ->label('Percentile')
                //     ->getStateUsing(function ($record) {
                //         $statsService = app(VotingStatsService::class);
                //         $stats = $statsService->calculateUserStats($record);
                //         return number_format($stats['percentile'], 1) . '%';
                //     })
                //     ->badge()
                //     ->color('success')
                //     ->toggleable(),

                // TextColumn::make('impact_score')
                //     ->label('Impact Score')
                //     ->getStateUsing(function ($record) {
                //         $statsService = app(VotingStatsService::class);
                //         $stats = $statsService->calculateUserStats($record);
                //         return $stats['impact_score'] . '/200';
                //     })
                //     ->badge()
                //     ->color('info')
                //     ->toggleable(),

                // TextColumn::make('last_vote_date')
                //     ->label('Last Vote')
                //     ->getStateUsing(function ($record) {
                //         $lastVote = DB::table('votes')
                //             ->where('voter_id', $record->id)
                //             ->orderBy('voted_at', 'desc')
                //             ->first();
                //         return $lastVote ? \Carbon\Carbon::parse($lastVote->voted_at)->format('M d, Y') : 'Never';
                //     })
                //     ->dateTime()
                //     ->sortable(query: function ($query, string $direction) {
                //         return $query->join('votes', 'users.id', '=', 'votes.voter_id')
                //             ->select('users.*', DB::raw('MAX(votes.voted_at) as last_vote'))
                //             ->groupBy('users.id')
                //             ->orderBy('last_vote', $direction);
                //     })
                //     ->toggleable(isToggledHiddenByDefault: true),

                TextColumn::make('created_at')
                    ->label('Created')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                SelectFilter::make('enrollment_status')
                    ->label('Enrollment Status')
                    ->options([
                        'Active' => 'Active',
                        'Suspended' => 'Suspended',
                        'Graduated' => 'Graduated',
                    ]),

                SelectFilter::make('class_level')
                    ->label('Class Level')
                    ->options([
                        'Freshman' => 'Freshman',
                        'Sophomore' => 'Sophomore',
                        'Junior' => 'Junior',
                        'Senior' => 'Senior',
                    ]),

                SelectFilter::make('student_type')
                    ->label('Student Type')
                    ->options([
                        'Undergraduate' => 'Undergraduate',
                        'Graduate' => 'Graduate',
                        'Transfer' => 'Transfer',
                        'International' => 'International',
                    ]),
            ])
            ->recordActions([
                ViewAction::make(),
                EditAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ])
            ->defaultSort('student_id')
            ->emptyStateHeading('No students yet')
            ->emptyStateDescription('Create your first student account to get started.')
            ->emptyStateIcon('heroicon-o-users');
    }
}
