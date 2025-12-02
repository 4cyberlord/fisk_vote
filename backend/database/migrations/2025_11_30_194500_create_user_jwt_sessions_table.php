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
        Schema::create('user_jwt_sessions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->string('jti')->unique()->comment('JWT ID (jti claim) - unique token identifier');
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->string('device_type')->nullable()->comment('e.g., iOS, Android, Windows, macOS, Linux');
            $table->string('browser')->nullable()->comment('e.g., Chrome, Firefox, Safari');
            $table->string('location')->nullable()->comment('Geographic location if available');
            $table->timestamp('last_activity')->useCurrent();
            $table->timestamp('expires_at')->nullable()->comment('Token expiration time');
            $table->boolean('is_current')->default(false)->comment('Is this the current session?');
            $table->timestamps();

            // Indexes
            $table->index(['user_id', 'last_activity']);
            $table->index(['jti']);
            $table->index(['user_id', 'is_current']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('user_jwt_sessions');
    }
};
