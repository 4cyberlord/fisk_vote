<?php

namespace App\Filament\Resources\Spatie\Permission\Models\Roles\Schemas;

use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class RoleInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Role Information')
                    ->schema([
                        TextEntry::make('name')
                            ->label('Role Name'),

                        TextEntry::make('guard_name')
                            ->label('Guard Name')
                            ->badge()
                            ->color(fn (string $state): string => match ($state) {
                                'web' => 'success',
                                'api' => 'info',
                                default => 'gray',
                            }),
                    ])
                    ->columns(2),

                Section::make('Permissions')
                    ->schema([
                        TextEntry::make('permissions.name')
                            ->label('Assigned Permissions')
                            ->badge()
                            ->separator(',')
                            ->placeholder('No permissions assigned'),
                    ]),

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
