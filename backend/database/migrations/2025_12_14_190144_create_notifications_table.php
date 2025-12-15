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
        Schema::create('notifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->string('type'); // 'new_election', 'upcoming', 'closing_soon', 'vote_confirmed', 'results_available'
            $table->string('title');
            $table->text('message');
            $table->string('icon')->nullable(); // For frontend icon reference
            $table->string('color')->nullable(); // For frontend color reference
            $table->string('href')->nullable(); // Link to relevant page
            $table->boolean('is_read')->default(false);
            $table->boolean('urgent')->default(false);
            $table->json('metadata')->nullable(); // Store additional data like election_id, vote_id, etc.
            $table->timestamp('read_at')->nullable();
            $table->timestamps();

            // Indexes for performance
            $table->index(['user_id', 'is_read']);
            $table->index(['user_id', 'urgent']);
            $table->index('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('notifications');
    }
};
