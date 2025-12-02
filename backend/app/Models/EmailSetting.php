<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Crypt;

class EmailSetting extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'email_service',
        'smtp_host',
        'smtp_port',
        'encryption_type',
        'smtp_username',
        'smtp_password',
        'mailtrap_api_key',
        'mailtrap_use_sandbox',
        'mailtrap_inbox_id',
        'voter_registration_email',
        'email_verification',
        'password_reset',
        'election_announcement',
        'upcoming_election_reminder',
        'thank_you_for_voting',
        'result_announcement_email',
        'send_daily_summary_to_admins',
        'send_voting_activity_alerts',
        'notify_users_when_election_opens',
        'notify_eligible_voters_before_election_ends',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected function casts(): array
    {
        return [
            'smtp_port' => 'integer',
            'mailtrap_use_sandbox' => 'boolean',
            'send_daily_summary_to_admins' => 'boolean',
            'send_voting_activity_alerts' => 'boolean',
            'notify_users_when_election_opens' => 'boolean',
            'notify_eligible_voters_before_election_ends' => 'boolean',
        ];
    }

    /**
     * Get or create the singleton settings instance.
     */
    public static function getSettings(): self
    {
        return static::firstOrCreate(['id' => 1]);
    }

    /**
     * Encrypt the SMTP password before saving.
     */
    public function setSmtpPasswordAttribute($value): void
    {
        if ($value) {
            $this->attributes['smtp_password'] = Crypt::encryptString($value);
        }
    }

    /**
     * Decrypt the SMTP password when retrieving.
     */
    public function getSmtpPasswordAttribute($value): ?string
    {
        if ($value) {
            try {
                return Crypt::decryptString($value);
            } catch (\Exception $e) {
                return null;
            }
        }
        return null;
    }

    /**
     * Encrypt the Mailtrap API key before saving.
     */
    public function setMailtrapApiKeyAttribute($value): void
    {
        if ($value) {
            $this->attributes['mailtrap_api_key'] = Crypt::encryptString($value);
        }
    }

    /**
     * Decrypt the Mailtrap API key when retrieving.
     */
    public function getMailtrapApiKeyAttribute($value): ?string
    {
        if ($value) {
            try {
                return Crypt::decryptString($value);
            } catch (\Exception $e) {
                return null;
            }
        }
        return null;
    }
}
