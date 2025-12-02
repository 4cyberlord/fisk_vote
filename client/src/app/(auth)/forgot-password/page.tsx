"use client";

import Link from "next/link";
import Image from "next/image";
import { Input, Button, Logo } from "@/components";

export default function ForgotPasswordPage() {
  return (
    <div className="h-screen flex bg-[#0f172a]">
      {/* LEFT SIDE - Form */}
      <div className="w-full lg:max-w-[50%] lg:w-1/2 h-full bg-[#0f172a] flex items-center justify-center overflow-y-auto">
        <div className="w-full max-w-xl p-8 lg:p-12 flex flex-col justify-center">
          {/* Logo */}
          <div className="mb-10">
            <Logo />
          </div>

          <h2 className="text-3xl font-bold text-white mb-2">Forgot your password?</h2>
          <p className="text-sm text-gray-400 mb-8">
            No worries, we&apos;ll send you reset instructions.
          </p>

          <form className="space-y-6" action="#" method="POST">
            {/* Email */}
            <Input
              id="email"
              name="email"
              type="email"
              label="Email address"
              autoComplete="email"
              required
              placeholder="you@my.fisk.edu"
              maxLength={255}
            />

            {/* Submit Button */}
            <Button type="submit" fullWidth>
              Send reset link
            </Button>

            {/* Back to Login */}
            <div className="text-center pt-4">
              <Link
                href="/login"
                className="text-indigo-400 hover:text-indigo-300 text-sm inline-flex items-center font-medium"
              >
                <svg
                  className="w-4 h-4 mr-1"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M10 19l-7-7m0 0l7-7m-7 7h18"
                  />
                </svg>
                Back to login
              </Link>
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

