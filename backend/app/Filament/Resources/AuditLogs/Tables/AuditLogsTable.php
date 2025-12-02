<?php

namespace App\Filament\Resources\AuditLogs\Tables;

use App\Models\AuditLog;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\BadgeColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Filters\Filter;
use Filament\Tables\Table;
use Filament\Actions\ViewAction;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\DB;

class AuditLogsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('created_at')
                    ->label('Date & Time')
                    ->dateTime('M j, Y g:i A')
                    ->sortable()
                    ->searchable()
                    ->description(fn (AuditLog $record): string => $record->created_at->diffForHumans())
                    ->width('180px'),

                TextColumn::make('user_name')
                    ->label('User')
                    ->searchable()
                    ->sortable()
                    ->description(fn (AuditLog $record): ?string => $record->user_email)
                    ->icon('heroicon-o-user')
                    ->default('System'),

                TextColumn::make('action_type')
                    ->label('Action')
                    ->badge()
                    ->color(fn (string $state): string => match($state) {
                        'created' => 'success',
                        'updated' => 'info',
                        'deleted' => 'danger',
                        'login.success' => 'success',
                        'login.failed' => 'danger',
                        'logout' => 'gray',
                        'vote.submitted' => 'success',
                        default => 'primary',
                    })
                    ->searchable()
                    ->sortable(),

                TextColumn::make('action_description')
                    ->label('Description')
                    ->limit(50)
                    ->tooltip(fn (AuditLog $record): string => $record->action_description)
                    ->searchable()
                    ->wrap(),

                TextColumn::make('resource_name')
                    ->label('Resource')
                    ->limit(30)
                    ->tooltip(fn (AuditLog $record): ?string => $record->resource_name)
                    ->searchable()
                    ->sortable()
                    ->default('N/A'),

                BadgeColumn::make('status')
                    ->label('Status')
                    ->colors([
                        'success' => 'success',
                        'failed' => 'danger',
                        'pending' => 'warning',
                    ])
                    ->sortable(),

                TextColumn::make('ip_address')
                    ->label('IP Address')
                    ->toggleable(isToggledHiddenByDefault: true)
                    ->searchable(),

                TextColumn::make('user_role')
                    ->label('Role')
                    ->badge()
                    ->color('info')
                    ->toggleable(isToggledHiddenByDefault: true)
                    ->sortable(),
            ])
            ->filters([
                SelectFilter::make('status')
                    ->options([
                        'success' => 'Success',
                        'failed' => 'Failed',
                        'pending' => 'Pending',
                    ])
                    ->multiple(),

                SelectFilter::make('action_type')
                    ->label('Action Type')
                    ->options(function () {
                        return AuditLog::query()
                            ->distinct()
                            ->pluck('action_type')
                            ->mapWithKeys(fn ($type) => [$type => ucfirst(str_replace('.', ' ', $type))])
                            ->toArray();
                    })
                    ->multiple()
                    ->searchable(),

                SelectFilter::make('user_role')
                    ->label('User Role')
                    ->options(function () {
                        return AuditLog::query()
                            ->whereNotNull('user_role')
                            ->distinct()
                            ->pluck('user_role')
                            ->mapWithKeys(fn ($role) => [$role => ucfirst($role)])
                            ->toArray();
                    })
                    ->multiple(),

                Filter::make('created_at')
                    ->form([
                        \Filament\Forms\Components\DatePicker::make('created_from')
                            ->label('Created From'),
                        \Filament\Forms\Components\DatePicker::make('created_until')
                            ->label('Created Until'),
                    ])
                    ->query(function (Builder $query, array $data): Builder {
                        return $query
                            ->when(
                                $data['created_from'],
                                fn (Builder $query, $date): Builder => $query->whereDate('created_at', '>=', $date),
                            )
                            ->when(
                                $data['created_until'],
                                fn (Builder $query, $date): Builder => $query->whereDate('created_at', '<=', $date),
                            );
                    }),

                SelectFilter::make('auditable_type')
                    ->label('Resource Type')
                    ->options(function () {
                        return AuditLog::query()
                            ->whereNotNull('auditable_type')
                            ->distinct()
                            ->pluck('auditable_type')
                            ->mapWithKeys(fn ($type) => [\Str::afterLast($type, '\\') => class_basename($type)])
                            ->toArray();
                    })
                    ->multiple()
                    ->searchable(),

                Filter::make('user_id')
                    ->form([
                        \Filament\Forms\Components\Select::make('user_id')
                            ->label('User')
                            ->relationship('user', 'name')
                            ->searchable()
                            ->preload(),
                    ])
                    ->query(function (Builder $query, array $data): Builder {
                        return $query->when(
                            $data['user_id'],
                            fn (Builder $query, $userId): Builder => $query->where('user_id', $userId),
                        );
                    }),
            ])
            ->defaultSort('created_at', 'desc')
            ->recordActions([
                ViewAction::make(),
            ])
            ->bulkActions([
                // No bulk actions - audit logs should not be deleted
            ])
            ->poll('30s') // Auto-refresh every 30 seconds
            ->emptyStateHeading('No audit logs yet')
            ->emptyStateDescription('Activity logs will appear here as users interact with the system.')
            ->emptyStateIcon('heroicon-o-clipboard-document-list');
    }
}
