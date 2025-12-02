<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class CheckEmailQueue extends Command
{
    protected $signature = 'email:check-queue';
    protected $description = 'Check email queue status and recent jobs';

    public function handle()
    {
        $this->info('=== Email Queue Status ===');
        
        // Check queue connection
        $queueConnection = config('queue.default');
        $this->info("Queue Connection: {$queueConnection}");
        
        // Check pending jobs
        $pendingJobs = DB::table('jobs')
            ->where('queue', 'emails')
            ->count();
        $this->info("Pending Jobs in 'emails' queue: {$pendingJobs}");
        
        // Check all jobs
        $allJobs = DB::table('jobs')->count();
        $this->info("Total Pending Jobs: {$allJobs}");
        
        // Check failed jobs
        $failedJobs = DB::table('failed_jobs')->count();
        $this->info("Failed Jobs: {$failedJobs}");
        
        // Show recent jobs
        $recentJobs = DB::table('jobs')
            ->where('queue', 'emails')
            ->orderBy('created_at', 'desc')
            ->limit(5)
            ->get();
        
        if ($recentJobs->count() > 0) {
            $this->info("\nRecent Jobs:");
            foreach ($recentJobs as $job) {
                $this->line("  - Job ID: {$job->id}, Created: {$job->created_at}, Attempts: {$job->attempts}");
            }
        }
        
        // Show recent failed jobs
        $recentFailed = DB::table('failed_jobs')
            ->orderBy('failed_at', 'desc')
            ->limit(5)
            ->get();
        
        if ($recentFailed->count() > 0) {
            $this->warn("\nRecent Failed Jobs:");
            foreach ($recentFailed as $job) {
                $this->line("  - Job ID: {$job->id}, Failed: {$job->failed_at}, Queue: {$job->queue}");
                if (strlen($job->exception) > 200) {
                    $this->line("    Error: " . substr($job->exception, 0, 200) . "...");
                } else {
                    $this->line("    Error: " . $job->exception);
                }
            }
        }
        
        // Check if queue worker is running
        $this->info("\n=== Queue Worker Status ===");
        $processes = shell_exec("ps aux | grep 'queue:work' | grep -v grep");
        if ($processes) {
            $this->info("Queue worker appears to be running");
            $this->line($processes);
        } else {
            $this->error("Queue worker does NOT appear to be running!");
            $this->warn("Run: php artisan queue:work database --queue=emails");
        }
        
        return 0;
    }
}

