<?php

namespace App\Filament\Resources\Spatie\Permission\Models\Roles;

use App\Filament\Resources\Spatie\Permission\Models\Roles\Pages\CreateRole;
use App\Filament\Resources\Spatie\Permission\Models\Roles\Pages\EditRole;
use App\Filament\Resources\Spatie\Permission\Models\Roles\Pages\ListRoles;
use App\Filament\Resources\Spatie\Permission\Models\Roles\Pages\ViewRole;
use App\Filament\Resources\Spatie\Permission\Models\Roles\Schemas\RoleForm;
use App\Filament\Resources\Spatie\Permission\Models\Roles\Schemas\RoleInfolist;
use App\Filament\Resources\Spatie\Permission\Models\Roles\Tables\RolesTable;
use Spatie\Permission\Models\Role;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables\Table;

class RoleResource extends Resource
{
    protected static ?string $model = Role::class;

    protected static string | \BackedEnum | null $navigationIcon = 'heroicon-o-shield-check';

    protected static ?string $navigationLabel = 'Roles';

    protected static ?string $modelLabel = 'Role';

    protected static ?string $pluralModelLabel = 'Roles';

    protected static string | \UnitEnum | null $navigationGroup = 'Access Control';

    public static function form(Schema $schema): Schema
    {
        return RoleForm::configure($schema);
    }

    public static function infolist(Schema $schema): Schema
    {
        return RoleInfolist::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return RolesTable::configure($table);
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
            'index' => ListRoles::route('/'),
            'create' => CreateRole::route('/create'),
            'view' => ViewRole::route('/{record}'),
            'edit' => EditRole::route('/{record}/edit'),
        ];
    }
}
