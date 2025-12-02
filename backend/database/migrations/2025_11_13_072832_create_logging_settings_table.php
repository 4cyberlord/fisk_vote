<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('logging_settings', function (Blueprint $table) {
            $table->id();
            // Logging preferences
            $table->boolean('enable_activity_logs')->default(true);
            $table->boolean('log_admin_actions')->default(true);
            $table->boolean('log_voter_logins')->default(true);
            $table->boolean('log_vote_submission_events')->default(true)->comment('Vote submission events should be anonymized before storage');
            $table->boolean('log_ip_addresses')->default(false)->comment('When enabled, IPs must be stored securely and in compliance with privacy policies');

            // Log retention
            $table->enum('retention_period', ['30_days', '3_months', '1_year', 'forever'])->default('3_months');

            // Performance monitoring
            $table->boolean('enable_system_health_dashboard')->default(true);
            $table->boolean('track_cpu_load')->default(true);
            $table->boolean('track_database_queries')->default(true);
            $table->boolean('track_active_users')->default(true);
            $table->boolean('track_vote_submission_rate')->default(true);

            // Error & crash handling
            $table->boolean('auto_email_admin_on_failure')->default(true);
            $table->boolean('store_crash_reports')->default(true);

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('logging_settings');
    }
};
