<?php

namespace App\Notifications\Channels;

use App\Models\EmailSetting;
use Illuminate\Notifications\Notification;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Log;
use Illuminate\Mail\Message;

class CustomMailChannel
{
    /**
     * Send the given notification.
     *
     * @param  mixed  $notifiable
     * @param  \Illuminate\Notifications\Notification  $notification
     * @return void
     */
    public function send($notifiable, Notification $notification)
    {
        try {
            Log::info('CustomMailChannel: Starting email send', [
                'notifiable_id' => $notifiable->id ?? 'unknown',
                'notifiable_email' => $notifiable->getEmailForVerification() ?? 'unknown',
            ]);

            if (!method_exists($notification, 'toMail')) {
                Log::error('CustomMailChannel: Notification does not have toMail method');
                return;
            }

            // Call toMail method - it exists because we checked above
            /** @var \Illuminate\Notifications\Messages\MailMessage $message */
            $message = call_user_func([$notification, 'toMail'], $notifiable);

            // Store verification URL for later use in email templates
            $verificationUrl = null;
            if (property_exists($message, 'actionUrl')) {
                $verificationUrl = $message->actionUrl;
            } elseif (method_exists($message, 'actionUrl')) {
                $verificationUrl = $message->actionUrl();
            }

            // Get email settings
            $emailSettings = EmailSetting::getSettings();
            $emailService = $emailSettings->email_service ?? 'smtp';

            Log::info('CustomMailChannel: Email service determined', [
                'service' => $emailService,
                'has_smtp_host' => !empty($emailSettings->smtp_host),
                'has_mailtrap_key' => !empty($emailSettings->mailtrap_api_key),
            ]);

            // Get from email and name
            // For production Mailtrap, use no-reply@ctarlabs.com as default
            $fromEmail = \App\Helpers\SettingsHelper::contactEmail() ?? 'no-reply@ctarlabs.com';
            $fromName = \App\Helpers\SettingsHelper::systemName() ?? config('mail.from.name', 'Fisk Voting System');

            // Ensure production emails use the correct from address
            if ($emailService === 'mailtrap' && !($emailSettings->mailtrap_use_sandbox ?? true)) {
                // Production mode - ensure we use no-reply@ctarlabs.com
                if (!str_ends_with($fromEmail, '@ctarlabs.com') && !str_ends_with($fromEmail, '@fisk.edu')) {
                    $fromEmail = 'no-reply@ctarlabs.com';
                    Log::info('CustomMailChannel: Overriding from email to production address', [
                        'new_from' => $fromEmail,
                    ]);
                }
            }

            // Use Mailtrap Production API if sandbox is disabled (sends to real recipients)
            // Otherwise use SMTP (which goes to Mailtrap inbox for testing)
            $isSandboxEnabled = $emailSettings->mailtrap_use_sandbox ?? true;
            $shouldUseProductionApi = ($emailService === 'mailtrap' && !$isSandboxEnabled);

            Log::info('CustomMailChannel: Email routing decision', [
                'email_service' => $emailService,
                'mailtrap_use_sandbox' => $isSandboxEnabled,
                'should_use_production_api' => $shouldUseProductionApi,
                'has_smtp_host' => !empty($emailSettings->smtp_host),
                'has_mailtrap_api_key' => !empty($emailSettings->mailtrap_api_key),
            ]);

            // Check API key by accessing raw attribute (accessor might return null)
            $hasApiKeyRaw = !empty($emailSettings->getAttributes()['mailtrap_api_key'] ?? null);
            $hasApiKeyAccessor = !empty($emailSettings->mailtrap_api_key);

            if ($shouldUseProductionApi && ($hasApiKeyRaw || $hasApiKeyAccessor)) {
                // Production mode - use Mailtrap API to send to real recipients
                Log::info('CustomMailChannel: Using Mailtrap Production API (sandbox disabled)', [
                    'to' => $notifiable->getEmailForVerification(),
                    'from' => $fromEmail,
                    'has_api_key_raw' => $hasApiKeyRaw,
                    'has_api_key_accessor' => $hasApiKeyAccessor,
                ]);
                $this->sendViaMailtrap($notifiable, $notification, $message, $emailSettings, $fromEmail, $fromName);
            } elseif (!empty($emailSettings->smtp_host)) {
                // SMTP mode - goes to Mailtrap inbox (for testing)
                Log::info('CustomMailChannel: Using SMTP from admin dashboard settings', [
                    'host' => $emailSettings->smtp_host,
                    'port' => $emailSettings->smtp_port,
                    'note' => 'SMTP emails go to Mailtrap inbox, not real recipients',
                    'reason' => $shouldUseProductionApi ? 'Mailtrap API key missing' : 'Sandbox enabled or not Mailtrap service',
                ]);
                $this->sendViaSmtp($notifiable, $notification, $message, $emailSettings, $fromEmail, $fromName);
            } else {
                throw new \Exception('No email service configured. Please configure Mailtrap API or SMTP settings in Admin Panel → System → Email & Notification Settings.');
            }

            Log::info('CustomMailChannel: Email sent successfully', [
                'notifiable_email' => $notifiable->getEmailForVerification(),
                'service' => $emailService,
            ]);
        } catch (\Exception $e) {
            Log::error('CustomMailChannel: Failed to send email', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'notifiable_email' => $notifiable->getEmailForVerification() ?? 'unknown',
            ]);
            throw $e; // Re-throw to mark job as failed
        }
    }

    /**
     * Send email via Mailtrap API.
     */
    protected function sendViaMailtrap($notifiable, $notification, $message, $emailSettings, $fromEmail, $fromName)
    {
        // Refresh the model to ensure accessors work properly
        $emailSettings->refresh();

        // Get the API key (will be automatically decrypted by the accessor)
        $apiKey = $emailSettings->mailtrap_api_key;

        // If still null, try to get raw attribute and decrypt manually
        if (empty($apiKey)) {
            $rawKey = $emailSettings->getAttributes()['mailtrap_api_key'] ?? null;
            if ($rawKey) {
                try {
                    $apiKey = \Illuminate\Support\Facades\Crypt::decryptString($rawKey);
                    Log::info('Mailtrap: API key decrypted manually');
                } catch (\Exception $e) {
                    Log::error('Mailtrap: Failed to decrypt API key manually', ['error' => $e->getMessage()]);
                }
            }
        }

        Log::info('Mailtrap: API key check', [
            'has_api_key' => !empty($apiKey),
            'api_key_length' => $apiKey ? strlen($apiKey) : 0,
            'api_key_preview' => $apiKey ? substr($apiKey, 0, 10) . '...' : 'empty',
            'api_key_ends_with' => $apiKey ? '...' . substr($apiKey, -4) : 'empty',
        ]);

        if (empty($apiKey)) {
            Log::error('Mailtrap API key is not configured or could not be decrypted', [
                'has_raw_key' => !empty($emailSettings->getAttributes()['mailtrap_api_key'] ?? null),
            ]);
            throw new \Exception('Mailtrap API key is not configured or could not be decrypted. Please check your Mailtrap settings in the admin panel and ensure the API key is valid. Try re-saving the API key.');
        }

        $isSandbox = $emailSettings->mailtrap_use_sandbox ?? true;
        $inboxId = $isSandbox ? ($emailSettings->mailtrap_inbox_id ?? null) : null;

        if ($isSandbox && empty($inboxId)) {
            Log::error('Mailtrap: Sandbox mode enabled but inbox ID not configured');
            throw new \Exception('Sandbox Inbox ID is required when sandbox mode is enabled. Please configure it in Email Settings.');
        }

        // For sandbox: use any email (goes to Mailtrap inbox)
        // For production: must use verified domain email (sends to real recipients)
        if ($isSandbox) {
            $fromAddress = 'sandbox@example.com';
            Log::info('Mailtrap: Using sandbox mode - emails will go to Mailtrap inbox');
        } else {
            // Production mode - use configured from email, defaulting to no-reply@ctarlabs.com
            $fromAddress = $fromEmail ?: 'no-reply@ctarlabs.com';

            // Ensure we're using the correct production email
            if (!str_ends_with($fromAddress, '@ctarlabs.com') && !str_ends_with($fromAddress, '@fisk.edu')) {
                Log::warning('Mailtrap Production: Using unverified domain email. Emails may be rejected.', [
                    'email' => $fromAddress,
                    'note' => 'Verify your domain in Mailtrap dashboard for best deliverability',
                ]);
            } else {
                Log::info('Mailtrap Production: Using verified domain email', ['email' => $fromAddress]);
            }
        }

        Log::info('Mailtrap: Configuration determined', [
            'is_sandbox' => $isSandbox,
            'from_address' => $fromAddress,
            'to_address' => $notifiable->getEmailForVerification(),
        ]);

        // Determine API endpoint
        // Mailtrap API v2 endpoints
        $apiUrl = $isSandbox
            ? "https://sandbox.api.mailtrap.io/api/send/{$inboxId}"
            : "https://send.api.mailtrap.io/api/send";

        Log::info('Mailtrap: Endpoint determined', [
            'url' => $apiUrl,
            'is_sandbox' => $isSandbox,
            'inbox_id' => $inboxId,
        ]);

        // Get subject from MailMessage
        $subject = $message->subject ?? 'Verify Your Email Address - Fisk Voting System';

        // Get verification URL (already extracted above, but check again if needed)
        if (empty($verificationUrl)) {
            if (property_exists($message, 'actionUrl')) {
                $verificationUrl = $message->actionUrl;
            } elseif (method_exists($message, 'actionUrl')) {
                $verificationUrl = $message->actionUrl();
            }
        }

        Log::info('CustomMailChannel: Preparing verification email', [
            'has_verification_url' => !empty($verificationUrl),
            'url_preview' => $verificationUrl ? substr($verificationUrl, 0, 50) . '...' : 'none',
        ]);

        // Get email content - use the email template with verification link
        $firstName = $notifiable->first_name ?? $notifiable->name ?? 'Student';
        $htmlContent = view('emails.verify-student-email', [
            'firstName' => $firstName,
            'verificationUrl' => $verificationUrl ?? '#',
        ])->render();

        // Create plain text version
        $textContent = $subject . "\n" . str_repeat("=", 50) . "\n\n";
        $textContent .= "Hello " . $firstName . "!\n\n";
        $textContent .= "Thank you for registering with the Fisk Voting System.\n\n";
        $textContent .= "Please verify your email address by clicking the link below:\n\n";
        $textContent .= ($verificationUrl ?? 'Verification link not available') . "\n\n";
        $textContent .= "This verification link will expire in 2 minutes and can only be used once.\n\n";
        $textContent .= "If you did not create an account, no further action is required.\n\n";
        $textContent .= "Best regards,\nFisk Voting System Team";

        // Build email payload
        $emailPayload = [
            'to' => [
                [
                    'email' => $notifiable->getEmailForVerification(),
                ],
            ],
            'from' => [
                'email' => $fromAddress,
                'name' => $fromName,
            ],
            'reply_to' => [
                'email' => $fromAddress,
                'name' => $fromName,
            ],
            'subject' => $subject,
            'text' => $textContent,
            'html' => $htmlContent,
            'category' => 'Email Verification',
            'headers' => [
                'X-Mailer' => 'Fisk Voting System',
                'X-Priority' => '3',
                'X-Message-Source' => 'ctarlabs.com',
                'List-Unsubscribe' => '<mailto:' . $fromAddress . '?subject=unsubscribe>',
                'List-Unsubscribe-Post' => 'List-Unsubscribe=One-Click',
            ],
            'custom_variables' => [
                'email_type' => 'verification',
                'service' => 'mailtrap',
                'timestamp' => now()->toIso8601String(),
            ],
        ];

        // Send via cURL
        $curl = curl_init();
        $apiKey = trim($apiKey);
        $apiKey = preg_replace('/\s+/', '', $apiKey);

        $headers = [
            "Accept: application/json",
            "Api-Token: {$apiKey}",
            "Content-Type: application/json",
        ];

        curl_setopt_array($curl, [
            CURLOPT_URL => $apiUrl,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_ENCODING => "",
            CURLOPT_MAXREDIRS => 10,
            CURLOPT_TIMEOUT => 30,
            CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
            CURLOPT_CUSTOMREQUEST => "POST",
            CURLOPT_POSTFIELDS => json_encode($emailPayload),
            CURLOPT_HTTPHEADER => $headers,
        ]);

        $response = curl_exec($curl);
        $err = curl_error($curl);
        $httpCode = curl_getinfo($curl, CURLINFO_HTTP_CODE);
        curl_close($curl);

        if ($err) {
            Log::error('Mailtrap cURL Error: ' . $err);
            throw new \Exception("Mailtrap cURL Error: {$err}");
        }

        if ($httpCode >= 400) {
            $responseData = json_decode($response, true);
            $errorMsg = $responseData['message'] ?? $responseData['errors'] ?? 'Unknown error';

            // Log detailed error information
            Log::error('Mailtrap API Error', [
                'http_code' => $httpCode,
                'response' => $responseData,
                'endpoint' => $apiUrl,
                'from_email' => $fromAddress,
                'to_email' => $notifiable->getEmailForVerification(),
                'is_sandbox' => $isSandbox,
                'api_key_length' => strlen($apiKey),
            ]);

            // Provide helpful error message for 401
            if ($httpCode === 401) {
                $helpMessage = $isSandbox
                    ? ' The Mailtrap API key may be invalid or expired. Please check your Mailtrap Sandbox API token in Email Settings.'
                    : ' The Mailtrap Production API key may be invalid, expired, or your domain may not be verified. Consider enabling Sandbox mode for testing.';
                throw new \Exception("Mailtrap API Error (HTTP 401 Unauthorized): " . (is_array($errorMsg) ? json_encode($errorMsg) : $errorMsg) . $helpMessage);
            }

            throw new \Exception("Mailtrap API Error (HTTP {$httpCode}): " . (is_array($errorMsg) ? json_encode($errorMsg) : $errorMsg));
        }

        // Log success
        Log::info('Mailtrap email sent successfully', [
            'to' => $notifiable->getEmailForVerification(),
            'http_code' => $httpCode,
            'is_sandbox' => $isSandbox,
        ]);
    }

    /**
     * Send email via SMTP.
     */
    protected function sendViaSmtp($notifiable, $notification, $message, $emailSettings, $fromEmail, $fromName)
    {
        if (empty($emailSettings->smtp_host)) {
            Log::error('SMTP Host is not configured');
            throw new \Exception('SMTP Host is not configured. Please configure your SMTP server settings in the admin panel.');
        }

        // Store original config
        $originalConfig = config('mail.mailers.smtp');

        // Use SMTP settings from admin dashboard
        $port = $emailSettings->smtp_port ?? 587;
        $encryption = $emailSettings->encryption_type ?? 'tls';

        // CRITICAL FIX: Mailtrap SMTP port 465 has SSL connection issues
        // Automatically use port 2525 with TLS for Mailtrap (their recommended and working port)
        if (str_contains(strtolower($emailSettings->smtp_host ?? ''), 'mailtrap')) {
            if ($port == 465) {
                // Port 465 doesn't work reliably with Mailtrap - switch to 2525
                Log::warning('CustomMailChannel: Mailtrap port 465 detected. Auto-switching to port 2525 with TLS for reliability.');
                $port = 2525;
                $encryption = 'tls';
            } elseif (empty($port) || $port == 587) {
                // Default to Mailtrap's recommended port
                $port = 2525;
                $encryption = 'tls';
            } elseif ($port == 2525) {
                // Ensure TLS for port 2525
                $encryption = 'tls';
            }
        } else {
            // For non-Mailtrap SMTP, respect configured settings but ensure encryption matches port
            if ($port == 465 && ($encryption == 'tls' || empty($encryption))) {
                $encryption = 'ssl'; // Port 465 requires SSL
            } elseif (($port == 2525 || $port == 587) && ($encryption == 'ssl' || empty($encryption))) {
                $encryption = 'tls'; // Port 2525/587 require TLS
            }
        }

        Log::info('CustomMailChannel: SMTP configuration', [
            'host' => $emailSettings->smtp_host,
            'port' => $port,
            'encryption' => $encryption,
            'has_username' => !empty($emailSettings->smtp_username),
            'has_password' => !empty($emailSettings->smtp_password),
        ]);

        // Update mail configuration dynamically
        config([
            'mail.mailers.smtp.host' => $emailSettings->smtp_host,
            'mail.mailers.smtp.port' => $port,
            'mail.mailers.smtp.encryption' => $encryption,
            'mail.mailers.smtp.username' => $emailSettings->smtp_username,
            'mail.mailers.smtp.password' => $emailSettings->smtp_password,
            'mail.mailers.smtp.timeout' => 30,
        ]);

        // Get mail manager and clear cache
        $mailManager = app('mail.manager');
        $mailManager->forgetMailers();

        try {
            // Get subject from MailMessage
            $subject = $message->subject ?? 'Verify Your Email Address - Fisk Voting System';

            // Get verification URL (already extracted above, but check again if needed)
            if (empty($verificationUrl)) {
                if (property_exists($message, 'actionUrl')) {
                    $verificationUrl = $message->actionUrl;
                } elseif (method_exists($message, 'actionUrl')) {
                    $verificationUrl = $message->actionUrl();
                }
            }

            Log::info('CustomMailChannel: Preparing verification email via SMTP', [
                'has_verification_url' => !empty($verificationUrl),
                'url_preview' => $verificationUrl ? substr($verificationUrl, 0, 50) . '...' : 'none',
            ]);

            // Get email content using the template with verification link
            $firstName = $notifiable->first_name ?? $notifiable->name ?? 'Student';
            $htmlContent = view('emails.verify-student-email', [
                'firstName' => $firstName,
                'verificationUrl' => $verificationUrl ?? '#',
            ])->render();

            // Create plain text version
            $textContent = $subject . "\n" . str_repeat("=", 50) . "\n\n";
            $textContent .= "Hello " . $firstName . "!\n\n";
            $textContent .= "Thank you for registering with the Fisk Voting System.\n\n";
            $textContent .= "Please verify your email address by clicking the link below:\n\n";
            $textContent .= ($verificationUrl ?? 'Verification link not available') . "\n\n";
            $textContent .= "This verification link will expire in 2 minutes and can only be used once.\n\n";
            $textContent .= "If you did not create an account, no further action is required.\n\n";
            $textContent .= "Best regards,\nFisk Voting System Team";

            // Send email using the configured SMTP with both HTML and plain text
            Mail::mailer('smtp')->send([], [], function (Message $mailMessage) use ($notifiable, $subject, $htmlContent, $textContent, $fromEmail, $fromName) {
                $mailMessage->from($fromEmail, $fromName)
                    ->to($notifiable->getEmailForVerification())
                    ->subject($subject)
                    ->html($htmlContent)
                    ->text($textContent);
            });

            Log::info('CustomMailChannel: SMTP email sent successfully', [
                'to' => $notifiable->getEmailForVerification(),
                'subject' => $subject,
                'from' => $fromEmail,
                'has_verification_url' => !empty($verificationUrl),
                'host' => $emailSettings->smtp_host,
                'port' => $port,
                'encryption' => $encryption,
                'IMPORTANT' => 'Emails sent via Mailtrap SMTP go to Mailtrap inbox, NOT recipient email! Check Mailtrap dashboard.',
            ]);
        } finally {
            // Restore original config
            config(['mail.mailers.smtp' => $originalConfig]);
            $mailManager->forgetMailers();
        }
    }
}

