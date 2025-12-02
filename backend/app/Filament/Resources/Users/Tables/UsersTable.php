<?php

namespace App\Filament\Resources\Users\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

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
