<?php

namespace App\Providers;

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
