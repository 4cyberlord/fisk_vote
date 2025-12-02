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
        Schema::create('application_settings', function (Blueprint $table) {
            $table->id();

            // Platform Identity
            $table->string('system_name')->default('Fisk Voting System');
            $table->string('system_short_name')->default('FVS');
            $table->string('university_name')->default('Fisk University');
            $table->text('system_description')->nullable();
            $table->string('voting_platform_contact_email')->nullable();
            $table->string('voting_support_email')->nullable();
            $table->string('support_phone_number')->nullable();

            // Branding
            $table->string('university_logo_url')->nullable();
            $table->string('secondary_logo_url')->nullable();
            $table->string('primary_color')->default('#3B82F6');
            $table->string('secondary_color')->default('#8B5CF6');
            $table->enum('dashboard_theme', ['light', 'dark', 'auto'])->default('auto');
            $table->string('login_page_background_image_url')->nullable();

            // Time & Localization
            $table->string('default_timezone')->default('America/Chicago');
            $table->enum('date_format', ['MM/DD/YYYY', 'DD/MM/YYYY', 'YYYY-MM-DD'])->default('MM/DD/YYYY');
            $table->enum('time_format', ['12-hour', '24-hour'])->default('12-hour');
            $table->string('default_language')->default('en');
            $table->json('additional_languages')->nullable();

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('application_settings');
    }
};
