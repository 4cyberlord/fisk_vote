<?php

namespace App\Services;

use App\Models\UserJwtSession;
use Illuminate\Http\Request;
use Tymon\JWTAuth\Facades\JWTAuth;
use Carbon\Carbon;

class SessionService
{
    /**
     * Parse user agent to extract device and browser info.
     */
    public function parseUserAgent(?string $userAgent): array
    {
        if (!$userAgent) {
            return ['device' => 'Unknown', 'browser' => 'Unknown'];
        }

        $device = 'Unknown';
        $browser = 'Unknown';

        // Detect device
        if (preg_match('/iPhone|iPad|iPod/i', $userAgent)) {
            $device = 'iOS';
        } elseif (preg_match('/Android/i', $userAgent)) {
            $device = 'Android';
        } elseif (preg_match('/Windows/i', $userAgent)) {
            $device = 'Windows';
        } elseif (preg_match('/Macintosh|Mac OS X/i', $userAgent)) {
            $device = 'macOS';
        } elseif (preg_match('/Linux/i', $userAgent)) {
            $device = 'Linux';
        }

        // Detect browser
        if (preg_match('/Chrome/i', $userAgent) && !preg_match('/Edg|OPR/i', $userAgent)) {
            $browser = 'Chrome';
        } elseif (preg_match('/Firefox/i', $userAgent)) {
            $browser = 'Firefox';
        } elseif (preg_match('/Safari/i', $userAgent) && !preg_match('/Chrome/i', $userAgent)) {
            $browser = 'Safari';
        } elseif (preg_match('/Edg/i', $userAgent)) {
            $browser = 'Edge';
        } elseif (preg_match('/OPR/i', $userAgent)) {
            $browser = 'Opera';
        }

        return [
            'device' => $device,
            'browser' => $browser,
        ];
    }

    /**
     * Create or update a JWT session.
     */
    public function createSession(string $token, int $userId, Request $request): UserJwtSession
    {
        try {
            // Decode token to get JTI and expiration
            $payload = JWTAuth::setToken($token)->getPayload();
            // JWT tokens may not have jti, so generate one from token hash
            $jti = $payload->get('jti') ?? $this->generateJti($token);
            $expiresAt = $payload->get('exp') ? Carbon::createFromTimestamp($payload->get('exp')) : now()->addMinutes(config('jwt.ttl', 60));

            // Parse user agent
            $deviceInfo = $this->parseUserAgent($request->userAgent());

            // Mark all other sessions as not current
            UserJwtSession::where('user_id', $userId)
                ->where('is_current', true)
                ->update(['is_current' => false]);

            // Create or update session
            $session = UserJwtSession::updateOrCreate(
                [
                    'jti' => $jti,
                    'user_id' => $userId,
                ],
                [
                    'ip_address' => $request->ip(),
                    'user_agent' => $request->userAgent(),
                    'device_type' => $deviceInfo['device'],
                    'browser' => $deviceInfo['browser'],
                    'last_activity' => now(),
                    'expires_at' => $expiresAt,
                    'is_current' => true,
                ]
            );

            return $session;
        } catch (\Exception $e) {
            \Log::error('Failed to create session: ' . $e->getMessage());
            // Return a fallback session if creation fails
            return new UserJwtSession([
                'user_id' => $userId,
                'jti' => $this->generateJti($token),
                'device_type' => 'Unknown',
                'browser' => 'Unknown',
            ]);
        }
    }

    /**
     * Generate a JTI from token if not present.
     */
    public function generateJti(string $token): string
    {
        // Use first 32 chars of token hash as JTI
        return substr(md5($token), 0, 32);
    }

    /**
     * Update last activity for a session.
     */
    public function updateLastActivity(string $jti): void
    {
        try {
            UserJwtSession::where('jti', $jti)
                ->update(['last_activity' => now()]);
        } catch (\Exception $e) {
            // Silently fail - don't break requests
        }
    }

    /**
     * Get all active sessions for a user.
     */
    public function getUserSessions(int $userId): \Illuminate\Database\Eloquent\Collection
    {
        return UserJwtSession::where('user_id', $userId)
            ->active()
            ->orderBy('last_activity', 'desc')
            ->get();
    }

    /**
     * Revoke a specific session by JTI.
     */
    public function revokeSession(string $jti, int $userId): bool
    {
        try {
            $session = UserJwtSession::where('jti', $jti)
                ->where('user_id', $userId)
                ->first();

            if ($session) {
                // Invalidate the token if possible
                try {
                    $token = JWTAuth::setToken($session->jti)->getToken();
                    JWTAuth::invalidate($token);
                } catch (\Exception $e) {
                    // Token might already be invalid, continue
                }

                $session->delete();
                return true;
            }

            return false;
        } catch (\Exception $e) {
            \Log::error('Failed to revoke session: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Revoke all sessions except current for a user.
     */
    public function revokeAllOtherSessions(int $userId, string $currentJti): int
    {
        try {
            $sessions = UserJwtSession::where('user_id', $userId)
                ->where('jti', '!=', $currentJti)
                ->get();

            $count = 0;
            foreach ($sessions as $session) {
                try {
                    $token = JWTAuth::setToken($session->jti)->getToken();
                    JWTAuth::invalidate($token);
                } catch (\Exception $e) {
                    // Token might already be invalid, continue
                }
                $session->delete();
                $count++;
            }

            return $count;
        } catch (\Exception $e) {
            \Log::error('Failed to revoke all other sessions: ' . $e->getMessage());
            return 0;
        }
    }

    /**
     * Revoke all sessions for a user.
     */
    public function revokeAllSessions(int $userId): int
    {
        try {
            $sessions = UserJwtSession::where('user_id', $userId)->get();

            $count = 0;
            foreach ($sessions as $session) {
                // Delete session record
                // The tokens will naturally expire and won't be recognized
                $session->delete();
                $count++;
            }

            return $count;
        } catch (\Exception $e) {
            \Log::error('Failed to revoke all sessions: ' . $e->getMessage());
            return 0;
        }
    }
}

