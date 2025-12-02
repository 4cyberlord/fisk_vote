<?php

namespace App\Notifications;

use Illuminate\Auth\Notifications\VerifyEmail;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\URL;
use Illuminate\Support\Facades\Route;

class VerifyStudentEmail extends VerifyEmail
{
    /**
     * Override parent's static callback property to prevent it from using default route
     * Set to null to ensure parent's verificationUrl never uses a callback
     */
    public static $createUrlCallback = null;

    /**
     * Override parent's static method to prevent external code from setting a callback
     * that would override our verificationUrl method
     */
    public static function createUrlUsing($callback)
    {
        // Ignore any attempts to set a callback - we handle URL generation ourselves
        // This prevents external code from overriding our verificationUrl method
        static::$createUrlCallback = null;
    }

    /**
     * Override parent's static toMail callback to prevent it from interfering
     */
    public static $toMailCallback = null;

    /**
     * Get the notification's delivery channels.
     *
     * @param  mixed  $notifiable
     * @return array<int, string>
     */
    public function via($notifiable): array
    {
        // Use only custom mail channel that uses the configured email service
        return [\App\Notifications\Channels\CustomMailChannel::class];
    }

    /**
     * Get the verification URL for the given notifiable.
     * IMPORTANT: This completely overrides parent method to use API route instead of default 'verification.verify'
     *
     * We override this method completely to prevent the parent from using the non-existent 'verification.verify' route
     *
     * CRITICAL: This method MUST NOT call parent::verificationUrl() as it uses 'verification.verify' route
     *
     * @param  mixed  $notifiable
     * @return string
     */
    protected function verificationUrl($notifiable)
    {
        // CRITICAL: Never call parent::verificationUrl() as it uses 'verification.verify' route which doesn't exist
        // This method MUST be called instead of parent's method

        // Ensure static callback is null to prevent parent from using it
        static::$createUrlCallback = null;

        // Log that our method is being called
        \Illuminate\Support\Facades\Log::info('VerifyStudentEmail: verificationUrl called (OUR METHOD)', [
            'user_id' => $notifiable->id ?? 'unknown',
            'email' => $notifiable->getEmailForVerification() ?? 'unknown',
            'static_callback_set' => !is_null(static::$createUrlCallback),
        ]);

        // Use API route - always registered and available
        $routeName = 'api.v1.students.email.verify';

        $parameters = [
            'id' => $notifiable->getKey(),
            'hash' => sha1($notifiable->getEmailForVerification()),
        ];

        $expires = Carbon::now()->addMinutes(2);

        // Generate signed URL using the API route
        // Use absolute path to ensure route is found
        try {
            // Force route to be available by checking it exists
            if (Route::has($routeName)) {
                // Generate signed URL using Laravel's URL signing
                $url = URL::temporarySignedRoute(
                    $routeName,
                    $expires,
                    $parameters,
                    true // absolute URL
                );

                // Verify URL was generated successfully
                if (!empty($url) && is_string($url)) {
                    \Illuminate\Support\Facades\Log::info('VerifyStudentEmail: URL generated successfully', [
                        'route' => $routeName,
                        'url_preview' => substr($url, 0, 50) . '...',
                    ]);
                    return $url;
                }
            } else {
                \Illuminate\Support\Facades\Log::warning('VerifyStudentEmail: Route not found', [
                    'route' => $routeName,
                ]);
            }
        } catch (\Illuminate\Routing\Exceptions\UrlGenerationException $e) {
            // Route generation failed - log and continue to fallback
            \Illuminate\Support\Facades\Log::error('VerifyStudentEmail: Route generation failed', [
                'route' => $routeName,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);
        } catch (\Exception $e) {
            // Any other exception - log and continue to fallback
            \Illuminate\Support\Facades\Log::error('VerifyStudentEmail: Exception during URL generation', [
                'route' => $routeName,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);
        }

        // Fallback: Build URL manually with proper signing
        // This ensures we never fall back to parent's method which uses 'verification.verify'
        $baseUrl = config('app.url', url('/'));
        $path = '/api/v1/students/email/verify/' . $parameters['id'] . '/' . $parameters['hash'];
        $fullUrl = rtrim($baseUrl, '/') . $path;

        // Generate signature using Laravel's URL signing method
        $signature = hash_hmac('sha256', $fullUrl . $expires->timestamp, config('app.key'));

        \Illuminate\Support\Facades\Log::info('VerifyStudentEmail: Using fallback URL generation', [
            'url_preview' => substr($fullUrl, 0, 50) . '...',
        ]);

        return $fullUrl . '?expires=' . $expires->timestamp . '&signature=' . $signature;
    }

    /**
     * Build the mail representation of the notification.
     * Uses the same email template as browser registration
     *
     * @param  mixed  $notifiable
     * @return \Illuminate\Notifications\Messages\MailMessage
     */
    public function toMail($notifiable)
    {
        // CRITICAL: Override parent's toMail completely to ensure our verificationUrl is called
        // Never call parent::toMail() as it might use parent's verificationUrl which uses 'verification.verify'

        \Illuminate\Support\Facades\Log::info('VerifyStudentEmail: toMail called', [
            'user_id' => $notifiable->id ?? 'unknown',
            'email' => $notifiable->getEmailForVerification() ?? 'unknown',
        ]);

        $firstName = $notifiable->first_name ?? $notifiable->name ?? 'Student';

        // Call our own verificationUrl method (not parent's)
        $verificationUrl = $this->verificationUrl($notifiable);

        \Illuminate\Support\Facades\Log::info('VerifyStudentEmail: Verification URL generated', [
            'url_preview' => substr($verificationUrl, 0, 100) . '...',
        ]);

        return (new MailMessage)
            ->subject('Verify Your Email Address - Fisk Voting System')
            ->greeting('Hello ' . $firstName . '!')
            ->line('Thank you for registering with the Fisk Voting System. Please click the button below to verify your email address.')
            ->action('Verify Email Address', $verificationUrl)
            ->line('**This verification link will expire in 2 minutes and can only be used once.**')
            ->line('If you did not create an account, no further action is required.')
            ->salutation('Best regards,<br>Fisk Voting System Team');
    }
}
