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
        Schema::table('users', function (Blueprint $table) {
            $table->text('otp_code')->nullable()->after('email_verified_at')->comment('Encrypted 7-digit OTP code');
            $table->timestamp('otp_expires_at')->nullable()->after('otp_code')->comment('OTP expiration timestamp (5 minutes from generation)');
            $table->timestamp('otp_verified_at')->nullable()->after('otp_expires_at')->comment('Timestamp when OTP was successfully verified');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['otp_code', 'otp_expires_at', 'otp_verified_at']);
        });
    }
};
