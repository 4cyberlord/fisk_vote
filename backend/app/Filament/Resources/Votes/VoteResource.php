<?php

namespace App\Filament\Resources\Votes;

use App\Filament\Resources\Votes\Pages\CreateVote;
use App\Filament\Resources\Votes\Pages\EditVote;
use App\Filament\Resources\Votes\Pages\ListVotes;
use App\Filament\Resources\Votes\Pages\ViewVote;
use App\Filament\Resources\Votes\Schemas\VoteForm;
use App\Filament\Resources\Votes\Schemas\VoteInfolist;
use App\Filament\Resources\Votes\Tables\VotesTable;
use App\Models\Vote;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables\Table;

class VoteResource extends Resource
{
    protected static ?string $model = Vote::class;

    protected static string | \BackedEnum | null $navigationIcon = 'heroicon-o-check-circle';

    protected static ?string $navigationLabel = 'Votes';

    protected static ?string $modelLabel = 'Vote';

    protected static ?string $pluralModelLabel = 'Votes';

    protected static string | \UnitEnum | null $navigationGroup = 'Voting';

    public static function form(Schema $schema): Schema
    {
        return VoteForm::configure($schema);
    }

    public static function infolist(Schema $schema): Schema
    {
        return VoteInfolist::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return VotesTable::configure($table);
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
            'index' => ListVotes::route('/'),
            'create' => CreateVote::route('/create'),
            'view' => ViewVote::route('/{record}'),
            'edit' => EditVote::route('/{record}/edit'),
        ];
    }
}
