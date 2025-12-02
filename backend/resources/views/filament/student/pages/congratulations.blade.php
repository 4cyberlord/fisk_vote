<div class="space-y-6 text-center">
    <div class="mx-auto flex items-center justify-center h-20 w-20 rounded-full bg-green-100 dark:bg-green-900 mb-6">
        <svg class="h-12 w-12 text-green-600 dark:text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
        </svg>
    </div>

    <div>
        <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-3">
            🎉 Congratulations!
        </h2>
        <p class="text-lg text-gray-700 dark:text-gray-300 mb-6">
            Your email has been successfully verified!
        </p>
    </div>

    <div class="bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-lg p-6">
        <p class="text-gray-700 dark:text-gray-300 mb-4">
            Your account is now active and ready to use. You can now log in and start voting!
        </p>
        
        <div class="mt-6">
            <a href="{{ filament()->getPanel('student')->getLoginUrl() }}" class="inline-flex items-center px-6 py-3 border border-transparent text-base font-medium rounded-md text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 transition-colors">
                <svg class="h-5 w-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1"></path>
                </svg>
                Login Now
            </a>
        </div>
    </div>

    <div class="pt-4">
        <p class="text-sm text-gray-500 dark:text-gray-400">
            Thank you for registering with the Fisk Voting System!
        </p>
    </div>
</div>

