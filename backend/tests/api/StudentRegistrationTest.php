<?php

namespace Tests\Api;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class StudentRegistrationTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test successful student registration
     */
    public function test_student_can_register_successfully(): void
    {
        $response = $this->postJson('/api/v1/students/register', [
            'first_name' => 'John',
            'middle_initial' => 'M',
            'last_name' => 'Doe',
            'student_id' => '123456789',
            'email' => 'john.doe@my.fisk.edu',
            'password' => 'SecurePassword123!',
            'password_confirmation' => 'SecurePassword123!',
            'accept_terms' => true,
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
            ])
            ->assertJsonStructure([
                'success',
                'message',
                'user' => [
                    'id',
                    'email',
                    'name',
                ],
            ]);

        $this->assertDatabaseHas('users', [
            'email' => 'john.doe@my.fisk.edu',
            'student_id' => '123456789',
        ]);

        $user = User::where('email', 'john.doe@my.fisk.edu')->first();
        $this->assertTrue($user->hasRole('Student'));
    }

    /**
     * Test registration fails with invalid email domain
     */
    public function test_registration_fails_with_invalid_email_domain(): void
    {
        $response = $this->postJson('/api/v1/students/register', [
            'first_name' => 'John',
            'last_name' => 'Doe',
            'student_id' => '123456789',
            'email' => 'john.doe@gmail.com', // Invalid domain
            'password' => 'SecurePassword123!',
            'password_confirmation' => 'SecurePassword123!',
            'accept_terms' => true,
        ]);

        $response->assertStatus(422)
            ->assertJson([
                'success' => false,
            ])
            ->assertJsonValidationErrors(['email']);
    }

    /**
     * Test registration fails with duplicate email
     */
    public function test_registration_fails_with_duplicate_email(): void
    {
        User::factory()->create([
            'email' => 'existing@my.fisk.edu',
        ]);

        $response = $this->postJson('/api/v1/students/register', [
            'first_name' => 'John',
            'last_name' => 'Doe',
            'student_id' => '123456789',
            'email' => 'existing@my.fisk.edu',
            'password' => 'SecurePassword123!',
            'password_confirmation' => 'SecurePassword123!',
            'accept_terms' => true,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['email']);
    }

    /**
     * Test registration fails with duplicate student ID
     */
    public function test_registration_fails_with_duplicate_student_id(): void
    {
        User::factory()->create([
            'student_id' => '123456789',
        ]);

        $response = $this->postJson('/api/v1/students/register', [
            'first_name' => 'John',
            'last_name' => 'Doe',
            'student_id' => '123456789',
            'email' => 'john.doe@my.fisk.edu',
            'password' => 'SecurePassword123!',
            'password_confirmation' => 'SecurePassword123!',
            'accept_terms' => true,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['student_id']);
    }

    /**
     * Test registration fails with password mismatch
     */
    public function test_registration_fails_with_password_mismatch(): void
    {
        $response = $this->postJson('/api/v1/students/register', [
            'first_name' => 'John',
            'last_name' => 'Doe',
            'student_id' => '123456789',
            'email' => 'john.doe@my.fisk.edu',
            'password' => 'SecurePassword123!',
            'password_confirmation' => 'DifferentPassword123!',
            'accept_terms' => true,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['password']);
    }

    /**
     * Test registration fails without accepting terms
     */
    public function test_registration_fails_without_accepting_terms(): void
    {
        $response = $this->postJson('/api/v1/students/register', [
            'first_name' => 'John',
            'last_name' => 'Doe',
            'student_id' => '123456789',
            'email' => 'john.doe@my.fisk.edu',
            'password' => 'SecurePassword123!',
            'password_confirmation' => 'SecurePassword123!',
            'accept_terms' => false,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['accept_terms']);
    }
}

