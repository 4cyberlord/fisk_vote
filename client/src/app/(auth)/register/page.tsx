"use client";

import { useRouter } from "next/navigation";
import Link from "next/link";
import Image from "next/image";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { Input, PasswordInput, Checkbox, Button, Logo } from "@/components";
import { registerSchema, type RegisterFormData } from "@/lib/schemas/authSchemas";
import toast from "react-hot-toast";

export default function RegisterPage() {
  const router = useRouter();

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<RegisterFormData>({
    resolver: zodResolver(registerSchema),
  });

  const onSubmit = async (data: RegisterFormData) => {
    try {
      const payload: Record<string, any> = {
        first_name: data.first_name,
        last_name: data.last_name,
        student_id: data.student_id,
        email: data.email,
        password: data.password,
        password_confirmation: data.passwordConfirmation,
        accept_terms: data.accept_terms,
      };

      // Only include middle_initial if it has a value
      if (data.middle_initial && data.middle_initial.trim()) {
        payload.middle_initial = data.middle_initial.trim();
      }

      const response = await fetch("/api/students/register", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(payload),
      });

      const result = await response.json();

      if (!response.ok) {
        // Handle validation errors
        if (result.errors) {
          // Show first error from each field
          Object.keys(result.errors).forEach((key) => {
            const errorMessage = Array.isArray(result.errors[key])
              ? result.errors[key][0]
              : result.errors[key];
            toast.error(errorMessage);
          });
        } else {
          toast.error(result.message || "Registration failed");
        }
        return;
      }

      // Success
      toast.success(
        `Registration successful!\nPlease check your email (${data.email}) to verify your account.`
      );

      // Redirect to login page after 2 seconds
      setTimeout(() => {
        router.push("/login");
      }, 2000);
    } catch (error) {
      console.error("Registration error:", error);
      toast.error("Failed to connect to server. Please try again later.");
    }
  };

  return (
    <div className="h-screen flex bg-[#0f172a]">
      {/* LEFT SIDE - Form */}
      <div className="w-full lg:max-w-[50%] lg:w-1/2 h-full bg-[#0f172a] flex items-center justify-center overflow-y-auto">
        <div className="w-full max-w-3xl p-8 lg:p-12 flex flex-col justify-center">
          {/* Logo */}
          <div className="mb-10">
            <Logo />
          </div>

          <h2 className="text-3xl font-bold text-white mb-2">Create your account</h2>
          <p className="text-sm text-gray-400 mb-8">
            Already have an account?{" "}
            <Link href="/login" className="text-indigo-400 hover:text-indigo-300 font-medium">
              Sign in
            </Link>
          </p>

          <form className="space-y-8" onSubmit={handleSubmit(onSubmit)}>
            {/* Personal Information */}
            <div className="space-y-5">
              <div className="pb-2 border-b border-white/10">
                <h3 className="text-lg font-semibold text-white">Personal Information</h3>
                <p className="text-xs text-gray-400 mt-1">Use your legal name as it appears on university records.</p>
              </div>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
                <Input
                  id="first_name"
                  type="text"
                  label="First Name"
                  autoComplete="given-name"
                  placeholder="John"
                  maxLength={255}
                  error={errors.first_name?.message}
                  {...register("first_name")}
                />
                <Input
                  id="middle_initial"
                  type="text"
                  label="Middle Name"
                  autoComplete="additional-name"
                  placeholder="Michael"
                  maxLength={255}
                  error={errors.middle_initial?.message}
                  {...register("middle_initial")}
                />
                <Input
                  id="last_name"
                  type="text"
                  label="Last Name"
                  autoComplete="family-name"
                  placeholder="Doe"
                  maxLength={255}
                  error={errors.last_name?.message}
                  {...register("last_name")}
                />
              </div>
            </div>

            {/* University Details */}
            <div className="space-y-5">
              <div className="pb-2 border-b border-white/10">
                <h3 className="text-lg font-semibold text-white">University Details</h3>
                <p className="text-xs text-gray-400 mt-1">We use your Fisk credentials to verify student eligibility.</p>
              </div>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                <Input
                  id="student_id"
                  type="text"
                  label="Student ID"
                  placeholder="123456789"
                  maxLength={255}
                  pattern="[0-9]*"
                  inputMode="numeric"
                  error={errors.student_id?.message}
                  {...register("student_id")}
                />
                <Input
                  id="email"
                  type="email"
                  label="Email (Fisk Email)"
                  autoComplete="email"
                  placeholder="you@my.fisk.edu"
                  maxLength={255}
                  error={errors.email?.message}
                  {...register("email")}
                />
              </div>
            </div>

            {/* Security */}
            <div className="space-y-5">
              <div className="pb-2 border-b border-white/10">
                <h3 className="text-lg font-semibold text-white">Security</h3>
                <p className="text-xs text-gray-400 mt-1">Create a secure password for your voting account.</p>
              </div>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                <PasswordInput
                  id="password"
                  label="Password"
                  autoComplete="new-password"
                  placeholder="••••••••"
                  error={errors.password?.message}
                  {...register("password")}
                />
                <PasswordInput
                  id="passwordConfirmation"
                  label="Confirm Password"
                  autoComplete="new-password"
                  placeholder="••••••••"
                  error={errors.passwordConfirmation?.message}
                  {...register("passwordConfirmation")}
                />
              </div>
            </div>

            {/* Terms and Conditions */}
            <div className="space-y-5">
              <div className="pb-2 border-b border-white/10">
                <h3 className="text-lg font-semibold text-white">Agreement</h3>
                <p className="text-xs text-gray-400 mt-1">You must agree to the Fisk Voting Terms & Policies to continue.</p>
              </div>
              <div className="pt-2">
                <Checkbox
                  id="accept_terms"
                  type="checkbox"
                  error={errors.accept_terms?.message}
                  {...register("accept_terms")}
                  label="I accept the Terms of Service and Voting Policy"
                />
              </div>
            </div>

            {/* Submit Button */}
            <div className="pt-4">
              <Button type="submit" fullWidth disabled={isSubmitting}>
                {isSubmitting ? "Creating account..." : "Create account"}
              </Button>
            </div>
          </form>
        </div>
      </div>

      {/* RIGHT SIDE - Election Image */}
      <div className="hidden lg:block relative flex-1 h-full w-full overflow-hidden">
        <Image
          src="https://images.unsplash.com/photo-1479772854944-5ef10e427d94?q=80&w=1318&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
          alt="Election voting image"
          fill
          className="object-cover"
          priority
          sizes="50vw"
          unoptimized={false}
        />
        <div className="absolute inset-0 bg-black/20 z-10"></div>
      </div>
    </div>
  );
}
