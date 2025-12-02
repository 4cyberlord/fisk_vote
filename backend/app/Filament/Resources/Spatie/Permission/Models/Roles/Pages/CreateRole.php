<?php

namespace App\Filament\Resources\Spatie\Permission\Models\Roles\Pages;

use App\Filament\Resources\Spatie\Permission\Models\Roles\RoleResource;
use Filament\Resources\Pages\CreateRecord;

class CreateRole extends CreateRecord
{
    protected static string $resource = RoleResource::class;

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        // Extract permissions from the data
        $permissions = $data['permissions'] ?? [];
        unset($data['permissions']);

        return $data;
    }

    protected function afterCreate(): void
    {
        // Sync permissions after role is created
        $permissions = $this->form->getState()['permissions'] ?? [];
        if (!empty($permissions)) {
            $this->record->syncPermissions($permissions);
        }
    }
}
