<div class="space-y-6">
    <div class="text-center">
        <div class="mx-auto flex items-center justify-center h-16 w-16 rounded-full bg-primary-100 dark:bg-primary-900 mb-4">
            <svg class="h-8 w-8 text-primary-600 dark:text-primary-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
            </svg>
        </div>
        <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-2">
            Verification Email Sent!
        </h3>
    </div>

    <div class="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg p-6">
        <p class="text-gray-700 dark:text-gray-300 mb-4">
            We've sent a verification email to <strong class="text-gray-900 dark:text-white">{{ $this->registrationEmail ?? 'your email address' }}</strong>
        </p>
        
        <div class="space-y-3">
            <div class="flex items-start">
                <svg class="h-5 w-5 text-blue-600 dark:text-blue-400 mt-0.5 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                </svg>
                <p class="text-sm text-gray-700 dark:text-gray-300">
                    Check your inbox (including spam folder) for the verification email
                </p>
            </div>
            
            <div class="flex items-start">
                <svg class="h-5 w-5 text-blue-600 dark:text-blue-400 mt-0.5 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                </svg>
                <p class="text-sm text-gray-700 dark:text-gray-300">
                    Click the verification link in the email to activate your account
                </p>
            </div>
            
            <div class="flex items-start">
                <svg class="h-5 w-5 text-blue-600 dark:text-blue-400 mt-0.5 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                </svg>
                <p class="text-sm text-gray-700 dark:text-gray-300">
                    <strong>Important:</strong> The verification link expires in <strong>2 minutes</strong> and can only be used <strong>once</strong>
                </p>
            </div>
        </div>
    </div>

    <div class="bg-yellow-50 dark:bg-yellow-900/20 border border-yellow-200 dark:border-yellow-800 rounded-lg p-4">
        <p class="text-sm text-yellow-800 dark:text-yellow-200">
            <strong>Note:</strong> After clicking the verification link, return to this page and click "Next" to proceed to the final step.
        </p>
    </div>
</div>

