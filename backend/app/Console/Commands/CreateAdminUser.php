<?php

namespace App\Console\Commands;

use App\Models\User;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Hash;
use Spatie\Permission\Models\Role;

class CreateAdminUser extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'user:create-admin 
                            {--email=iadmin@my.fisk.edu : The email address for the admin user}
                            {--password= : The password for the admin user (default: Admin123!)}
                            {--name=Admin User : The name for the admin user}
                            {--first-name=Admin : The first name for the admin user}
                            {--last-name=User : The last name for the admin user}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Create an admin user with Admin role';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $email = $this->option('email');
        $password = $this->option('password') ?: 'Admin123!';
        $name = $this->option('name');
        $firstName = $this->option('first-name');
        $lastName = $this->option('last-name');

        // Check if user already exists
        $existingUser = User::where('email', $email)->first();
        
        if ($existingUser) {
            $this->warn("User with email {$email} already exists!");
            
            if (!$this->confirm('Do you want to update this user to admin?', false)) {
                $this->info('Operation cancelled.');
                return Command::FAILURE;
            }

            // Update existing user
            $existingUser->update([
                'name' => $name,
                'first_name' => $firstName,
                'last_name' => $lastName,
                'password' => Hash::make($password),
                'email_verified_at' => now(),
            ]);

            // Remove Student role if exists
            if ($existingUser->hasRole('Student')) {
                $existingUser->removeRole('Student');
            }

            // Assign Admin role
            $adminRole = Role::firstOrCreate(['name' => 'Admin', 'guard_name' => 'web']);
            if (!$existingUser->hasRole('Admin')) {
                $existingUser->assignRole($adminRole);
            }

            $this->info("✓ User updated successfully!");
            $this->info("  Email: {$email}");
            $this->info("  Password: {$password}");
            $this->info("  Role: Admin");
            
            return Command::SUCCESS;
        }

        // Create new admin user
        try {
            // Temporarily disable the boot method's role assignment
            // We'll assign Admin role manually
            $user = User::withoutEvents(function () use ($email, $password, $name, $firstName, $lastName) {
                return User::create([
                    'name' => $name,
                    'first_name' => $firstName,
                    'last_name' => $lastName,
                    'email' => $email,
                    'university_email' => $email,
                    'password' => Hash::make($password),
                    'email_verified_at' => now(), // Auto-verify admin email
                ]);
            });

            // Remove Student role if it was auto-assigned
            if ($user->hasRole('Student')) {
                $user->removeRole('Student');
            }

            // Assign Admin role
            $adminRole = Role::firstOrCreate(['name' => 'Admin', 'guard_name' => 'web']);
            $user->assignRole($adminRole);

            $this->info("✓ Admin user created successfully!");
            $this->info("  Email: {$email}");
            $this->info("  Password: {$password}");
            $this->info("  Name: {$name}");
            $this->info("  Role: Admin");
            $this->info("  Email Verified: Yes");

            return Command::SUCCESS;

        } catch (\Exception $e) {
            $this->error("Failed to create admin user: " . $e->getMessage());
            return Command::FAILURE;
        }
    }
}

