<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use App\Services\AuditLogService;
use App\Models\LoggingSetting;
use Symfony\Component\HttpFoundation\Response;

class LogApiActivity
{
    protected AuditLogService $auditLogService;

    public function __construct(AuditLogService $auditLogService)
    {
        $this->auditLogService = $auditLogService;
    }

    /**
     * Handle an incoming request and log API activity.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        // Check if activity logging is enabled
        $settings = LoggingSetting::getSettings();
        if (!$settings->enable_activity_logs) {
            return $next($request);
        }

        // Get authenticated user (check both api and web guards)
        $user = auth('api')->user() ?? auth('web')->user();

        // Only log if user is authenticated
        if (!$user) {
            return $next($request);
        }

        // Skip logging for certain routes (to avoid noise or duplicate logs)
        $skipRoutes = [
            'api/v1/students/refresh', // Token refresh happens frequently
            'api/v1/students/me', // User profile check happens frequently
            'api/v1/students/login', // Login is logged explicitly in controller
            'api/v1/students/logout', // Logout is logged explicitly in controller
        ];

        $path = $request->path();
        foreach ($skipRoutes as $skipRoute) {
            if (str_contains($path, $skipRoute)) {
                return $next($request);
            }
        }

        // Determine action type based on HTTP method
        $actionType = match($request->method()) {
            'GET' => 'view',
            'POST' => 'create',
            'PUT', 'PATCH' => 'update',
            'DELETE' => 'delete',
            default => 'access',
        };

        // Generate action description
        $actionDescription = $this->generateActionDescription($request, $actionType);

        // Log the activity
        try {
            $this->auditLogService->log(
                $actionType,
                $actionDescription,
                null, // No specific model for general API access
                [],
                [],
                'success',
                null,
                [
                    'route' => $request->route()?->getName(),
                    'path' => $request->path(),
                    'method' => $request->method(),
                ],
                'api.' . $actionType
            );
        } catch (\Exception $e) {
            // Don't break the request if logging fails
            \Log::error('Failed to log API activity: ' . $e->getMessage());
        }

        return $next($request);
    }

    /**
     * Generate a human-readable action description.
     */
    protected function generateActionDescription(Request $request, string $actionType): string
    {
        $path = $request->path();
        $method = $request->method();

        // Extract resource name from path
        $pathParts = explode('/', $path);
        $resource = $pathParts[count($pathParts) - 1] ?? 'resource';

        // Map common API endpoints to readable descriptions
        $descriptions = [
            'api/v1/students/elections' => 'Viewed elections list',
            'api/v1/students/elections/active' => 'Viewed active elections',
            'api/v1/students/elections/results' => 'Viewed election results list',
            'api/v1/students/votes' => 'Viewed voting history',
            'api/v1/students/analytics' => 'Viewed analytics',
        ];

        // Check for exact matches first
        foreach ($descriptions as $route => $description) {
            if (str_contains($path, $route)) {
                return $description;
            }
        }

        // Check for specific election/resource IDs
        if (preg_match('/elections\/(\d+)/', $path, $matches)) {
            $electionId = $matches[1];
            if (str_contains($path, 'results')) {
                return "Viewed results for election #{$electionId}";
            }
            if (str_contains($path, 'vote')) {
                return $actionType === 'view' 
                    ? "Viewed ballot for election #{$electionId}"
                    : "Cast vote for election #{$electionId}";
            }
            return "Viewed election #{$electionId}";
        }

        // Generic description
        $resourceName = ucfirst(str_replace(['-', '_'], ' ', $resource));
        return match($actionType) {
            'view' => "Viewed {$resourceName}",
            'create' => "Created {$resourceName}",
            'update' => "Updated {$resourceName}",
            'delete' => "Deleted {$resourceName}",
            default => "Accessed {$resourceName}",
        };
    }
}

