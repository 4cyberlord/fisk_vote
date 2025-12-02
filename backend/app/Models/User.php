<?php

namespace App\Models;

use Illuminate\Contracts\Auth\MustVerifyEmail;
use Filament\Models\Contracts\FilamentUser;
use Filament\Panel;
use Spatie\Permission\Traits\HasRoles;
use Illuminate\Notifications\Notifiable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Tymon\JWTAuth\Contracts\JWTSubject;

class User extends Authenticatable implements FilamentUser, MustVerifyEmail, JWTSubject
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasFactory, Notifiable, HasRoles;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'first_name',
        'last_name',
        'middle_initial',
        'student_id',
        'email',
        'university_email',
        'personal_email',
        'phone_number',
        'profile_photo',
        'address',
        'department',
        'major',
        'class_level',
        'enrollment_status',
        'student_type',
        'citizenship_status',
        'password',
        'temporary_password',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    /**
     * Boot the model.
     */
    protected static function boot(): void
    {
        parent::boot();

        static::creating(function ($user) {
            // Set default role to Student if not already assigned
            if (!$user->hasAnyRole()) {
                $studentRole = \Spatie\Permission\Models\Role::firstOrCreate(['name' => 'Student', 'guard_name' => 'web']);
                $user->assignRole($studentRole);
            }
        });
    }

    /**
     * Get the user's full name.
     */
    public function getFullNameAttribute(): string
    {
        $name = trim("{$this->first_name} {$this->last_name}");
        if ($this->middle_initial) {
            $name = trim("{$this->first_name} {$this->middle_initial}. {$this->last_name}");
        }
        return $name;
    }

    /**
     * Get the votes cast by this user.
     */
    public function votes(): HasMany
    {
        return $this->hasMany(Vote::class, 'voter_id');
    }

    /**
     * Get the organizations the user belongs to.
     */
    public function organizations(): BelongsToMany
    {
        return $this->belongsToMany(Organization::class);
    }


    /**
     * Send the email verification notification.
     * Override to use our custom VerifyStudentEmail notification instead of default VerifyEmail
     *
     * @return void
     */
    public function sendEmailVerificationNotification()
    {
        $this->notify(new \App\Notifications\VerifyStudentEmail());
    }

    /**
     * Get the identifier that will be stored in the subject claim of the JWT.
     *
     * @return mixed
     */
    public function getJWTIdentifier()
    {
        return $this->getKey();
    }

    /**
     * Return a key value array, containing any custom claims to be added to the JWT.
     *
     * @return array
     */
    public function getJWTCustomClaims()
    {
        // Generate a unique JTI (JWT ID) for session tracking
        $jti = bin2hex(random_bytes(16)); // 32 character hex string
        
        return [
            'email' => $this->email,
            'email_verified' => $this->hasVerifiedEmail(),
            'jti' => $jti, // JWT ID for session management
        ];
    }

    /**
     * Determine if the user can access the Filament panel.
     */
    public function canAccessPanel(Panel $panel): bool
    {
        // Admin panel: Allow users with admin roles or users without Student role
        if ($panel->getId() === 'admin') {
            // Allow if user has admin roles
            if ($this->hasAnyRole(['Admin', 'Super Admin'])) {
                return true;
            }

            // Allow if user doesn't have Student role (for other staff/admin users)
            return !$this->hasRole('Student');
        }

        // Student panel: Only allow users with Student role, @my.fisk.edu email, and verified email
        if ($panel->getId() === 'student') {
            // Check if user has Student role
            if (!$this->hasRole('Student')) {
                return false;
            }

            // Check if email ends with @my.fisk.edu
            $email = $this->email ?? $this->university_email ?? '';
            if (!str_ends_with(strtolower($email), '@my.fisk.edu')) {
                return false;
            }

            // Check if email is verified
            return $this->hasVerifiedEmail();
        }

        // Default: deny access
        return false;
    }
}
