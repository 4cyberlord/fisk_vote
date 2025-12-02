<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * We previously enforced a unique constraint per election + voter, which
     * prevents storing one row per position. Update this to be unique per
     * election + position + voter instead.
     */
    public function up(): void
    {
        // Intentionally left empty.
        // We decided to keep the existing unique constraint
        // (election_id + voter_id) and instead adjust the
        // vote storage logic to use a single row per election.
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // No-op: nothing to roll back because up() is empty.
    }
};


