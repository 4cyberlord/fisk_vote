"use client";

import { useState } from "react";
import React from "react";
import { cn } from "@/lib/utils";

interface PasswordInputProps
  extends Omit<React.InputHTMLAttributes<HTMLInputElement>, "type"> {
  label?: string;
  error?: string;
}

export const PasswordInput = React.forwardRef<
  HTMLInputElement,
  PasswordInputProps
>(({ label, error, className, ...props }, ref) => {
  const [showPassword, setShowPassword] = useState(false);

  return (
    <div>
      {label && (
        <label
          htmlFor={props.id}
          className="block text-sm font-semibold text-gray-300 mb-2"
        >
          {label}
        </label>
      )}
      <div className="relative">
        <input
          ref={ref}
          type={showPassword ? "text" : "password"}
          className={cn(
            "w-full rounded-lg bg-[#1e293b] border border-white/10 px-5 py-4 pr-12 text-base text-gray-200 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500 focus:outline-none transition-colors",
            error && "border-red-500",
            className
          )}
          {...props}
        />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-4 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-300 focus:outline-none p-1"
                  aria-label={showPassword ? "Hide password" : "Show password"}
                >
          {showPassword ? (
            <svg
              className="w-5 h-5"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.29 3.29m13.42 13.42l-3.29-3.29M3 3l18 18"
              />
            </svg>
          ) : (
            <svg
              className="w-5 h-5"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
              />
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"
              />
            </svg>
          )}
        </button>
      </div>
      {error && <p className="mt-1 text-sm text-red-400">{error}</p>}
    </div>
  );
});

PasswordInput.displayName = "PasswordInput";

