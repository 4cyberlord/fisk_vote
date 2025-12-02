<?php

namespace App\Filament\Resources\EmailSettings;

use App\Filament\Resources\EmailSettings\Pages\CreateEmailSetting;
use App\Filament\Resources\EmailSettings\Pages\EditEmailSetting;
use App\Filament\Resources\EmailSettings\Pages\ListEmailSettings;
use App\Filament\Resources\EmailSettings\Pages\ViewEmailSetting;
use App\Filament\Resources\EmailSettings\Schemas\EmailSettingForm;
use App\Filament\Resources\EmailSettings\Schemas\EmailSettingInfolist;
use App\Filament\Resources\EmailSettings\Tables\EmailSettingsTable;
use App\Models\EmailSetting;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables\Table;

class EmailSettingResource extends Resource
{
    protected static ?string $model = EmailSetting::class;

    protected static string | \BackedEnum | null $navigationIcon = 'heroicon-o-envelope';

    protected static ?string $navigationLabel = 'Email & Notifications';

    protected static ?string $modelLabel = 'Email & Notification Settings';

    protected static ?string $pluralModelLabel = 'Email & Notification Settings';

    protected static string | \UnitEnum | null $navigationGroup = 'System';

    public static function form(Schema $schema): Schema
    {
        return EmailSettingForm::configure($schema);
    }

    public static function infolist(Schema $schema): Schema
    {
        return EmailSettingInfolist::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return EmailSettingsTable::configure($table);
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
            'index' => ListEmailSettings::route('/'),
            'create' => CreateEmailSetting::route('/create'),
            'view' => ViewEmailSetting::route('/{record}'),
            'edit' => EditEmailSetting::route('/{record}/edit'),
        ];
    }
}
