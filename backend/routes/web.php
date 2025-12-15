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

// Convenience redirects for API docs (Scramble)
// Hitting http://<backend-host>/docs/api or /docs/api.json serves the UI/spec.
// These redirects make common guesses work even if the frontend catches /docs.
Route::redirect('/api/docs', '/docs/api')->name('scramble.ui.redirect');
Route::redirect('/api/docs.json', '/docs/api.json')->name('scramble.json.redirect');
Route::redirect('/docs', '/docs/api')->name('scramble.docs.redirect');
