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
        Schema::create('election_positions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('election_id')->constrained('elections')->onDelete('cascade');
            $table->string('name');
            $table->text('description')->nullable();
            $table->enum('type', ['single', 'multiple', 'ranked'])->default('single');
            $table->integer('max_selection')->nullable()->comment('Used for multiple-choice positions');
            $table->integer('ranking_levels')->nullable()->comment('Used for ranked-choice positions');
            $table->boolean('allow_abstain')->default(false);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('election_positions');
    }
};
