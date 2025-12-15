<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Storage;

Route::get('/', function () {
    return view('welcome');
});

// Route to serve blog images from private storage (for backward compatibility)
Route::get('/blog-image/{path}', function ($path) {
    try {
        $decodedPath = base64_decode($path);
        $filePath = storage_path('app/private/' . $decodedPath);

        if (!file_exists($filePath)) {
            abort(404);
        }

        // Security: ensure the path is within the private directory
        $realPath = realpath($filePath);
        $privatePath = realpath(storage_path('app/private'));

        if (!$realPath || strpos($realPath, $privatePath) !== 0) {
            abort(404);
        }

        $mimeType = mime_content_type($filePath);
        return response()->file($filePath, ['Content-Type' => $mimeType]);
    } catch (\Exception $e) {
        abort(404);
    }
})->name('blog.image');
