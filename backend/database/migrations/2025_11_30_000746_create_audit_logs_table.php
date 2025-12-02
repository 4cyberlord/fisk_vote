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
        Schema::create('audit_logs', function (Blueprint $table) {
            $table->id();
            
            // User Information
            $table->foreignId('user_id')->nullable()->constrained('users')->onDelete('set null');
            $table->string('user_name')->nullable()->comment('User name snapshot at time of action');
            $table->string('user_email')->nullable()->comment('User email snapshot at time of action');
            $table->string('user_role')->nullable()->comment('User role at time of action');
            
            // Action Details
            $table->string('action_type')->index()->comment('Type of action (login, create, update, delete, etc.)');
            $table->text('action_description')->comment('Human-readable description of the action');
            $table->string('event_type')->nullable()->index()->comment('Technical event name (e.g., user.created)');
            
            // Resource Information
            $table->string('auditable_type')->nullable()->index()->comment('Model class name');
            $table->unsignedBigInteger('auditable_id')->nullable()->index()->comment('ID of the affected record');
            $table->string('resource_name')->nullable()->comment('Display name of the resource');
            
            // Change Tracking
            $table->json('old_values')->nullable()->comment('Previous state (for updates)');
            $table->json('new_values')->nullable()->comment('New state (for creates/updates)');
            $table->text('changes_summary')->nullable()->comment('Human-readable summary of changes');
            
            // Request/Context Information
            $table->string('ip_address', 45)->nullable()->index()->comment('IP address (IPv4 or IPv6)');
            $table->text('user_agent')->nullable()->comment('Browser/client information');
            $table->string('request_url')->nullable()->comment('URL where action occurred');
            $table->string('request_method', 10)->nullable()->comment('HTTP method (GET, POST, etc.)');
            
            // Status and Metadata
            $table->enum('status', ['success', 'failed', 'pending'])->default('success')->index();
            $table->text('error_message')->nullable()->comment('Error details if failed');
            $table->json('metadata')->nullable()->comment('Additional context data');
            $table->string('session_id')->nullable()->index()->comment('Session identifier');
            
            $table->timestamps();
            
            // Indexes for common queries
            $table->index(['user_id', 'created_at']);
            $table->index(['auditable_type', 'auditable_id']);
            $table->index(['action_type', 'created_at']);
            $table->index(['status', 'created_at']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('audit_logs');
    }
};
