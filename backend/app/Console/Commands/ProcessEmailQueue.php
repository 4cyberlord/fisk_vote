<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class ProcessEmailQueue extends Command
{
    protected $signature = 'email:process {--once : Process only one job}';
    protected $description = 'Process email queue jobs (useful for testing)';

    public function handle()
    {
        $this->info('Processing email queue...');
        
        if ($this->option('once')) {
            $this->call('queue:work', [
                'connection' => 'database',
                '--queue' => 'emails',
                '--once' => true,
                '--tries' => 3,
                '--timeout' => 120,
            ]);
        } else {
            $this->call('queue:work', [
                'connection' => 'database',
                '--queue' => 'emails',
                '--tries' => 3,
                '--timeout' => 120,
            ]);
        }
        
        return 0;
    }
}

