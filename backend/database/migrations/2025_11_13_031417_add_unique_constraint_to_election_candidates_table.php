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
        Schema::table('election_candidates', function (Blueprint $table) {
            // Add unique constraint to prevent duplicate candidates
            // A user can only be a candidate once per position per election
            $table->unique(['election_id', 'position_id', 'user_id'], 'unique_candidate_per_position');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('election_candidates', function (Blueprint $table) {
            $table->dropUnique('unique_candidate_per_position');
        });
    }
};
