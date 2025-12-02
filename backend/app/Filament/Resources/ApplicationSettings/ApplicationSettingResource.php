<?php

namespace App\Filament\Resources\ApplicationSettings;

use App\Filament\Resources\ApplicationSettings\Pages\CreateApplicationSetting;
use App\Filament\Resources\ApplicationSettings\Pages\EditApplicationSetting;
use App\Filament\Resources\ApplicationSettings\Pages\ListApplicationSettings;
use App\Filament\Resources\ApplicationSettings\Pages\ViewApplicationSetting;
use App\Filament\Resources\ApplicationSettings\Schemas\ApplicationSettingForm;
use App\Filament\Resources\ApplicationSettings\Schemas\ApplicationSettingInfolist;
use App\Filament\Resources\ApplicationSettings\Tables\ApplicationSettingsTable;
use App\Models\ApplicationSetting;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables\Table;

class ApplicationSettingResource extends Resource
{
    protected static ?string $model = ApplicationSetting::class;

    protected static string | \BackedEnum | null $navigationIcon = 'heroicon-o-cog-6-tooth';

    protected static ?string $navigationLabel = 'Settings';

    protected static ?string $modelLabel = 'Application Settings';

    protected static ?string $pluralModelLabel = 'Application Settings';

    protected static string | \UnitEnum | null $navigationGroup = 'System';

    public static function form(Schema $schema): Schema
    {
        return ApplicationSettingForm::configure($schema);
    }

    public static function infolist(Schema $schema): Schema
    {
        return ApplicationSettingInfolist::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return ApplicationSettingsTable::configure($table);
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
            'index' => ListApplicationSettings::route('/'),
            'create' => CreateApplicationSetting::route('/create'),
            'view' => ViewApplicationSetting::route('/{record}'),
            'edit' => EditApplicationSetting::route('/{record}/edit'),
        ];
    }

    public static function shouldRegisterNavigation(): bool
    {
        return true;
    }

    public static function getNavigationBadge(): ?string
    {
        return null;
    }
}
