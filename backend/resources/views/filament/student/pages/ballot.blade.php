<x-filament-panels::page>
    @if($hasVoted)
        <div class="mb-4">
            <x-filament::alert color="info" icon="heroicon-o-information-circle">
                You have already submitted your vote for this election. This is a read-only view of your ballot.
            </x-filament::alert>
        </div>
    @endif

    <form wire:submit="submit">
        {{ $this->form }}

    </form>
</x-filament-panels::page>

