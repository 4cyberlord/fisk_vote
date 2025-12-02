<?php

namespace App\Filament\Resources\Users\Pages;

use App\Filament\Resources\Users\UserResource;
use Filament\Resources\Pages\CreateRecord;
use Illuminate\Support\Facades\Crypt;
use Illuminate\Support\Facades\Hash;

class CreateUser extends CreateRecord
{
    protected static string $resource = UserResource::class;

    protected function mutateFormDataBeforeCreate(array $data): array
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

        // Automatically set password and temporary_password (fields are hidden from admin)
        $temporaryPassword = 'Fisk123';

        // Hash the password - always use temporary password as default
        $data['password'] = Hash::make($temporaryPassword);

        // Encrypt temporary_password before saving (so it can be decrypted later if needed)
        $data['temporary_password'] = Crypt::encryptString($temporaryPassword);

        return $data;
    }

    protected function afterCreate(): void
    {
        // Role assignment is handled in the User model's boot method
        // But we can ensure it here as well
        if (!$this->record->hasAnyRole()) {
            $studentRole = \Spatie\Permission\Models\Role::firstOrCreate(['name' => 'Student', 'guard_name' => 'web']);
            $this->record->assignRole($studentRole);
        }
    }
}
