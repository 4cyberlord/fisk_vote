@if(session()->has('registered') || session()->has('registration_success') || request()->query('registered'))
    @php
        $email = session('registration_email') ?? request()->query('email') ?? 'your email address';
        $emailSent = session('email_sent') ?? request()->query('email_sent', true);
        if (is_string($emailSent)) {
            $emailSent = $emailSent === 'true' || $emailSent === '1';
        }
    @endphp
    
    @if($emailSent !== false && $emailSent !== 'false')
        <script>
            // Show notification directly using browser event
            function showRegistrationNotification() {
                var message = '<strong>Registration Successful!</strong><br>';
                message += 'Please check your email inbox (including spam folder) for a verification email sent to <strong>{{ $email }}</strong>. ';
                message += 'Click the verification link in the email to activate your account.<br>';
                message += '<strong>Important:</strong> The verification link expires in 2 minutes and can only be used once. ';
                message += '<strong>You must verify your email before you can log in and access the application.</strong>';
                
                // Dispatch browser event that the global notifications component listens to
                window.dispatchEvent(new CustomEvent('notify', { 
                    detail: { 
                        message: message, 
                        type: 'success' 
                    } 
                }));
            }
            
            // Try multiple times to ensure it shows
            setTimeout(showRegistrationNotification, 100);
            setTimeout(showRegistrationNotification, 500);
            setTimeout(showRegistrationNotification, 1000);
            
            // Also try when DOM is ready
            if (document.readyState === 'loading') {
                document.addEventListener('DOMContentLoaded', showRegistrationNotification);
            } else {
                showRegistrationNotification();
            }
        </script>
    @endif
@endif
