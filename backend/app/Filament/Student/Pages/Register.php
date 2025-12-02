<?php

namespace App\Filament\Student\Pages;

use Filament\Auth\Pages\Register as BaseRegister;
use Filament\Auth\Events\Registered;
use Filament\Forms\Components\Checkbox;
use Filament\Forms\Components\TextInput;
use Filament\Notifications\Notification;
use Filament\Schemas\Schema;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Components\View;
use Filament\Schemas\Components\Wizard;
use Filament\Schemas\Components\Wizard\Step;
use Filament\Support\Enums\Width;
use Filament\Actions\Action;
use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\HtmlString;
use Illuminate\Validation\Rules\Password;
use Spatie\Permission\Models\Role;
use App\Notifications\VerifyStudentEmail;

class Register extends BaseRegister
{
    protected Width | string | null $maxWidth = '5xl';

    public ?string $registrationEmail = null;
    public ?int $registeredUserId = null;
    public bool $registrationCompleted = false;

    public function mount(): void
    {
        // Check if user was redirected here after email verification
        if (session()->has('verified')) {
            // Get user ID from session (user might not be authenticated)
            $userId = session()->get('verified_user_id');

            if ($userId) {
                // Find the user who just verified their email
                $user = \App\Models\User::find($userId);

                if ($user && $user->hasVerifiedEmail()) {
                    // Set the registered user ID so the wizard can track verification status
                    $this->registeredUserId = $user->id;
                    $this->registrationEmail = $user->email;
                    $this->registrationCompleted = true;

                    // Show success notification
                    Notification::make()
                        ->title('Email Verified Successfully!')
                        ->body('Your email has been verified. You can now log in to access your account.')
                        ->success()
                        ->send();

                    // Navigate to Verification step after email verification
                    $this->js('
                        setTimeout(() => {
                            // Clean URL first - remove any query parameters
                            if (window.history && window.history.replaceState) {
                                const cleanUrl = window.location.pathname;
                                window.history.replaceState({}, document.title, cleanUrl);
                            }

                            // Find the Verification step button
                            let targetButton = null;
                            const allButtons = Array.from(document.querySelectorAll("button"));

                            // Look for buttons with "Verification" or "Email Verification" text
                            targetButton = allButtons.find(btn => {
                                const text = btn.textContent.trim();
                                return text.includes("Verification") ||
                                       text.includes("Email Verification");
                            });

                            // Also try finding by wizard step tabs/indicators
                            if (!targetButton) {
                                const wizardTabs = document.querySelectorAll("[role=\"tab\"], [data-wizard-step]");
                                wizardTabs.forEach(tab => {
                                    const text = tab.textContent.trim() || tab.getAttribute("aria-label") || "";
                                    if (text.includes("Verification") || text.includes("Email Verification")) {
                                        targetButton = tab;
                                    }
                                });
                            }

                            // Click the target button if found
                            if (targetButton && !targetButton.disabled) {
                                targetButton.click();
                                // Clean URL again after clicking
                                setTimeout(() => {
                                    if (window.history && window.history.replaceState) {
                                        const cleanUrl = window.location.pathname;
                                        window.history.replaceState({}, document.title, cleanUrl);
                                    }
                                }, 300);
                            }
                        }, 500);
                    ');
                }
            }
        }
    }

    public function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                Wizard::make([
                    Step::make('Registration')
                        ->label('Create Account')
                        ->icon('heroicon-o-user-plus')
                        ->description('Fill in your personal information')
                        ->schema([
                            Section::make('Personal Information')
                                ->description('Use your legal name as it appears on university records.')
                                ->columns(12)
                                ->schema([
                                    TextInput::make('first_name')
                                        ->label('First Name')
                                        ->required()
                                        ->maxLength(255)
                                        ->autofocus()
                                        ->columnSpan([
                                            'sm' => 12,
                                            'md' => 6,
                                            'lg' => 4,
                                        ]),

                                    TextInput::make('middle_initial')
                                        ->label('Middle Name')
                                        ->maxLength(255)
                                        ->placeholder('Enter your middle name')
                                        ->helperText('Optional')
                                        ->columnSpan([
                                            'sm' => 12,
                                            'md' => 6,
                                            'lg' => 4,
                                        ]),

                                    TextInput::make('last_name')
                                        ->label('Last Name')
                                        ->required()
                                        ->maxLength(255)
                                        ->columnSpan([
                                            'sm' => 12,
                                            'md' => 12,
                                            'lg' => 4,
                                        ]),
                                ]),

                            Section::make('University Details')
                                ->description('We use your Fisk credentials to verify student eligibility.')
                                ->columns(12)
                                ->schema([
                                    TextInput::make('student_id')
                                        ->label('Student ID')
                                        ->required()
                                        ->maxLength(255)
                                        ->unique($this->getUserModel(), 'student_id')
                                        ->helperText('Your unique student identification number (digits only).')
                                        ->rules(['regex:/^\d+$/'])
                                        ->validationMessages([
                                            'regex' => 'Student ID must contain only numbers',
                                            'unique' => 'This student ID is already registered',
                                        ])
                                        ->columnSpan([
                                            'sm' => 12,
                                            'md' => 6,
                                        ]),

                                    TextInput::make('email')
                                        ->label('Email (Fisk Email)')
                                        ->email()
                                        ->required()
                                        ->maxLength(255)
                                        ->unique($this->getUserModel())
                                        ->helperText('Please use your @my.fisk.edu email address')
                                        ->rules([
                                            'ends_with:@my.fisk.edu',
                                        ])
                                        ->validationMessages([
                                            'ends_with' => 'Please use your Fisk University email address ending with @my.fisk.edu',
                                        ])
                                        ->columnSpan([
                                            'sm' => 12,
                                            'md' => 6,
                                        ]),
                                ]),

                            Section::make('Security')
                                ->description('Create a secure password for your voting account.')
                                ->columns(12)
                                ->schema([
                                    TextInput::make('password')
                                        ->label('Password')
                                        ->password()
                                        ->revealable(filament()->arePasswordsRevealable())
                                        ->required()
                                        ->rule(Password::default())
                                        ->showAllValidationMessages()
                                        ->dehydrateStateUsing(fn ($state) => Hash::make($state))
                                        ->same('passwordConfirmation')
                                        ->validationAttribute('password')
                                        ->columnSpan([
                                            'sm' => 12,
                                            'md' => 6,
                                        ]),

                                    TextInput::make('passwordConfirmation')
                                        ->label('Confirm Password')
                                        ->password()
                                        ->revealable(filament()->arePasswordsRevealable())
                                        ->required()
                                        ->dehydrated(false)
                                        ->columnSpan([
                                            'sm' => 12,
                                            'md' => 6,
                                        ]),
                                ]),

                            Section::make('Agreement')
                                ->description('You must agree to the Fisk Voting Terms & Policies to continue.')
                                ->columns(12)
                                ->schema([
                                    Checkbox::make('accept_terms')
                                        ->label('I accept the Terms of Service and Voting Policy')
                                        ->required()
                                        ->accepted()
                                        ->validationMessages([
                                            'accepted' => 'You must accept the Terms of Service and Voting Policy to register.',
                                        ])
                                        ->columnSpan([
                                            'sm' => 12,
                                        ]),
                                ]),
                        ])
                        ->afterValidation(function () {
                            // Process registration when moving from Step 1 to Step 2
                            if (!$this->registrationCompleted) {
                                $this->processRegistration();
                            }
                        }),

                    Step::make('Verification')
                        ->label('Email Verification')
                        ->icon('heroicon-o-envelope')
                        ->description('Verify your email address')
                        ->schema([
                            Section::make('Verification Status')
                                ->description('We\'ve sent a verification email to your inbox.')
                                ->schema([
                                    View::make('filament.student.pages.verification-waiting'),
                                ]),
                        ])
                        ->afterValidation(function () {
                            // Check if email is verified before allowing wizard completion
                            if ($this->registeredUserId) {
                                $user = \App\Models\User::find($this->registeredUserId);
                                $user?->refresh();

                                if (!$user || !$user->hasVerifiedEmail()) {
                                    Notification::make()
                                        ->title('Email Not Verified')
                                        ->body('Please check your email and click the verification link before proceeding.')
                                        ->warning()
                                        ->persistent()
                                        ->send();

                                    throw new \Filament\Support\Exceptions\Halt();
                                }
                            }
                        }),
                ])
                ->submitAction(\Filament\Actions\Action::make('submit')
                    ->label('Complete Registration')
                    ->submit('register')),
            ]);
    }

    protected function processRegistration(): void
    {
        try {
            $this->rateLimit(2);
        } catch (\DanHarrin\LivewireRateLimiting\Exceptions\TooManyRequestsException $exception) {
            $this->getRateLimitedNotification($exception)?->send();
            throw new \Filament\Support\Exceptions\Halt();
        }

        $user = $this->wrapInDatabaseTransaction(function (): Model {
            $data = $this->form->getState();
            $data = $this->mutateFormDataBeforeRegister($data);

            $user = $this->handleRegistration($data);
            $this->form->model($user)->saveRelationships();

            return $user;
        });

        // Fire registered event
        // This automatically triggers SendEmailVerificationNotification listener
        // which calls $user->sendEmailVerificationNotification()
        // We've overridden that method in User model to use VerifyStudentEmail
        event(new Registered($user));

        // Store registration data
        $this->registrationEmail = $user->email;
        $this->registeredUserId = $user->id;
        $this->registrationCompleted = true;

        Log::info('Register: Registration completed', [
            'user_id' => $user->id,
            'email' => $user->email,
        ]);
    }

    protected function mutateFormDataBeforeRegister(array $data): array
    {
        // Set email from the form (already validated to be @my.fisk.edu)
        $data['university_email'] = $data['email'];

        // Combine first_name, middle_initial (middle name), and last_name into name field
        $nameParts = [];
        if (!empty($data['first_name'])) {
            $nameParts[] = trim($data['first_name']);
        }
        if (!empty($data['middle_initial'])) {
            $nameParts[] = trim($data['middle_initial']); // Middle name (no period)
        }
        if (!empty($data['last_name'])) {
            $nameParts[] = trim($data['last_name']);
        }
        $data['name'] = implode(' ', $nameParts);

        // Remove fields that aren't in the database
        unset($data['passwordConfirmation']);
        unset($data['accept_terms']);

        return $data;
    }

    protected function handleRegistration(array $data): \Illuminate\Database\Eloquent\Model
    {
        $user = parent::handleRegistration($data);

        // Ensure the user has the Student role
        if (!$user->hasRole('Student')) {
            $studentRole = Role::firstOrCreate(['name' => 'Student', 'guard_name' => 'web']);
            $user->assignRole($studentRole);
        }

        return $user;
    }

    /**
     * Override the register method - registration is now handled in processRegistration()
     * This method is called when the wizard is submitted (on the last step)
     */
    public function register(): ?\Filament\Auth\Http\Responses\Contracts\RegistrationResponse
    {
        // Registration is already completed in processRegistration()
        // This is called when user completes the wizard
        // Redirect to login page
        $panel = \Filament\Facades\Filament::getPanel('student');
        $loginUrl = $panel->getLoginUrl();

        return new class($loginUrl) implements \Filament\Auth\Http\Responses\Contracts\RegistrationResponse {
            public function __construct(
                private string $loginUrl
            ) {}

            public function toResponse($request)
            {
                return redirect()->away($this->loginUrl);
            }
        };
    }

    public function getTitle(): string | \Illuminate\Contracts\Support\Htmlable
    {
        return 'Student Registration';
    }

    public function getHeading(): string | \Illuminate\Contracts\Support\Htmlable | null
    {
        return 'Create Your Student Account';
    }

    public function getSubheading(): string | \Illuminate\Contracts\Support\Htmlable | null
    {
        if (!filament()->hasLogin()) {
            return null;
        }

        return new \Illuminate\Support\HtmlString(
            'Already have an account? ' .
            '<a href="' . filament()->getLoginUrl() . '" class="text-primary-600 hover:text-primary-700 underline">Sign in here</a>'
        );
    }

    /**
     * Check email verification status (called by Alpine.js polling)
     */
    public function checkEmailVerification(): bool
    {
        if (!$this->registeredUserId) {
            return false;
        }

        $user = \App\Models\User::find($this->registeredUserId);
        $user?->refresh();

        return $user && $user->hasVerifiedEmail();
    }
}
