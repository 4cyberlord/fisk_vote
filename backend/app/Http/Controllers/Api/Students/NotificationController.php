<?php

namespace App\Http\Controllers\Api\Students;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class NotificationController extends Controller
{
    /**
     * Get all notifications for the authenticated user.
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        
        $query = Notification::forUser($user->id)
            ->orderBy('created_at', 'desc');

        // Filter by read/unread status
        if ($request->has('unread_only') && $request->boolean('unread_only')) {
            $query->unread();
        }

        // Filter by urgent
        if ($request->has('urgent_only') && $request->boolean('urgent_only')) {
            $query->urgent();
        }

        $notifications = $query->get();

        return response()->json([
            'success' => true,
            'data' => $notifications->map(function ($notification) {
                return [
                    'id' => $notification->id,
                    'type' => $notification->type,
                    'title' => $notification->title,
                    'message' => $notification->message,
                    'icon' => $notification->icon,
                    'color' => $notification->color,
                    'href' => $notification->href ? (str_starts_with($notification->href, '/') ? $notification->href : '/' . $notification->href) : null,
                    'urgent' => $notification->urgent,
                    'is_read' => $notification->is_read,
                    'read_at' => $notification->read_at?->toISOString(),
                    'metadata' => $notification->metadata,
                    'created_at' => $notification->created_at->toISOString(),
                    'time' => $this->formatTime($notification->created_at),
                ];
            }),
            'meta' => [
                'unread_count' => Notification::forUser($user->id)->unread()->urgent()->count(),
                'total_unread' => Notification::forUser($user->id)->unread()->count(),
            ],
        ]);
    }

    /**
     * Mark a notification as read.
     */
    public function markAsRead(Request $request, int $id): JsonResponse
    {
        $user = $request->user();
        
        $notification = Notification::forUser($user->id)->findOrFail($id);
        $notification->markAsRead();

        return response()->json([
            'success' => true,
            'message' => 'Notification marked as read',
        ]);
    }

    /**
     * Mark all notifications as read.
     */
    public function markAllAsRead(Request $request): JsonResponse
    {
        $user = $request->user();
        
        Notification::forUser($user->id)
            ->unread()
            ->update([
                'is_read' => true,
                'read_at' => now(),
            ]);

        return response()->json([
            'success' => true,
            'message' => 'All notifications marked as read',
        ]);
    }

    /**
     * Get unread count.
     */
    public function unreadCount(Request $request): JsonResponse
    {
        $user = $request->user();
        
        $urgentUnread = Notification::forUser($user->id)->unread()->urgent()->count();
        $totalUnread = Notification::forUser($user->id)->unread()->count();

        return response()->json([
            'success' => true,
            'data' => [
                'urgent_count' => $urgentUnread,
                'total_count' => $totalUnread,
            ],
        ]);
    }

    /**
     * Format time for display.
     */
    private function formatTime($timestamp): string
    {
        $now = now();
        $diff = $now->diffInMinutes($timestamp);

        if ($diff < 1) {
            return 'Just now';
        } elseif ($diff < 60) {
            return "{$diff} minute" . ($diff !== 1 ? 's' : '') . " ago";
        } elseif ($diff < 1440) {
            $hours = floor($diff / 60);
            return "{$hours} hour" . ($hours !== 1 ? 's' : '') . " ago";
        } elseif ($diff < 10080) {
            $days = floor($diff / 1440);
            return "{$days} day" . ($days !== 1 ? 's' : '') . " ago";
        } else {
            return $timestamp->format('M j, Y');
        }
    }
}
