<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// Run cleanup of unverified student registrations:
// any student account created more than 2 minutes ago (but less than 10 minutes ago)
// that still has a null email_verified_at will be deleted.
Schedule::command('students:cleanup-unverified')
    ->everyMinute()
    ->description('Delete unverified student registrations that did not verify their email within 2 minutes');
