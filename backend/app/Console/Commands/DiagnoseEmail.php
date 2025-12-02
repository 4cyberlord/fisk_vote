<?php

namespace App\Console\Commands;

use App\Models\EmailSetting;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class DiagnoseEmail extends Command
{
    protected $signature = 'email:diagnose';
    protected $description = 'Diagnose email sending issues';

    public function handle()
    {
        $this->info('=== Email System Diagnosis ===');
        $this->newLine();

        // Check email settings
        $this->info('1. Email Settings:');
        try {
            $settings = EmailSetting::getSettings();
            $this->line("   Service: " . ($settings->email_service ?? 'not set'));
            $this->line("   SMTP Host: " . ($settings->smtp_host ?? 'not set'));
            $this->line("   Has Mailtrap Key: " . (empty($settings->mailtrap_api_key) ? 'NO' : 'YES'));
            $this->line("   Mailtrap Sandbox: " . ($settings->mailtrap_use_sandbox ? 'YES' : 'NO'));
            if ($settings->mailtrap_use_sandbox) {
                $this->line("   Mailtrap Inbox ID: " . ($settings->mailtrap_inbox_id ?? 'NOT SET'));
            }
        } catch (\Exception $e) {
            $this->error("   Error loading settings: " . $e->getMessage());
        }
        $this->newLine();

        // Check queue status
        $this->info('2. Queue Status:');
        $pendingJobs = DB::table('jobs')->where('queue', 'emails')->count();
        $this->line("   Pending jobs in 'emails' queue: {$pendingJobs}");
        
        $failedJobs = DB::table('failed_jobs')->count();
        $this->line("   Failed jobs: {$failedJobs}");
        
        if ($failedJobs > 0) {
            $this->warn("   ⚠️  There are failed jobs! Run 'php artisan queue:failed' to see details.");
        }
        $this->newLine();

        // Check queue worker
        $this->info('3. Queue Worker:');
        $processes = shell_exec("ps aux | grep 'queue:work' | grep -v grep");
        if ($processes) {
            $this->info("   ✓ Queue worker is running");
            $this->line("   " . trim($processes));
        } else {
            $this->error("   ✗ Queue worker is NOT running!");
            $this->warn("   Run: php artisan queue:work database --queue=emails --tries=3 --timeout=120");
        }
        $this->newLine();

        // Check recent logs
        $this->info('4. Recent Email Logs:');
        $logFile = storage_path('logs/laravel.log');
        if (file_exists($logFile)) {
            $logs = shell_exec("tail -100 {$logFile} | grep -i 'CustomMailChannel\|Mailtrap\|email' | tail -10");
            if ($logs) {
                $this->line("   Recent email-related logs:");
                foreach (explode("\n", trim($logs)) as $log) {
                    if (!empty($log)) {
                        $this->line("   " . substr($log, 0, 100));
                    }
                }
            } else {
                $this->line("   No recent email-related logs found");
            }
        }
        $this->newLine();

        // Recommendations
        $this->info('5. Recommendations:');
        if ($pendingJobs > 0 && !$processes) {
            $this->warn("   - Start the queue worker to process {$pendingJobs} pending job(s)");
        }
        if ($failedJobs > 0) {
            $this->warn("   - Check failed jobs: php artisan queue:failed");
            $this->warn("   - Retry failed jobs: php artisan queue:retry all");
        }
        if (!$processes) {
            $this->warn("   - Queue worker must be running for emails to be sent");
        }

        return 0;
    }
}

