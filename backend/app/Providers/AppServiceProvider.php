<?php

namespace App\Providers;

use App\Models\Election;
use App\Models\Vote;
use App\Observers\ElectionObserver;
use App\Observers\VoteObserver;
use Filament\Support\Facades\FilamentTimezone;
use Illuminate\Support\ServiceProvider;
use Livewire\Component;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Set global timezone for all Filament components (DateTimePicker, TextColumn, etc.)
        // This ensures dates are stored and displayed in America/Chicago timezone consistently
        FilamentTimezone::set('America/Chicago');

        // Register observers
        Election::observe(ElectionObserver::class);
        Vote::observe(VoteObserver::class);

        // Add Livewire macro for global notifications
        // This allows any Livewire component to call $this->notifyGlobal($message, $type)
        // In Livewire 3, dispatchBrowserEvent is deprecated - use dispatch() instead
        Component::macro('notifyGlobal', function ($message, $type = 'info') {
            // $this refers to the component instance
            // In Livewire 3, use dispatch() which dispatches browser events
            $this->dispatch('notify', message: $message, type: $type);
        });
    }
}
