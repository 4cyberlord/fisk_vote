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

    // Public routes (no authentication required)
    Route::get('/departments', [\App\Http\Controllers\Api\DepartmentController::class, 'index'])->name('api.v1.departments.index');
    Route::get('/majors', [\App\Http\Controllers\Api\MajorController::class, 'index'])->name('api.v1.majors.index');

    // Blog routes (public)
    Route::prefix('blog')->name('api.v1.blog.')->group(function () {
        Route::get('/posts', [\App\Http\Controllers\Api\BlogController::class, 'index'])->name('posts.index');
        Route::get('/posts/{id}', [\App\Http\Controllers\Api\BlogController::class, 'show'])->name('posts.show');
        Route::get('/categories', [\App\Http\Controllers\Api\BlogController::class, 'categories'])->name('categories.index');
        Route::get('/featured', [\App\Http\Controllers\Api\BlogController::class, 'featured'])->name('featured');
        Route::get('/popular', [\App\Http\Controllers\Api\BlogController::class, 'popular'])->name('popular');
        Route::get('/recent', [\App\Http\Controllers\Api\BlogController::class, 'recent'])->name('recent');
        Route::get('/posts/{id}/related', [\App\Http\Controllers\Api\BlogController::class, 'related'])->name('posts.related');
        Route::get('/search', [\App\Http\Controllers\Api\BlogController::class, 'search'])->name('search');
    });

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

