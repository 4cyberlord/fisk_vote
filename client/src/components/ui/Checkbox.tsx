import React from "react";
import { cn } from "@/lib/utils";

interface CheckboxProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string | React.ReactNode;
  error?: string;
}

export const Checkbox = React.forwardRef<HTMLInputElement, CheckboxProps>(
  ({ label, error, className, ...props }, ref) => {
    return (
      <div>
        <div className="flex items-start">
          <input
            ref={ref}
            type="checkbox"
            className={cn(
              "mt-1 h-4 w-4 text-indigo-600 rounded-md bg-[#1e293b] border-gray-600 focus:ring-indigo-500 cursor-pointer",
              error && "border-red-500",
              className
            )}
            {...props}
          />
          {label && (
            <label htmlFor={props.id} className="ml-2 text-sm text-gray-400 cursor-pointer">
              {label}
            </label>
          )}
        </div>
        {error && <p className="mt-1 text-sm text-red-400">{error}</p>}
      </div>
    );
  }
);

Checkbox.displayName = "Checkbox";

