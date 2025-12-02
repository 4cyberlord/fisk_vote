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
        Schema::create('elections', function (Blueprint $table) {
            $table->id();

            // Basic Information
            $table->string('title');
            $table->text('description')->nullable();

            // Election Type
            $table->enum('type', ['single', 'multiple', 'referendum', 'ranked', 'poll']);

            // Advanced Type Settings
            $table->integer('max_selection')->nullable()->comment('Used for multiple-choice elections');
            $table->integer('ranking_levels')->nullable()->comment('Used for ranked-choice elections');
            $table->boolean('allow_write_in')->default(false);

            // Abstain Settings
            $table->boolean('allow_abstain')->default(false);

            // Eligibility Settings
            $table->boolean('is_universal')->default(false)->comment('If TRUE, all students are eligible');
            $table->json('eligible_groups')->nullable()->comment('Contains departments[], class_levels[], organizations[], manual[]');

            // Timeline
            $table->dateTime('start_time');
            $table->dateTime('end_time');

            // Status
            $table->enum('status', ['draft', 'active', 'closed', 'archived'])->default('draft');

            // System-Generated Fields
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('elections');
    }
};
