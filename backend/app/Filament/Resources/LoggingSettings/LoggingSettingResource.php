<?php

namespace App\Filament\Resources\LoggingSettings;

use App\Filament\Resources\LoggingSettings\Pages\CreateLoggingSetting;
use App\Filament\Resources\LoggingSettings\Pages\EditLoggingSetting;
use App\Filament\Resources\LoggingSettings\Pages\ListLoggingSettings;
use App\Filament\Resources\LoggingSettings\Pages\ViewLoggingSetting;
use App\Filament\Resources\LoggingSettings\Schemas\LoggingSettingForm;
use App\Filament\Resources\LoggingSettings\Schemas\LoggingSettingInfolist;
use App\Filament\Resources\LoggingSettings\Tables\LoggingSettingsTable;
use App\Models\LoggingSetting;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables\Table;

class LoggingSettingResource extends Resource
{
    protected static ?string $model = LoggingSetting::class;

    protected static string | \BackedEnum | null $navigationIcon = 'heroicon-o-chart-bar-square';

    protected static ?string $navigationLabel = 'Logs & Monitoring';

    protected static ?string $modelLabel = 'Logs & Monitoring Settings';

    protected static ?string $pluralModelLabel = 'Logs & Monitoring Settings';

    protected static string | \UnitEnum | null $navigationGroup = 'System';

    public static function form(Schema $schema): Schema
    {
        return LoggingSettingForm::configure($schema);
    }

    public static function infolist(Schema $schema): Schema
    {
        return LoggingSettingInfolist::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return LoggingSettingsTable::configure($table);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListLoggingSettings::route('/'),
            'create' => CreateLoggingSetting::route('/create'),
            'view' => ViewLoggingSetting::route('/{record}'),
            'edit' => EditLoggingSetting::route('/{record}/edit'),
        ];
    }
}

