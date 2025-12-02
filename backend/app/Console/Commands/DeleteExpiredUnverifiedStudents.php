<?php

namespace App\Console\Commands;

use App\Models\User;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Log;

class DeleteExpiredUnverifiedStudents extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'students:cleanup-unverified';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Delete recently registered student accounts that did not verify their email within the verification window';

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        // Match the 2-minute verification link expiry
        $expiryThreshold = now()->subMinutes(2);

        // Safety window so we only touch *recent* signups, not old seeded data
        $recentWindowStart = now()->subMinutes(10);

        $this->info('Cleaning up unverified student accounts...');

        $query = User::query()
            ->whereNull('email_verified_at')
            ->whereBetween('created_at', [$recentWindowStart, $expiryThreshold])
            ->whereHas('roles', function ($q) {
                $q->where('name', 'Student');
            });

        $users = $query->get();

        if ($users->isEmpty()) {
            $this->info('No unverified student accounts to clean up.');
            return self::SUCCESS;
        }

        $count = $users->count();

        $this->warn("Deleting {$count} unverified student account(s) that did not verify within 2 minutes...");

        $userSnapshots = $users->map(function (User $user) {
            return [
                'id' => $user->id,
                'email' => $user->email,
                'created_at' => $user->created_at?->toDateTimeString(),
            ];
        })->all();

        $query->delete();

        Log::info('students:cleanup-unverified executed', [
            'deleted_count' => $count,
            'users' => $userSnapshots,
        ]);

        $this->info("Deleted {$count} unverified student account(s).");

        return self::SUCCESS;
    }
}


