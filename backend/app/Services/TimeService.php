<?php

namespace App\Services;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class TimeService
{
    private const NASHVILLE_TZ = 'America/Chicago';
    private const CACHE_KEY = 'worldtimeapi.nashville.unixtime';
    private const CACHE_TTL = 300; // 5 minutes
    private const WORLD_TIME_API_URL = 'https://worldtimeapi.org/api/timezone/' . self::NASHVILLE_TZ;

    /**
    * Get Nashville (America/Chicago) current time as Unix timestamp using World Time API.
    * Falls back to PHP time() if the API is unavailable.
    */
    public static function getNashvilleTimestamp(): int
    {
        return Cache::remember(self::CACHE_KEY, self::CACHE_TTL, function () {
            try {
                $response = Http::timeout(3)->get(self::WORLD_TIME_API_URL);

                if ($response->successful()) {
                    $data = $response->json();
                    if (isset($data['unixtime'])) {
                        return (int) $data['unixtime'];
                    }
                }

                Log::warning('TimeService: World Time API did not return unixtime, falling back to time().', [
                    'status' => $response->status(),
                    'body' => $response->body(),
                ]);
            } catch (\Throwable $e) {
                Log::warning('TimeService: Failed to fetch World Time API, falling back to time().', [
                    'error' => $e->getMessage(),
                ]);
            }

            return time();
        });
    }

    /**
    * Clear cached timestamp (primarily for tests or manual refresh).
    */
    public static function clearCache(): void
    {
        Cache::forget(self::CACHE_KEY);
    }

    /**
    * Expose the timezone string (America/Chicago).
    */
    public static function timezone(): string
    {
        return self::NASHVILLE_TZ;
    }
}
