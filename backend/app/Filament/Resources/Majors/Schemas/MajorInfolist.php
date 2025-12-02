<?php

namespace App\Filament\Resources\Majors\Schemas;

use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;

class MajorInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('name')
                    ->label('Major/Minor Name')
                    ->weight('bold'),

                TextEntry::make('created_at')
                    ->label('Created At')
                    ->dateTime(),

                TextEntry::make('updated_at')
                    ->label('Updated At')
                    ->dateTime(),
            ]);
    }
}
