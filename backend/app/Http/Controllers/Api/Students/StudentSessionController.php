<?php

namespace App\Http\Controllers\Api\Students;

use App\Http\Controllers\Controller;
use App\Services\SessionService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Tymon\JWTAuth\Facades\JWTAuth;

class StudentSessionController extends Controller
{
    protected $sessionService;

    public function __construct(SessionService $sessionService)
    {
        $this->sessionService = $sessionService;
    }

    /**
     * Get all active sessions for the authenticated user.
     *
     * GET /api/v1/students/me/sessions
     */
    public function getMySessions(Request $request)
    {
        try {
            $user = auth('api')->user();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated.',
                ], 401);
            }

            $sessions = $this->sessionService->getUserSessions($user->id);

            // Get current session JTI if available
            $currentJti = null;
            try {
                $token = JWTAuth::getToken();
                if ($token) {
                    $payload = JWTAuth::setToken($token)->getPayload();
                    $currentJti = $payload->get('jti') ?? $this->sessionService->generateJti($token->get());
                }
            } catch (\Exception $e) {
                // Ignore
            }

            // Format sessions for response
            $formattedSessions = $sessions->map(function ($session) use ($currentJti) {
                return [
                    'id' => $session->id,
                    'jti' => $session->jti,
                    'ip_address' => $session->ip_address,
                    'device_type' => $session->device_type,
                    'browser' => $session->browser,
                    'device_info' => $session->device_info,
                    'location' => $session->location,
                    'is_current' => $session->is_current || ($currentJti && $session->jti === $currentJti),
                    'last_activity' => $session->last_activity->toIso8601String(),
                    'last_activity_human' => $session->last_activity->diffForHumans(),
                    'created_at' => $session->created_at->toIso8601String(),
                    'created_at_human' => $session->created_at->diffForHumans(),
                ];
            });

            return response()->json([
                'success' => true,
                'message' => 'Sessions retrieved successfully.',
                'data' => $formattedSessions,
            ], 200);
        } catch (\Exception $e) {
            Log::error('API Get Sessions: Failed to retrieve sessions', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'user_id' => $user->id ?? 'unknown',
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve sessions.',
                'error' => config('app.debug') ? $e->getMessage() : 'An error occurred',
            ], 500);
        }
    }

    /**
     * Revoke a specific session.
     *
     * DELETE /api/v1/students/me/sessions/{jti}
     */
    public function revokeSession(Request $request, string $jti)
    {
        try {
            $user = auth('api')->user();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated.',
                ], 401);
            }

            // Don't allow revoking current session
            try {
                $token = JWTAuth::getToken();
                if ($token) {
                    $payload = JWTAuth::setToken($token)->getPayload();
                    $currentJti = $payload->get('jti') ?? $this->sessionService->generateJti($token->get());
                    if ($jti === $currentJti) {
                        return response()->json([
                            'success' => false,
                            'message' => 'Cannot revoke your current session. Please use logout instead.',
                        ], 422);
                    }
                }
            } catch (\Exception $e) {
                // Ignore
            }

            $revoked = $this->sessionService->revokeSession($jti, $user->id);

            if ($revoked) {
                // Log to audit log
                try {
                    $auditLogService = app(\App\Services\AuditLogService::class);
                    $auditLogService->logUserAction(
                        'session.revoked',
                        "Revoked session from device",
                        $user,
                        [],
                        [],
                        'success'
                    );
                } catch (\Exception $e) {
                    Log::warning('Failed to log session revocation: ' . $e->getMessage());
                }

                return response()->json([
                    'success' => true,
                    'message' => 'Session revoked successfully.',
                ], 200);
            }

            return response()->json([
                'success' => false,
                'message' => 'Session not found or already revoked.',
            ], 404);
        } catch (\Exception $e) {
            Log::error('API Revoke Session: Failed to revoke session', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'user_id' => $user->id ?? 'unknown',
                'jti' => $jti,
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to revoke session.',
                'error' => config('app.debug') ? $e->getMessage() : 'An error occurred',
            ], 500);
        }
    }

    /**
     * Revoke all other sessions (except current).
     *
     * DELETE /api/v1/students/me/sessions/others
     */
    public function revokeAllOtherSessions(Request $request)
    {
        try {
            $user = auth('api')->user();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated.',
                ], 401);
            }

            // Get current session JTI
            $currentJti = null;
            try {
                $token = JWTAuth::getToken();
                if ($token) {
                    $payload = JWTAuth::setToken($token)->getPayload();
                    $currentJti = $payload->get('jti') ?? $this->sessionService->generateJti($token->get());
                }
            } catch (\Exception $e) {
                Log::warning('Failed to get current session JTI: ' . $e->getMessage());
            }

            if (!$currentJti) {
                return response()->json([
                    'success' => false,
                    'message' => 'Could not identify current session.',
                ], 422);
            }

            $revokedCount = $this->sessionService->revokeAllOtherSessions($user->id, $currentJti);

            // Log to audit log
            try {
                $auditLogService = app(\App\Services\AuditLogService::class);
                $auditLogService->logUserAction(
                    'session.revoked.all_others',
                    "Revoked all other sessions ({$revokedCount} sessions)",
                    $user,
                    [],
                    [],
                    'success'
                );
            } catch (\Exception $e) {
                Log::warning('Failed to log session revocation: ' . $e->getMessage());
            }

            return response()->json([
                'success' => true,
                'message' => "Successfully revoked {$revokedCount} session(s).",
                'data' => [
                    'revoked_count' => $revokedCount,
                ],
            ], 200);
        } catch (\Exception $e) {
            Log::error('API Revoke All Other Sessions: Failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'user_id' => $user->id ?? 'unknown',
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to revoke sessions.',
                'error' => config('app.debug') ? $e->getMessage() : 'An error occurred',
            ], 500);
        }
    }

    /**
     * Revoke all sessions (including current).
     *
     * DELETE /api/v1/students/me/sessions/all
     */
    public function revokeAllSessions(Request $request)
    {
        try {
            $user = auth('api')->user();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated.',
                ], 401);
            }

            $revokedCount = $this->sessionService->revokeAllSessions($user->id);

            // Invalidate current token
            try {
                $token = JWTAuth::getToken();
                if ($token) {
                    JWTAuth::invalidate($token);
                }
            } catch (\Exception $e) {
                Log::warning('Failed to invalidate current token: ' . $e->getMessage());
            }

            // Log to audit log
            try {
                $auditLogService = app(\App\Services\AuditLogService::class);
                $auditLogService->logUserAction(
                    'session.revoked.all',
                    "Revoked all sessions ({$revokedCount} sessions)",
                    $user,
                    [],
                    [],
                    'success'
                );
            } catch (\Exception $e) {
                Log::warning('Failed to log session revocation: ' . $e->getMessage());
            }

            return response()->json([
                'success' => true,
                'message' => "Successfully revoked all {$revokedCount} session(s). You will need to log in again.",
                'data' => [
                    'revoked_count' => $revokedCount,
                ],
            ], 200);
        } catch (\Exception $e) {
            Log::error('API Revoke All Sessions: Failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'user_id' => $user->id ?? 'unknown',
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to revoke sessions.',
                'error' => config('app.debug') ? $e->getMessage() : 'An error occurred',
            ], 500);
        }
    }
}

