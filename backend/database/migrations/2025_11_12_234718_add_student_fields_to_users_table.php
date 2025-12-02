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
            // Personal Information
            $table->string('first_name')->nullable()->after('name');
            $table->string('last_name')->nullable()->after('first_name');
            $table->string('middle_initial', 1)->nullable()->after('last_name');

            // Student Information
            $table->string('student_id')->nullable()->unique()->after('middle_initial');
            $table->string('university_email')->nullable()->unique()->after('student_id');
            $table->string('personal_email')->nullable()->after('university_email');

            // Academic Information
            $table->string('department')->nullable()->after('personal_email');
            $table->string('major')->nullable()->after('department');
            $table->enum('class_level', ['Freshman', 'Sophomore', 'Junior', 'Senior'])->nullable()->after('major');

            // Status Information
            $table->enum('enrollment_status', ['Active', 'Suspended', 'Graduated'])->default('Active')->after('class_level');
            $table->enum('student_type', ['Undergraduate', 'Graduate', 'Transfer', 'International'])->nullable()->after('enrollment_status');
            $table->string('citizenship_status')->nullable()->after('student_type');

            // Temporary Password
            $table->string('temporary_password')->default('Fisk123')->after('password');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'first_name',
                'last_name',
                'middle_initial',
                'student_id',
                'university_email',
                'personal_email',
                'department',
                'major',
                'class_level',
                'enrollment_status',
                'student_type',
                'citizenship_status',
                'temporary_password',
            ]);
        });
    }
};
