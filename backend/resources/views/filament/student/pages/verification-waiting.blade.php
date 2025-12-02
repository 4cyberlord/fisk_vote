<div 
    x-data="verificationStatus()"
    x-init="init()"
    class="fi-section-content-ctn"
>
    <div class="max-w-lg mx-auto py-8">
        <!-- Simple Header -->
        <div class="text-center mb-8">
            <h2 class="text-xl font-semibold text-gray-900 dark:text-white mb-2">
                Check Your Email
            </h2>
            <p class="text-sm text-gray-600 dark:text-gray-400">
                We sent a verification link to <strong>{{ $this->registrationEmail ?? 'your email' }}</strong>
            </p>
        </div>

        <!-- Simple Instructions -->
        <div class="bg-gray-50 dark:bg-gray-800 rounded-lg p-6 mb-6">
            <p class="text-sm text-gray-700 dark:text-gray-300 mb-4">
                Please check your email and click the verification link to activate your account.
            </p>
            <p class="text-xs text-gray-500 dark:text-gray-400">
                The link expires in 2 minutes and can only be used once.
            </p>
        </div>

        <!-- Status Message -->
        <div class="mb-6 text-center">
            <div x-show="!isVerified" class="text-sm text-gray-600 dark:text-gray-400">
                <p>Waiting for verification...</p>
            </div>
            <div x-show="isVerified" style="display: none;" class="text-sm text-green-600 dark:text-green-400 font-medium">
                <p>✓ Email verified! You can continue now.</p>
            </div>
        </div>

        <!-- Continue Button -->
        <div>
            <button
                type="button"
                @click="checkVerification()"
                :disabled="!isVerified || checking"
                class="w-full fi-btn fi-btn-size-lg fi-color-primary inline-flex items-center justify-center gap-x-2 rounded-lg border border-transparent bg-primary-600 px-4 py-2.5 text-sm font-semibold text-white shadow-sm transition duration-75 hover:bg-primary-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary-600 disabled:opacity-50 disabled:cursor-not-allowed dark:bg-primary-500 dark:hover:bg-primary-400 dark:focus-visible:outline-primary-500"
            >
                <span x-show="checking" style="display: none;" class="inline-block">
                    Checking...
                </span>
                <span x-show="!checking && !isVerified" class="inline-block">
                    Waiting for Verification
                </span>
                <span x-show="!checking && isVerified" style="display: none;" class="inline-block">
                    Continue
                </span>
            </button>
        </div>
    </div>
</div>

<script>
function verificationStatus() {
    return {
        isVerified: false,
        checking: false,
        interval: null,
        
        checkVerification() {
            this.checking = true;
            $wire.checkEmailVerification().then((verified) => {
                this.isVerified = verified;
                this.checking = false;
                if (verified) {
                    setTimeout(() => {
                        this.navigateToNextStep();
                    }, 1000);
                }
            });
        },
        
        navigateToNextStep() {
            const buttons = document.querySelectorAll('button[type="button"]');
            for (let btn of buttons) {
                const text = btn.textContent.trim();
                if (text.includes('Next') && !btn.disabled && !btn.classList.contains('opacity-50')) {
                    btn.click();
                    break;
                }
            }
        },
        
        init() {
            this.checkVerification();
            this.interval = setInterval(() => {
                if (!this.isVerified) {
                    $wire.checkEmailVerification().then((verified) => {
                        this.isVerified = verified;
                        if (verified) {
                            clearInterval(this.interval);
                            setTimeout(() => {
                                this.navigateToNextStep();
                            }, 1000);
                        }
                    });
                }
            }, 3000);
        },
        
        destroy() {
            if (this.interval) {
                clearInterval(this.interval);
            }
        }
    };
}
</script>
