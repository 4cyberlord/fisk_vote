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
        Schema::table('votes', function (Blueprint $table) {
            // Add unique constraint to prevent duplicate votes
            // A voter can only cast one vote per election
            $table->unique(['election_id', 'voter_id'], 'unique_vote_per_election');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('votes', function (Blueprint $table) {
            $table->dropUnique('unique_vote_per_election');
        });
    }
};
