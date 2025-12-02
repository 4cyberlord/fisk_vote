<?php

namespace App\Filament\Resources\ElectionPositions;

use App\Filament\Resources\ElectionPositions\Pages\CreateElectionPosition;
use App\Filament\Resources\ElectionPositions\Pages\EditElectionPosition;
use App\Filament\Resources\ElectionPositions\Pages\ListElectionPositions;
use App\Filament\Resources\ElectionPositions\Pages\ViewElectionPosition;
use App\Filament\Resources\ElectionPositions\Schemas\ElectionPositionForm;
use App\Filament\Resources\ElectionPositions\Schemas\ElectionPositionInfolist;
use App\Filament\Resources\ElectionPositions\Tables\ElectionPositionsTable;
use App\Models\ElectionPosition;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables\Table;

class ElectionPositionResource extends Resource
{
    protected static ?string $model = ElectionPosition::class;

    protected static string | \BackedEnum | null $navigationIcon = 'heroicon-o-briefcase';

    protected static ?string $navigationLabel = 'Positions';

    protected static ?string $modelLabel = 'Position';

    protected static ?string $pluralModelLabel = 'Positions';

    protected static string | \UnitEnum | null $navigationGroup = 'Voting';

    public static function form(Schema $schema): Schema
    {
        return ElectionPositionForm::configure($schema);
    }

    public static function infolist(Schema $schema): Schema
    {
        return ElectionPositionInfolist::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return ElectionPositionsTable::configure($table);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListElectionPositions::route('/'),
            'create' => CreateElectionPosition::route('/create'),
            'view' => ViewElectionPosition::route('/{record}'),
            'edit' => EditElectionPosition::route('/{record}/edit'),
        ];
    }
}
