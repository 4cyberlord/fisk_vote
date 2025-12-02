<?php

namespace App\Filament\Resources\Spatie\Permission\Models\Roles\Pages;

use App\Filament\Resources\Spatie\Permission\Models\Roles\RoleResource;
use Filament\Actions\DeleteAction;
use Filament\Actions\ViewAction;
use Filament\Resources\Pages\EditRecord;

class EditRole extends EditRecord
{
    protected static string $resource = RoleResource::class;

    protected function getHeaderActions(): array
    {
        return [
            ViewAction::make(),
            DeleteAction::make(),
        ];
    }

    protected function mutateFormDataBeforeSave(array $data): array
    {
        // Extract permissions from the data
        $permissions = $data['permissions'] ?? [];
        unset($data['permissions']);

        return $data;
    }

    protected function afterSave(): void
    {
        // Sync permissions after role is updated
        $permissions = $this->form->getState()['permissions'] ?? [];
        $this->record->syncPermissions($permissions);
    }
}
