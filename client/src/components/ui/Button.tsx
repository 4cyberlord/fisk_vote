import React from "react";
import { cn } from "@/lib/utils";

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: "primary" | "secondary" | "outline";
  fullWidth?: boolean;
  children: React.ReactNode;
}

export const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  (
    {
      variant = "primary",
      fullWidth = false,
      className,
      children,
      ...props
    },
    ref
  ) => {
    return (
      <button
        ref={ref}
        className={cn(
          "font-semibold py-3 rounded-lg shadow-md transition focus:outline-none focus:ring-2 focus:ring-offset-2",
          variant === "primary" &&
            "bg-indigo-600 hover:bg-indigo-500 text-white focus:ring-indigo-500 disabled:bg-indigo-400 disabled:cursor-not-allowed",
          variant === "secondary" &&
            "bg-gray-600 hover:bg-gray-500 text-white focus:ring-gray-500 disabled:bg-gray-400 disabled:cursor-not-allowed",
          variant === "outline" &&
            "bg-transparent border-2 border-indigo-600 text-indigo-600 hover:bg-indigo-600 hover:text-white focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed",
          fullWidth && "w-full",
          className
        )}
        {...props}
      >
        {children}
      </button>
    );
  }
);

Button.displayName = "Button";

