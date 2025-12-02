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
        Schema::create('votes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('election_id')
                  ->constrained('elections')
                  ->onDelete('cascade');
            $table->foreignId('position_id')
                  ->constrained('election_positions')
                  ->onDelete('cascade');
            $table->unsignedBigInteger('voter_id'); // from users table
            $table->json('vote_data'); // Core vote field - JSON for flexibility across all types
            $table->string('token')->unique(); // anonymized vote token
            $table->timestamp('voted_at');
            $table->timestamps();

            // Add foreign key constraint for voter_id
            $table->foreign('voter_id')->references('id')->on('users')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('votes');
    }
};
