"use client";

import { useEffect, useState } from "react";
import { useRouter, usePathname } from "next/navigation";
import Cookies from "js-cookie";
import { jwtDecode } from "jwt-decode";

interface ProtectedRouteProps {
  children: React.ReactNode;
  redirectTo?: string;
}

export function ProtectedRoute({
  children,
  redirectTo = "/login",
}: ProtectedRouteProps) {
  const router = useRouter();
  const pathname = usePathname();
  const [isChecking, setIsChecking] = useState(true);
  const [isAuthorized, setIsAuthorized] = useState(false);

  useEffect(() => {
    const validateAuth = () => {
      const token = Cookies.get("auth_token");
      
      if (!token) {
        console.log("ProtectedRoute: No token found, redirecting to login");
        setIsChecking(false);
        setIsAuthorized(false);
        // Only redirect if we're not already on the login page
        if (pathname !== redirectTo) {
          router.push(redirectTo);
        }
        return;
      }

      // Validate token format before decoding
      // JWT tokens should have 3 parts separated by dots
      const tokenParts = token.split(".");
      if (tokenParts.length !== 3) {
        console.error("ProtectedRoute: Invalid token format - missing parts");
        console.error("Token length:", token.length);
        console.error("Token preview:", token.substring(0, 100));
        console.error("Token parts count:", tokenParts.length);
        setIsChecking(false);
        setIsAuthorized(false);
        // Remove invalid token
        Cookies.remove("auth_token", { path: "/" });
        if (pathname !== redirectTo) {
          router.push(redirectTo);
        }
        return;
      }

      try {
        const decoded = jwtDecode(token);
        const currentTime = Date.now() / 1000;

        // Check if token is expired
        if (decoded.exp && decoded.exp < currentTime) {
          console.log("ProtectedRoute: Token expired, redirecting to login");
          setIsChecking(false);
          setIsAuthorized(false);
          Cookies.remove("auth_token", { path: "/" });
          if (pathname !== redirectTo) {
            router.push(redirectTo);
          }
          return;
        }

        // Token is valid
        console.log("ProtectedRoute: Token valid, allowing access");
        setIsChecking(false);
        setIsAuthorized(true);
      } catch (error) {
        // Invalid token - could be malformed or corrupted
        console.error("ProtectedRoute: Token validation error:", error);
        setIsChecking(false);
        setIsAuthorized(false);
        // Remove invalid token
        Cookies.remove("auth_token", { path: "/" });
        if (pathname !== redirectTo) {
          router.push(redirectTo);
        }
      }
    };

    // Small delay to ensure cookie is available after redirect
    // This is especially important after window.location.href redirect
    const timer = setTimeout(() => {
      validateAuth();
    }, 300);

    return () => clearTimeout(timer);
  }, [router, redirectTo, pathname]);

  // Show loading state while checking auth
  if (isChecking) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-white">
        <div className="text-center">
          <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-500"></div>
          <p className="mt-4 text-gray-600">Loading...</p>
        </div>
      </div>
    );
  }

  // If not authorized, don't render children (redirect is happening)
  if (!isAuthorized) {
    return null;
  }

  return <>{children}</>;
}
