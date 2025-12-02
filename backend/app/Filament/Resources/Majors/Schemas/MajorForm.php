<?php

namespace App\Filament\Resources\Majors\Schemas;

use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;

class MajorForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('name')
                    ->label('Major/Minor Name')
                    ->required()
                    ->unique(ignoreRecord: true)
                    ->maxLength(255)
                    ->helperText('Enter the name of the major or minor (e.g., Computer Science, Mathematics)'),
            ]);
    }
}
