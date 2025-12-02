<?php

namespace App\Http\Controllers\Api\Students;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;

class StudentAuditLogController extends Controller
{
    /**
     * Get the authenticated student's audit logs with pagination.
     *
     * GET /api/v1/students/me/audit-logs
     */
    public function getMyAuditLogs(Request $request)
    {
        try {
            $user = auth('api')->user();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated.',
                ], 401);
            }

            // Validate query parameters
            $validated = $request->validate([
                'page' => 'sometimes|integer|min:1',
                'per_page' => 'sometimes|integer|min:1|max:100',
                'action_type' => 'sometimes|string|in:login,logout,create,update,delete,view,access',
                'status' => 'sometimes|string|in:success,failed,pending',
                'date_from' => 'sometimes|date',
                'date_to' => 'sometimes|date|after_or_equal:date_from',
            ]);

            $perPage = $validated['per_page'] ?? 15;
            $page = $validated['page'] ?? 1;

            // Build query
            $query = AuditLog::where('user_id', $user->id)
                ->orderBy('created_at', 'desc');

            // Apply filters
            if (isset($validated['action_type'])) {
                $query->where('action_type', $validated['action_type']);
            }

            if (isset($validated['status'])) {
                $query->where('status', $validated['status']);
            }

            if (isset($validated['date_from'])) {
                $query->whereDate('created_at', '>=', $validated['date_from']);
            }

            if (isset($validated['date_to'])) {
                $query->whereDate('created_at', '<=', $validated['date_to']);
            }

            // Get paginated results
            $auditLogs = $query->paginate($perPage, ['*'], 'page', $page);

            // Get summary statistics
            $stats = $this->getStatistics($user->id);

            // Format response
            $formattedLogs = $auditLogs->map(function ($log) {
                return $this->formatAuditLog($log);
            });

            return response()->json([
                'success' => true,
                'message' => 'Audit logs retrieved successfully.',
                'data' => $formattedLogs,
                'meta' => [
                    'current_page' => $auditLogs->currentPage(),
                    'last_page' => $auditLogs->lastPage(),
                    'per_page' => $auditLogs->perPage(),
                    'total' => $auditLogs->total(),
                    'from' => $auditLogs->firstItem(),
                    'to' => $auditLogs->lastItem(),
                ],
                'statistics' => $stats,
            ], 200);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed.',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            Log::error('API Student Audit Logs: Failed to retrieve audit logs', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'user_id' => $user->id ?? 'unknown',
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve audit logs.',
                'error' => config('app.debug') ? $e->getMessage() : 'An error occurred',
            ], 500);
        }
    }

    /**
     * Format audit log for API response.
     */
    private function formatAuditLog(AuditLog $log): array
    {
        // Determine icon and color based on action type and status
        $icon = $this->getIconForAction($log->action_type, $log->status);
        $color = $this->getColorForStatus($log->status, $log->action_type);
        $badge = $this->getBadgeForAction($log->action_type, $log->status);

        // Parse user agent for device/browser info
        $deviceInfo = $this->parseUserAgent($log->user_agent);

        // Get location from IP (if available in metadata)
        $location = $log->metadata['location'] ?? null;

        return [
            'id' => $log->id,
            'action_type' => $log->action_type,
            'action_description' => $log->action_description,
            'event_type' => $log->event_type,
            'status' => $log->status,
            'icon' => $icon,
            'color' => $color,
            'badge' => $badge,
            'ip_address' => $log->ip_address,
            'user_agent' => $log->user_agent,
            'device' => $deviceInfo['device'] ?? null,
            'browser' => $deviceInfo['browser'] ?? null,
            'location' => $location,
            'request_url' => $log->request_url,
            'request_method' => $log->request_method,
            'changes_summary' => $log->changes_summary,
            'old_values' => $log->old_values,
            'new_values' => $log->new_values,
            'error_message' => $log->error_message,
            'metadata' => $log->metadata,
            'created_at' => $log->created_at->toIso8601String(),
            'created_at_human' => $log->created_at->diffForHumans(),
            'created_at_formatted' => $log->created_at->format('F j, Y \a\t g:i A'),
        ];
    }

    /**
     * Get icon name for action type.
     */
    private function getIconForAction(string $actionType, string $status): string
    {
        if ($status === 'failed') {
            return 'XCircle';
        }

        return match ($actionType) {
            'login', 'login.success' => 'CheckCircle',
            'logout' => 'LogOut',
            'profile.password.changed' => 'Lock',
            'profile.photo.updated' => 'User',
            'create', 'vote', 'vote.submitted' => 'Activity',
            'update' => 'Edit',
            'delete' => 'Trash2',
            'view', 'access' => 'Eye',
            default => 'History',
        };
    }

    /**
     * Get color for status.
     */
    private function getColorForStatus(string $status, string $actionType): string
    {
        if ($status === 'failed') {
            return 'red';
        }

        return match ($actionType) {
            'login', 'login.success' => 'green',
            'profile.password.changed' => 'purple',
            'profile.photo.updated' => 'blue',
            'vote', 'vote.submitted', 'create' => 'indigo',
            'update' => 'blue',
            default => 'gray',
        };
    }

    /**
     * Get badge label for action.
     */
    private function getBadgeForAction(string $actionType, string $status): string
    {
        if ($status === 'failed') {
            return 'Failed';
        }

        return match ($actionType) {
            'login', 'login.success' => 'Success',
            'logout' => 'Logged Out',
            'profile.password.changed' => 'Security',
            'profile.photo.updated' => 'Updated',
            'vote', 'vote.submitted' => 'Vote',
            'create' => 'Created',
            'update' => 'Updated',
            'delete' => 'Deleted',
            'view', 'access' => 'Viewed',
            default => 'Activity',
        };
    }

    /**
     * Parse user agent string to extract device and browser info.
     */
    private function parseUserAgent(?string $userAgent): array
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
            'full' => $browser . ' on ' . $device,
        ];
    }

    /**
     * Get statistics for the user's audit logs.
     */
    private function getStatistics(int $userId): array
    {
        $thirtyDaysAgo = now()->subDays(30);

        $stats = [
            'successful_logins' => AuditLog::where('user_id', $userId)
                ->where('action_type', 'login')
                ->where('status', 'success')
                ->where('created_at', '>=', $thirtyDaysAgo)
                ->count(),
            'failed_attempts' => AuditLog::where('user_id', $userId)
                ->where('action_type', 'login')
                ->where('status', 'failed')
                ->where('created_at', '>=', $thirtyDaysAgo)
                ->count(),
            'unique_ips' => AuditLog::where('user_id', $userId)
                ->where('created_at', '>=', $thirtyDaysAgo)
                ->whereNotNull('ip_address')
                ->distinct('ip_address')
                ->count('ip_address'),
            'total_activities' => AuditLog::where('user_id', $userId)
                ->where('created_at', '>=', $thirtyDaysAgo)
                ->count(),
        ];

        return $stats;
    }
}

