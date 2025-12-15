"use client";

import { useEffect } from "react";
import { useAuthStore } from "@/store/authStore";

/**
 * Component that validates authentication token on app initialization
 * This ensures isAuthenticated state is accurate and expired tokens are cleared
 */
export function AuthChecker() {
  const { checkAuth, isAuthenticated, token } = useAuthStore();

  useEffect(() => {
    // Validate token on mount
    const validateAuth = () => {
      if (token || isAuthenticated) {
        const isValid = checkAuth();
        
        if (!isValid) {
          // Token is invalid/expired - state is already cleared by checkAuth
          console.log("AuthChecker: Token validation failed, user logged out");
        } else {
          console.log("AuthChecker: Token validated successfully");
        }
      } else {
        // No token exists, ensure state is cleared
        if (isAuthenticated) {
          useAuthStore.getState().logout();
        }
      }
    };

    // Run validation on mount
    validateAuth();
  }, []); // Only run on mount

  return null; // This component doesn't render anything
}

