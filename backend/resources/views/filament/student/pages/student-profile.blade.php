<x-filament-panels::page>
    <form wire:submit="save">
        {{ $this->form }}

        <div style="margin-top: 1.5rem; padding-top: 1rem; display: flex; justify-content: flex-end;">
            <x-filament::actions :actions="$this->getFormActions()" :full-width="$this->hasFullWidthFormActions()" />
        </div>
    </form>
</x-filament-panels::page>
