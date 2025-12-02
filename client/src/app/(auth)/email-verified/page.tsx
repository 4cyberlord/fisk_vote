"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";

export default function EmailVerifiedPage() {
  const router = useRouter();
  const [countdown, setCountdown] = useState(3);

  // Countdown timer
  useEffect(() => {
    const timer = setInterval(() => {
      setCountdown((prev) => {
        if (prev <= 1) {
          clearInterval(timer);
          return 0;
        }
        return prev - 1;
      });
    }, 1000);

    // Cleanup on unmount
    return () => clearInterval(timer);
  }, []);

  // Redirect when countdown reaches 0
  useEffect(() => {
    if (countdown === 0) {
      router.push("/login");
    }
  }, [countdown, router]);

  return (
    <div className="bg-white min-h-screen flex items-center justify-center p-4 sm:p-6">
      <div className="text-center animate-fade-in w-full max-w-md mx-auto">
        {/* Emoji */}
        <div className="text-5xl sm:text-6xl mb-4 sm:mb-6">🎉</div>

        {/* Heading */}
        <h1 className="text-2xl sm:text-3xl font-bold text-gray-900 px-4">
          Email Verified!
        </h1>

        {/* Subheading */}
        <p className="mt-2 text-gray-600 text-base sm:text-lg px-4">
          Your account is ready!
        </p>

        {/* Login Link */}
        <Link
          href="/login"
          className="mt-6 sm:mt-8 inline-flex items-center text-indigo-600 font-medium text-base sm:text-lg hover:text-indigo-500 transition px-4"
        >
          Continue to Login
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            strokeWidth="2"
            stroke="currentColor"
            className="w-4 h-4 sm:w-5 sm:h-5 ml-1"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              d="M13 5l7 7-7 7M5 12h14"
            />
          </svg>
        </Link>

        {/* Redirect Notice */}
        <p className="mt-4 sm:mt-6 text-gray-500 text-xs sm:text-sm px-4">
          Redirecting you to the login page in <strong>{countdown} seconds</strong>...
          <br className="hidden sm:block" />
          <span className="sm:hidden"> </span>
          Or click the button above to continue manually.
        </p>
      </div>
    </div>
  );
}

