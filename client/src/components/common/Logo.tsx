import React from "react";
import { cn } from "@/lib/utils";

interface LogoProps {
  className?: string;
  size?: "sm" | "md" | "lg";
}

export const Logo: React.FC<LogoProps> = ({ className, size = "md" }) => {
  return (
    <svg
      className={cn(
        "text-indigo-400",
        size === "sm" && "h-6 w-6",
        size === "md" && "h-10 w-10",
        size === "lg" && "h-16 w-16",
        className
      )}
      viewBox="0 0 24 24"
      fill="currentColor"
    >
      <path d="M12 3L2 9l10 6 10-6-10-6zm0 13l-10-6v8l10 6 10-6v-8l-10 6z" />
    </svg>
  );
};

