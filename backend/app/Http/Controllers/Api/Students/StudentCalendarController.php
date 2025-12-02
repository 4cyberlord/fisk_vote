<?php

namespace App\Http\Controllers\Api\Students;

use App\Http\Controllers\Controller;
use App\Models\Election;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class StudentCalendarController extends Controller
{
    /**
     * Get all events (elections) for the calendar.
     *
     * GET /api/v1/students/calendar/events
     */
    public function getEvents(Request $request)
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
                'start_date' => 'sometimes|date',
                'end_date' => 'sometimes|date|after_or_equal:start_date',
            ]);

            $startDate = $validated['start_date'] ?? now()->startOfMonth()->toDateString();
            $endDate = $validated['end_date'] ?? now()->addMonths(2)->endOfMonth()->toDateString();

            // Get all elections within the date range
            $elections = Election::where(function ($query) use ($startDate, $endDate) {
                // Elections that start or end within the range
                $query->whereBetween('start_time', [$startDate, $endDate])
                    ->orWhereBetween('end_time', [$startDate, $endDate])
                    ->orWhere(function ($q) use ($startDate, $endDate) {
                        // Elections that span the entire range
                        $q->where('start_time', '<=', $startDate)
                          ->where('end_time', '>=', $endDate);
                    });
            })
            ->orderBy('start_time', 'asc')
            ->get();

            // Format events for calendar
            $events = $elections->map(function ($election) use ($user) {
                $now = now();
                $status = $election->current_status;
                
                // Determine event type/color
                $eventType = 'election';
                $color = 'blue';
                
                if ($status === 'Upcoming') {
                    $color = 'indigo';
                } elseif ($status === 'Open') {
                    $color = 'green';
                } elseif ($status === 'Closed') {
                    $color = 'gray';
                }

                // Check if user is eligible
                $isEligible = $election->isEligibleForUser($user);
                $hasVoted = $election->hasUserVoted($user);

                return [
                    'id' => $election->id,
                    'title' => $election->title,
                    'description' => $election->description,
                    'type' => $eventType,
                    'status' => $status,
                    'color' => $color,
                    'start' => $election->start_time->toIso8601String(),
                    'end' => $election->end_time->toIso8601String(),
                    'start_date' => $election->start_time->toDateString(),
                    'end_date' => $election->end_time->toDateString(),
                    'start_time' => $election->start_time->format('g:i A'),
                    'end_time' => $election->end_time->format('g:i A'),
                    'is_eligible' => $isEligible,
                    'has_voted' => $hasVoted,
                    'election_type' => $election->type,
                    'is_universal' => $election->is_universal,
                ];
            });

            return response()->json([
                'success' => true,
                'message' => 'Events retrieved successfully.',
                'data' => $events,
                'meta' => [
                    'start_date' => $startDate,
                    'end_date' => $endDate,
                    'total_events' => $events->count(),
                ],
            ], 200);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed.',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            Log::error('API Calendar Events: Failed to retrieve events', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'user_id' => $user->id ?? 'unknown',
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve events.',
                'error' => config('app.debug') ? $e->getMessage() : 'An error occurred',
            ], 500);
        }
    }
}

