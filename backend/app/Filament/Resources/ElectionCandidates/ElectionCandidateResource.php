<?php

namespace App\Filament\Resources\ElectionCandidates;

use App\Filament\Resources\ElectionCandidates\Pages\CreateElectionCandidate;
use App\Filament\Resources\ElectionCandidates\Pages\EditElectionCandidate;
use App\Filament\Resources\ElectionCandidates\Pages\ListElectionCandidates;
use App\Filament\Resources\ElectionCandidates\Pages\ViewElectionCandidate;
use App\Filament\Resources\ElectionCandidates\Schemas\ElectionCandidateForm;
use App\Filament\Resources\ElectionCandidates\Schemas\ElectionCandidateInfolist;
use App\Filament\Resources\ElectionCandidates\Tables\ElectionCandidatesTable;
use App\Models\ElectionCandidate;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables\Table;

class ElectionCandidateResource extends Resource
{
    protected static ?string $model = ElectionCandidate::class;

    protected static string | \BackedEnum | null $navigationIcon = 'heroicon-o-user-circle';

    protected static ?string $navigationLabel = 'Candidates';

    protected static ?string $modelLabel = 'Candidate';

    protected static ?string $pluralModelLabel = 'Candidates';

    protected static string | \UnitEnum | null $navigationGroup = 'Voting';

    public static function form(Schema $schema): Schema
    {
        return ElectionCandidateForm::configure($schema);
    }

    public static function infolist(Schema $schema): Schema
    {
        return ElectionCandidateInfolist::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return ElectionCandidatesTable::configure($table);
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
            'index' => ListElectionCandidates::route('/'),
            'create' => CreateElectionCandidate::route('/create'),
            'view' => ViewElectionCandidate::route('/{record}'),
            'edit' => EditElectionCandidate::route('/{record}/edit'),
        ];
    }
}
