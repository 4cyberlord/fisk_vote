<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
| API Versioning:
| - v1: Current stable version
| - Future versions (v2, v3, etc.) can be added as needed
|
*/

// API Version 1
Route::prefix('v1')->group(function () {
    require __DIR__ . '/api/v1/students.php';
    
    // Admin routes (protected by auth middleware)
    Route::middleware('auth:api')->prefix('admin')->name('api.v1.admin.')->group(function () {
        Route::get('/elections/{id}/results/export/csv', [\App\Http\Controllers\Api\Admin\ElectionResultsExportController::class, 'exportCsv'])
            ->name('elections.results.export.csv');
    });
});

// Future API versions can be added here:
// Route::prefix('v2')->group(function () {
//     require __DIR__ . '/api/v2/students.php';
// });

