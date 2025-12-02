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
        Schema::create('email_settings', function (Blueprint $table) {
            $table->id();

            // Email Server Settings
            $table->string('smtp_host')->nullable();
            $table->integer('smtp_port')->default(587);
            $table->enum('encryption_type', ['tls', 'ssl', 'none'])->default('tls');
            $table->string('smtp_username')->nullable();
            $table->text('smtp_password')->nullable(); // Encrypted

            // Email Templates (JSON)
            $table->text('voter_registration_email')->nullable();
            $table->text('email_verification')->nullable();
            $table->text('password_reset')->nullable();
            $table->text('election_announcement')->nullable();
            $table->text('upcoming_election_reminder')->nullable();
            $table->text('thank_you_for_voting')->nullable();
            $table->text('result_announcement_email')->nullable();

            // Notification Preferences
            $table->boolean('send_daily_summary_to_admins')->default(false);
            $table->boolean('send_voting_activity_alerts')->default(false);
            $table->boolean('notify_users_when_election_opens')->default(true);
            $table->boolean('notify_eligible_voters_before_election_ends')->default(true);

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('email_settings');
    }
};
