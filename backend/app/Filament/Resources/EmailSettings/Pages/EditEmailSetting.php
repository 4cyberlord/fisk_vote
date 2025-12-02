<?php

namespace App\Filament\Resources\EmailSettings\Pages;

use App\Filament\Resources\EmailSettings\EmailSettingResource;
use Filament\Actions\Action;
use Filament\Actions\ViewAction;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\EditRecord;
use Illuminate\Support\Facades\Mail;
use Illuminate\Mail\Message;

class EditEmailSetting extends EditRecord
{
    protected static string $resource = EmailSettingResource::class;

    protected function mutateFormDataBeforeFill(array $data): array
    {
        // Don't fill SMTP password for security - leave it empty so user can enter new one if needed
        $data['smtp_password'] = '';

        // Fill Mailtrap API key so user can see and edit it (decrypted by model accessor)
        // The API key is automatically decrypted by the EmailSetting model's getMailtrapApiKeyAttribute accessor
        if (!empty($this->record->mailtrap_api_key)) {
            $data['mailtrap_api_key'] = $this->record->mailtrap_api_key;
        }

        return $data;
    }

    protected function mutateFormDataBeforeSave(array $data): array
    {
        // Only update SMTP password if a new one is provided
        // If empty, remove it from the data so the existing encrypted password is preserved
        if (empty($data['smtp_password'])) {
            unset($data['smtp_password']);
        }

        // For Mailtrap API key: if it's empty or not provided, preserve the existing encrypted value
        // The model's setter will encrypt it if a value is provided
        if (empty($data['mailtrap_api_key']) || trim($data['mailtrap_api_key']) === '') {
            unset($data['mailtrap_api_key']);
        }

        return $data;
    }

