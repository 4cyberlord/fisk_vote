<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Major;
use Illuminate\Http\Request;

class MajorController extends Controller
{
    /**
     * Get all majors.
     *
     * GET /api/v1/majors
     */
    public function index(Request $request)
    {
        try {
            $majors = Major::orderBy('name', 'asc')->get();

            return response()->json([
                'success' => true,
                'message' => 'Majors retrieved successfully.',
                'data' => $majors->map(function ($major) {
                    return [
                        'id' => $major->id,
                        'name' => $major->name,
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

