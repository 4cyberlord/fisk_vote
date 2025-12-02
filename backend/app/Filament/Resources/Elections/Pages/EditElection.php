<?php

namespace App\Filament\Resources\Elections\Pages;

use App\Filament\Resources\Elections\ElectionResource;
use Filament\Actions\DeleteAction;
use Filament\Actions\ViewAction;
use Filament\Resources\Pages\EditRecord;

class EditElection extends EditRecord
{
    protected static string $resource = ElectionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            ViewAction::make(),
            DeleteAction::make(),
        ];
    }

    protected function mutateFormDataBeforeSave(array $data): array
    {
        // Clear eligible_groups if is_universal is true
        if (!empty($data['is_universal']) && $data['is_universal']) {
            $data['eligible_groups'] = null;
        } else {
            // Ensure eligible_groups is properly structured as an array
            if (empty($data['eligible_groups'])) {
                $data['eligible_groups'] = [
                    'departments' => [],
                    'class_levels' => [],
                    'organizations' => [],
                    'manual' => [],
                ];
            } else {
                // Ensure all keys exist
                $data['eligible_groups'] = array_merge([
                    'departments' => [],
                    'class_levels' => [],
                    'organizations' => [],
                    'manual' => [],
                ], $data['eligible_groups']);
            }
        }

        return $data;
    }
}
