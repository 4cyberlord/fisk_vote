<?php

namespace App\Console\Commands;

use App\Models\Election;
use App\Models\ElectionPosition;
use App\Models\ElectionCandidate;
use App\Models\Vote;
use App\Models\Notification;
use Illuminate\Console\Command;

class DeleteTestData extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'test-data:delete {--force : Force deletion without confirmation}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Delete all test data: Elections, Election Positions, Election Candidates, Votes, and Notifications';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        if (!$this->option('force')) {
            $this->warn('⚠️  This will delete ALL test data:');
            $this->line('   - All Elections');
            $this->line('   - All Election Positions');
            $this->line('   - All Election Candidates');
            $this->line('   - All Votes');
            $this->line('   - All Notifications');
            $this->newLine();
            $this->info('✅ The following will be KEPT:');
            $this->line('   - Users');
            $this->line('   - Departments');
            $this->line('   - Majors');
            $this->line('   - Organizations');
            $this->line('   - Settings');
            $this->line('   - Roles');
            $this->newLine();

            if (!$this->confirm('Do you want to proceed with deletion?', false)) {
                $this->info('Deletion cancelled.');
                return 0;
            }
        }

        $this->info('🗑️  Starting deletion of test data...');
        $this->newLine();

        // Count records before deletion
        $electionCount = Election::count();
        $positionCount = ElectionPosition::count();
        $candidateCount = ElectionCandidate::count();
        $voteCount = Vote::count();
        $notificationCount = Notification::count();

        $this->line("Found:");
        $this->line("  - Elections: {$electionCount}");
        $this->line("  - Election Positions: {$positionCount}");
        $this->line("  - Election Candidates: {$candidateCount}");
        $this->line("  - Votes: {$voteCount}");
        $this->line("  - Notifications: {$notificationCount}");
        $this->newLine();

        // Delete in order to respect foreign key constraints
        // Votes depend on Elections, Positions, Candidates
        // Candidates depend on Elections and Positions
        // Positions depend on Elections
        // Notifications are independent but may reference elections

        $this->info('Deleting Votes...');
        $deletedVotes = Vote::query()->delete();
        $this->line("  ✓ Deleted {$deletedVotes} votes");

        $this->info('Deleting Election Candidates...');
        $deletedCandidates = ElectionCandidate::query()->delete();
        $this->line("  ✓ Deleted {$deletedCandidates} candidates");

        $this->info('Deleting Election Positions...');
        $deletedPositions = ElectionPosition::query()->delete();
        $this->line("  ✓ Deleted {$deletedPositions} positions");

        $this->info('Deleting Elections...');
        $deletedElections = Election::query()->delete();
        $this->line("  ✓ Deleted {$deletedElections} elections");

        $this->info('Deleting Notifications...');
        $deletedNotifications = Notification::query()->delete();
        $this->line("  ✓ Deleted {$deletedNotifications} notifications");

        $this->newLine();
        $this->info('✅ Test data deletion completed!');
        $this->newLine();
        $this->line('Summary:');
        $this->line("  - Elections deleted: {$deletedElections}");
        $this->line("  - Positions deleted: {$deletedPositions}");
        $this->line("  - Candidates deleted: {$deletedCandidates}");
        $this->line("  - Votes deleted: {$deletedVotes}");
        $this->line("  - Notifications deleted: {$deletedNotifications}");

        return 0;
    }
}
