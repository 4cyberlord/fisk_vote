<?php

namespace App\Filament\Resources\Users\Pages;

use App\Filament\Resources\Users\UserResource;
use Filament\Actions\DeleteAction;
use Filament\Actions\ViewAction;
use Filament\Resources\Pages\EditRecord;
use Illuminate\Support\Facades\Crypt;
use Illuminate\Support\Facades\Hash;

class EditUser extends EditRecord
{
    protected static string $resource = UserResource::class;

    protected function getHeaderActions(): array
    {
        return [
            ViewAction::make(),
            DeleteAction::make(),
        ];
    }

    protected function mutateFormDataBeforeSave(array $data): array
    {
        // Always set email from university_email
        if (!empty($data['university_email'])) {
            $data['email'] = $data['university_email'];
        }

        // Combine first_name, middle_initial, and last_name into name field
        $nameParts = [];
        if (!empty($data['first_name'])) {
            $nameParts[] = $data['first_name'];
        }
        if (!empty($data['middle_initial'])) {
            $nameParts[] = trim($data['middle_initial']) . '.';
        }
        if (!empty($data['last_name'])) {
            $nameParts[] = $data['last_name'];
        }
        $data['name'] = implode(' ', $nameParts);

        // Password and temporary_password are hidden from admin (dehydrated=false)
        // Since fields are hidden, they won't be in $data, so we keep existing values
        // Remove from data to prevent overwriting existing password
        unset($data['password']);
        unset($data['temporary_password']);

        return $data;
    }
}
