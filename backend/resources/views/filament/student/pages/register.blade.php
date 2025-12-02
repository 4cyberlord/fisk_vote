<x-filament-panels::page>
    {{ $this->form }}
    
    <script>
        // Listen for redirect event
        document.addEventListener('livewire:init', () => {
            Livewire.on('redirect-to-verify', (event) => {
                // Force full page redirect
                window.location.href = event.url;
            });
        });
        
        // Also listen for Livewire events
        window.addEventListener('redirect-to-verify', (event) => {
            window.location.href = event.detail.url;
        });
    </script>
</x-filament-panels::page>

