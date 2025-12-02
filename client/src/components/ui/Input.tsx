import React from "react";
import { cn } from "@/lib/utils";

interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  error?: string;
}

export const Input = React.forwardRef<HTMLInputElement, InputProps>(
  ({ label, error, className, ...props }, ref) => {
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
        <input
          ref={ref}
          className={cn(
            "w-full rounded-lg bg-[#1e293b] border border-white/10 px-5 py-4 text-base text-gray-200 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500 focus:outline-none transition-colors",
            error && "border-red-500",
            className
          )}
          {...props}
        />
        {error && <p className="mt-1 text-sm text-red-400">{error}</p>}
      </div>
    );
  }
);

Input.displayName = "Input";