    protected function getHeaderActions(): array
    {
        return [
            ViewAction::make(),
            Action::make('test_email')
                ->label('Test Email')
                ->icon('heroicon-o-paper-airplane')
                ->color('info')
                ->requiresConfirmation()
                ->modalHeading('Send Test Email')
                ->modalDescription('Enter an email address to send a test email using your configured email service.')
                ->form([
                    \Filament\Forms\Components\TextInput::make('test_email_address')
                        ->label('Email Address')
                        ->email()
                        ->required()
                        ->default(fn () => \Illuminate\Support\Facades\Auth::user()?->email ?? ''),
                ])
                ->action(function (array $data) {
                    try {
                        $emailService = $this->record->email_service ?? 'smtp';
                        // Use no-reply@ctarlabs.com for Mailtrap, or fallback to settings/config
                        $fromEmail = $emailService === 'mailtrap'
                            ? 'no-reply@ctarlabs.com'
                            : (\App\Helpers\SettingsHelper::contactEmail() ?? config('mail.from.address', 'noreply@fisk.edu'));
                        $fromName = \App\Helpers\SettingsHelper::systemName() ?? config('mail.from.name', 'Fisk Voting System');

                        // Professional HTML email content optimized for deliverability and spam prevention
                        // Following best practices: proper structure, no spam triggers, accessible design
                        $htmlContent = '
                            <!DOCTYPE html>
                            <html lang="en">
                            <head>
                                <meta charset="UTF-8">
                                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
                                <title>Test Email - Fisk Voting System</title>
                            </head>
                            <body style="font-family: Arial, Helvetica, sans-serif; line-height: 1.6; color: #333333; margin: 0; padding: 0; background-color: #f4f4f4;">
                                <table role="presentation" cellpadding="0" cellspacing="0" border="0" style="width: 100%; border-collapse: collapse; background-color: #f4f4f4;">
                                    <tr>
                                        <td style="padding: 20px 0;" align="center">
                                            <table role="presentation" cellpadding="0" cellspacing="0" border="0" style="width: 600px; max-width: 100%; margin: 0 auto; background-color: #ffffff; border-collapse: collapse; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                                                <tr>
                                                    <td style="padding: 40px 30px; text-align: center; background-color: #3B82F6; border-radius: 8px 8px 0 0;">
                                                        <h1 style="color: #ffffff; margin: 0; font-size: 24px; font-weight: normal;">Test Email - Fisk Voting System</h1>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td style="padding: 30px;">
                                                        <p style="margin: 0 0 15px 0; font-size: 16px; color: #333333;">Hello,</p>
                                                        <p style="margin: 0 0 15px 0; font-size: 16px; color: #333333;">This is a test email from the Fisk Voting System.</p>
                                                        <p style="margin: 0 0 20px 0; font-size: 16px; color: #333333;">Your email service configuration is working correctly.</p>
                                                        <div style="background-color: #f8f9fa; padding: 15px; border-radius: 4px; margin: 20px 0;">
                                                            <p style="margin: 0; font-size: 14px; color: #666666;">
                                                                <strong>Email Service:</strong> ' . strtoupper(htmlspecialchars($emailService)) . '<br>
                                                                <strong>Sent at:</strong> ' . now()->format('F j, Y \a\t g:i A') . '
                                                            </p>
                                                        </div>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td style="padding: 20px 30px; background-color: #f8f9fa; border-radius: 0 0 8px 8px; text-align: center; border-top: 1px solid #e9ecef;">
                                                        <p style="margin: 0 0 10px 0; font-size: 12px; color: #999999;">This is an automated test email from the Fisk Voting System.</p>
                                                        <p style="margin: 0; font-size: 11px; color: #999999;">
                                                            If you have any questions, please contact us at ' . htmlspecialchars($fromEmail) . '
                                                        </p>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                            </body>
                            </html>
                        ';

                        // Comprehensive plain text version for better deliverability and accessibility
                        // Plain text is crucial for spam prevention and screen readers
                        $textContent = "Test Email - Fisk Voting System\n" .
                                     str_repeat("=", 50) . "\n\n" .
                                     "Hello,\n\n" .
                                     "This is a test email from the Fisk Voting System.\n\n" .
                                     "Your email service configuration is working correctly.\n\n" .
                                     str_repeat("-", 50) . "\n" .
                                     "Email Service: " . strtoupper($emailService) . "\n" .
                                     "Sent at: " . now()->format('F j, Y \a\t g:i A') . "\n" .
                                     str_repeat("-", 50) . "\n\n" .
                                     "This is an automated test email from the Fisk Voting System.\n\n" .
                                     "If you have any questions, please contact us at " . $fromEmail . "\n\n" .
                                     str_repeat("=", 50);

                        if ($emailService === 'mailtrap') {
                            // Use Mailtrap via direct cURL (matching the working curl implementation)
                            // The API key is automatically decrypted by the EmailSetting model accessor
                            // But we'll also try to decrypt manually if needed
                            $apiKey = $this->record->mailtrap_api_key;

                            // If accessor didn't decrypt (returns encrypted value), decrypt manually
                            if (!empty($apiKey) && (str_starts_with($apiKey, 'eyJ') || str_starts_with($apiKey, 'base64:'))) {
                                try {
                                    $apiKey = \Illuminate\Support\Facades\Crypt::decryptString($apiKey);
                                } catch (\Exception $e) {
                                    // If decryption fails, try getting raw attribute
                                    $rawKey = $this->record->getAttributes()['mailtrap_api_key'] ?? null;
                                    if ($rawKey) {
                                        try {
                                            $apiKey = \Illuminate\Support\Facades\Crypt::decryptString($rawKey);
                                        } catch (\Exception $e2) {
                                            throw new \Exception('Failed to decrypt Mailtrap API key. Please re-enter your API key in the settings.');
                                        }
                                    }
                                }
                            }

                            if (empty($apiKey)) {
                                throw new \Exception('Mailtrap API key is not configured. Please configure your Mailtrap settings first.');
                            }

                            // Trim whitespace from API key
                            $apiKey = trim($apiKey);

                            $isSandbox = $this->record->mailtrap_use_sandbox ?? true;
                            $inboxId = $isSandbox ? ($this->record->mailtrap_inbox_id ?? null) : null;

                            // Validate sandbox requirements
                            if ($isSandbox && empty($inboxId)) {
                                throw new \Exception('Sandbox Inbox ID is required when sandbox mode is enabled. Please enter your Mailtrap inbox ID.');
                            }

                            // For production, use the actual from email (must be from verified domain)
                            // For sandbox, any email works
                            $fromAddress = $isSandbox ? 'sandbox@example.com' : $fromEmail;

                            // Ensure we have a valid from email for production
                            if (!$isSandbox && empty($fromEmail)) {
                                throw new \Exception('From email address is required for production sending. Please configure it in Application Settings.');
                            }

                            // Determine the API endpoint based on sandbox/production mode
                            // Sandbox: https://sandbox.api.mailtrap.io/api/send/{inbox_id}
                            // Production: https://send.api.mailtrap.io/api/send
                            $apiUrl = $isSandbox
                                ? "https://sandbox.api.mailtrap.io/api/send/{$inboxId}"
                                : "https://send.api.mailtrap.io/api/send";

                            // Build the email payload with best practices for spam prevention
                            // Include both HTML and plain text versions (required for deliverability)
                            $emailPayload = [
                                'to' => [
                                    [
                                        'email' => $data['test_email_address'],
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
                                'subject' => $isSandbox ? '[SANDBOX] Test Email - Fisk Voting System' : 'Test Email - Fisk Voting System',
                                'text' => $textContent, // Plain text version (required for spam prevention)
                                'html' => $htmlContent, // HTML version
                                'category' => 'Test Email',
                                'headers' => [
                                    'X-Mailer' => 'Fisk Voting System',
                                    'X-Priority' => '3', // Normal priority (1=high, 3=normal, 5=low)
                                    'X-Message-Source' => 'ctarlabs.com',
                                    'List-Unsubscribe' => '<mailto:' . $fromAddress . '?subject=unsubscribe>', // Unsubscribe header for compliance
                                    'List-Unsubscribe-Post' => 'List-Unsubscribe=One-Click', // One-click unsubscribe
                                ],
                                'custom_variables' => [
                                    'email_type' => 'test',
                                    'service' => $emailService,
                                    'timestamp' => now()->toIso8601String(),
                                ],
                            ];

                            // Initialize cURL exactly as shown in the working example
                            $curl = curl_init();

                            // Ensure API key is properly trimmed and has no hidden characters
                            $apiKey = trim($apiKey);
                            $apiKey = preg_replace('/\s+/', '', $apiKey); // Remove all whitespace

                            // Build headers exactly as in the working curl example
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

                            // Handle cURL errors
                            if ($err) {
                                throw new \Exception("cURL Error: {$err}");
                            }

                            // Parse response
                            $responseData = json_decode($response, true);

                            // Check for API errors
                            if ($httpCode >= 400) {
                                // Extract error message from response
                                $errorMsg = 'Unknown error';
                                if (isset($responseData['errors']) && is_array($responseData['errors'])) {
                                    $errorMsg = is_array($responseData['errors'])
                                        ? implode(', ', array_map(function($err) {
                                            return is_array($err) ? json_encode($err) : $err;
                                        }, $responseData['errors']))
                                        : $responseData['errors'];
                                } elseif (isset($responseData['message'])) {
                                    $errorMsg = $responseData['message'];
                                } elseif (!empty($response)) {
                                    $errorMsg = $response;
                                }

                                // For 401 errors, provide detailed debugging info
                                if ($httpCode === 401) {
                                    $apiKeyLength = strlen($apiKey);
                                    $apiKeyPreview = $apiKeyLength > 0
                                        ? substr($apiKey, 0, 8) . '...' . substr($apiKey, -4)
                                        : 'EMPTY';

                                    $errorMsg .= ' | Response: ' . json_encode($responseData);
                                    $errorMsg .= " | API Key Length: {$apiKeyLength}";
                                    $errorMsg .= " | API Key Preview: {$apiKeyPreview}";
                                    $errorMsg .= " | Endpoint: {$apiUrl}";
                                    $errorMsg .= " | From Email: {$fromAddress}";

                                    // Additional troubleshooting
                                    if ($apiKeyLength === 0) {
                                        $errorMsg .= ' | ERROR: API key is empty!';
                                    } elseif ($apiKeyLength < 20) {
                                        $errorMsg .= ' | WARNING: API key seems too short (expected ~40+ characters)';
                                    }
                                }

                                throw new \Exception("Mailtrap API Error (HTTP {$httpCode}): {$errorMsg}");
                            }

                            // Success
                            Notification::make()
                                ->title('Test Email Sent')
                                ->body('Test email has been sent successfully via Mailtrap to ' . $data['test_email_address'] . '. ' . ($isSandbox ? 'Check your Mailtrap inbox.' : 'Please check your inbox (and spam folder).'))
                                ->success()
                                ->send();
                        } else {
                            // Use SMTP
                            if (empty($this->record->smtp_host)) {
                                throw new \Exception('SMTP Host is not configured. Please configure your SMTP server settings first.');
                            }

                            // Store original config
                            $originalConfig = config('mail.mailers.smtp');

                            // Update mail configuration dynamically
                            config([
                                'mail.mailers.smtp.host' => $this->record->smtp_host,
                                'mail.mailers.smtp.port' => $this->record->smtp_port ?? 587,
                                'mail.mailers.smtp.encryption' => $this->record->encryption_type ?? 'tls',
                                'mail.mailers.smtp.username' => $this->record->smtp_username,
                                'mail.mailers.smtp.password' => $this->record->smtp_password,
                                'mail.mailers.smtp.timeout' => 30,
                            ]);

                            // Get mail manager and clear cache
                            $mailManager = app('mail.manager');
                            $mailManager->forgetMailers();

                            // Use Mail facade with the updated configuration
                            Mail::mailer('smtp')->send([], [], function (Message $message) use ($data, $fromEmail, $fromName, $htmlContent) {
                                $message->from($fromEmail, $fromName)
                                    ->to($data['test_email_address'])
                                    ->subject('Test Email - Fisk Voting System')
                                    ->html($htmlContent);
                            });

                            // Restore original config
                            config(['mail.mailers.smtp' => $originalConfig]);
                            $mailManager->forgetMailers();

                            Notification::make()
                                ->title('Test Email Sent')
                                ->body('Test email has been sent successfully via SMTP to ' . $data['test_email_address'] . '. Please check your inbox (and spam folder).')
                                ->success()
                                ->send();
                        }
                    } catch (\Exception $e) {
                        $errorMessage = $e->getMessage();
                        $emailService = $this->record->email_service ?? 'smtp';

                        // Show the actual error message from the API response
                        // The error message already contains the detailed API response
                        // Only add additional context if it's a generic error
                        if ($emailService === 'mailtrap') {
                            if (str_contains($errorMessage, '401') || str_contains($errorMessage, 'Unauthorized')) {
                                $isSandbox = $this->record->mailtrap_use_sandbox ?? true;
                                $fromEmail = \App\Helpers\SettingsHelper::contactEmail() ?? config('mail.from.address', 'not set');

                                if (!$isSandbox) {
                                    $errorMessage = 'Unauthorized (401): ' . $errorMessage .
                                                   ' | Please verify: 1) Your API key is correct and has production sending permissions (get it from https://mailtrap.io/api-tokens), ' .
                                                   '2) Your domain is verified in Mailtrap, ' .
                                                   '3) The "from" email address (' . $fromEmail . ') is from your verified domain. ' .
                                                   '4) Make sure you\'re using the correct API token for production (not sandbox token).';
                                } else {
                                    $errorMessage = 'Unauthorized (401): ' . $errorMessage .
                                                   ' | Please verify your Mailtrap API key is correct and has sandbox permissions. Get your API key from https://mailtrap.io/api-tokens';
                                }
                            }
                        }

                        Notification::make()
                            ->title('Test Email Failed')
                            ->body('Failed to send test email: ' . $errorMessage)
                            ->danger()
                            ->persistent()
                            ->send();
                    }
                }),
        ];
    }
}
