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
        Schema::table('email_settings', function (Blueprint $table) {
            // Email Service Type
            $table->enum('email_service', ['smtp', 'mailtrap'])->default('smtp')->after('id');

            // Mailtrap Configuration
            $table->text('mailtrap_api_key')->nullable()->after('smtp_password'); // Text to accommodate encrypted values
            $table->boolean('mailtrap_use_sandbox')->default(true)->after('mailtrap_api_key');
            $table->string('mailtrap_inbox_id')->nullable()->after('mailtrap_use_sandbox');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('email_settings', function (Blueprint $table) {
            $table->dropColumn([
                'email_service',
                'mailtrap_api_key',
                'mailtrap_use_sandbox',
                'mailtrap_inbox_id',
            ]);
        });
    }
};
