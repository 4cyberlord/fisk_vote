<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Department;
use Illuminate\Http\Request;

class DepartmentController extends Controller
{
    /**
     * Get all departments.
     *
     * GET /api/v1/departments
     */
    public function index(Request $request)
    {
        try {
            $departments = Department::orderBy('name', 'asc')->get();

            return response()->json([
                'success' => true,
                'message' => 'Departments retrieved successfully.',
                'data' => $departments->map(function ($department) {
                    return [
                        'id' => $department->id,
                        'name' => $department->name,
                    ];
                }),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'An unexpected error occurred. Please try again later.',
                'error' => config('app.debug') ? $e->getMessage() : 'An unexpected error occurred',
            ], 500);
        }
    }
}

