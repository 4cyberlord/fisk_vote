<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}" class="fi" data-theme-mode="{{ strtolower($theme ?? 'system') }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>Email Verified Successfully - {{ $panel->getBrandName() ?? 'Fisk Voting System' }}</title>
    
    @php
        \Filament\Facades\Filament::setCurrentPanel($panel);
    @endphp
    
    @filamentStyles
    @vite('resources/css/app.css')
    
    <style>
        [x-cloak] { display: none !important; }
        .fi-body {
            font-family: ui-sans-serif, system-ui, sans-serif;
        }
        @keyframes fadeIn {
            from {
                opacity: 0;
            }
            to {
                opacity: 1;
            }
        }
        .animate-fade-in {
            animation: fadeIn 0.5s ease-out forwards;
        }
    </style>
</head>
<body class="fi-body min-h-screen bg-gray-50 dark:bg-gray-950">
    <div class="min-h-screen flex items-center justify-center px-4 py-12 sm:px-6 lg:px-8">
        <div class="w-full max-w-md text-center animate-fade-in">
            <!-- Emoji -->
            <div class="text-7xl mb-6">
                🎉
            </div>

            <!-- Title -->
            <h1 class="text-4xl font-bold text-gray-900 dark:text-white mb-4">
                Email Verified!
            </h1>

            <!-- Message -->
            <p class="text-xl text-gray-600 dark:text-gray-300 mb-8">
                @if(isset($userName) && $userName)
                    Welcome, <span class="font-semibold text-gray-900 dark:text-white">{{ $userName }}</span>!
                @else
                    Your account is ready!
                @endif
            </p>

            <!-- Login Button -->
            <div class="mb-6">
                <a href="{{ route('filament.student.auth.login') }}" 
                   class="inline-flex items-center justify-center gap-x-2 rounded-lg border border-transparent bg-primary-600 px-8 py-3 text-base font-semibold text-white shadow-sm transition-all duration-200 hover:bg-primary-500 hover:shadow-md focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary-600 dark:bg-primary-500 dark:hover:bg-primary-400 dark:focus-visible:outline-primary-500">
                    Continue to Login
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
                    </svg>
                </a>
            </div>

            <!-- Footer -->
            <p class="text-sm text-gray-500 dark:text-gray-400">
                Thank you for joining!
            </p>
        </div>
    </div>
    
    @filamentScripts
</body>
</html>

