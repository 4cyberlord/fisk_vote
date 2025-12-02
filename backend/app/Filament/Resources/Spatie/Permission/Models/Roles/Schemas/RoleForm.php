<?php

namespace App\Filament\Resources\Spatie\Permission\Models\Roles\Schemas;

use Filament\Forms\Components\CheckboxList;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class RoleForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Role Information')
                    ->schema([
                        TextInput::make('name')
                            ->label('Role Name')
                            ->required()
                            ->unique(ignoreRecord: true)
                            ->maxLength(255)
                            ->helperText('A unique name for this role (e.g., admin, voter, moderator)'),

                        Select::make('guard_name')
                            ->label('Guard Name')
                            ->options([
                                'web' => 'Web',
                                'api' => 'API',
                            ])
                            ->default('web')
                            ->required()
                            ->helperText('The guard this role applies to'),
                    ])
                    ->columns(2),

                Section::make('Permissions')
                    ->schema([
                        CheckboxList::make('permissions')
                            ->label('Assign Permissions')
                            ->relationship('permissions', 'name')
                            ->searchable()
                            ->bulkToggleable()
                            ->gridDirection('row')
                            ->columns(3)
                            ->helperText('Select the permissions that this role should have'),
                    ]),
            ]);
    }
}
