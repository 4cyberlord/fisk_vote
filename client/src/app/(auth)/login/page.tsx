"use client";

import { useState, useEffect, useRef, useCallback } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import Image from "next/image";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import Cookies from "js-cookie";
import { jwtDecode } from "jwt-decode";
import { Input, PasswordInput, Checkbox, Button, Logo } from "@/components";
import { loginSchema, type LoginFormData } from "@/lib/schemas/authSchemas";
import { useLogin } from "@/hooks/useAuth";

export default function LoginPage() {
  const router = useRouter();
  const loginMutation = useLogin();
  const [rememberMe, setRememberMe] = useState(false);
  const [isCheckingAuth, setIsCheckingAuth] = useState(true);
  // Remove separate error states - use React Hook Form's errors.root instead
  const authCheckedRef = useRef(false);
  const formRef = useRef<HTMLFormElement>(null);

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
    setError,
    clearErrors,
  } = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
  });
  
  // State changes are tracked internally by React Hook Form
  
  // Global error handler for uncaught errors (only in development)
  useEffect(() => {
    if (process.env.NODE_ENV !== "development") return;
    
    const handleError = (event: ErrorEvent) => {
      console.error("[LOGIN] Global Error:", event.error);
    };

    const handleUnhandledRejection = (event: PromiseRejectionEvent) => {
      console.error("[LOGIN] Unhandled Rejection:", event.reason);
    };

    window.addEventListener('error', handleError);
    window.addEventListener('unhandledrejection', handleUnhandledRejection);

    return () => {
      window.removeEventListener('error', handleError);
      window.removeEventListener('unhandledrejection', handleUnhandledRejection);
    };
  }, []);

  // CRITICAL FIX: Check authentication before rendering form
  // This prevents the flash/flicker issue as recommended by Next.js community
  // Based on: https://theodorusclarence.com/blog/nextjs-redirect-no-flashing
  useEffect(() => {
    if (authCheckedRef.current) {
      return;
    }
    authCheckedRef.current = true;

    try {
      const token = Cookies.get("auth_token");

      if (token) {
        try {
          const decoded = jwtDecode(token);
          const currentTime = Date.now() / 1000;

          if ((decoded as any).exp && (decoded as any).exp > currentTime) {
            router.replace("/dashboard");
            return;
          }
        } catch (error) {
          if (process.env.NODE_ENV === "development") {
            console.error("[LOGIN] Token decode error:", error);
          }
        }
      }

      setIsCheckingAuth(false);
    } catch (error) {
      if (process.env.NODE_ENV === "development") {
        console.error("[LOGIN] Auth check error:", error);
      }
      setIsCheckingAuth(false);
    }
  }, [router]);

  const onSubmit = useCallback(async (data: LoginFormData) => {
    try {
      // Clear previous errors immediately (synchronously)
      clearErrors(); // This clears all errors including errors.root

      await loginMutation.mutateAsync({
        email: data.email,
        password: data.password,
      });
    } catch (error: unknown) {
      // Extract error message from API response
      let errorMessage = "Email or password is incorrect. Please check your credentials and try again.";
      
      // Extract message from Axios error response
      if (error && typeof error === 'object' && 'response' in error) {
        const axiosError = error as {
          response?: {
            data?: {
              message?: string;
              success?: boolean;
              errors?: Record<string, unknown>;
            };
            status?: number;
          };
          message?: string;
          code?: string;
          isCorsError?: boolean;
        };
        
        const responseData = axiosError.response?.data;
        const status = axiosError.response?.status;
        
        // Only log in development
        if (process.env.NODE_ENV === "development") {
          console.error("[LOGIN] ERROR:", {
            status,
            message: responseData?.message || axiosError.message,
            code: axiosError.code,
          });
        }
        
        // Extract message from response
        if (responseData && typeof responseData === 'object' && responseData !== null) {
          const apiMessage = responseData.message;
          
          if (apiMessage && typeof apiMessage === 'string') {
            const messageLower = apiMessage.toLowerCase();
            
            // Handle different error types
            if (messageLower.includes("invalid") || 
                messageLower.includes("incorrect") || 
                messageLower.includes("credentials")) {
              // Generic auth error - use standardized message
              errorMessage = "Email or password is incorrect. Please check your credentials and try again.";
            } else if (messageLower.includes("verified") || messageLower.includes("verification")) {
              // Email verification error - use exact message
              errorMessage = apiMessage;
            } else if (messageLower.includes("validation failed")) {
              // Validation errors - extract from errors object
              if (responseData.errors && typeof responseData.errors === 'object') {
                const firstError = Object.values(responseData.errors)[0];
                if (Array.isArray(firstError) && firstError.length > 0) {
                  errorMessage = String(firstError[0]);
                } else if (typeof firstError === 'string') {
                  errorMessage = firstError;
                }
              } else {
                errorMessage = apiMessage;
              }
            } else {
              // Use the API message as-is for other errors
              errorMessage = apiMessage;
            }
          }
        }
        
        // Check for CORS/network errors
        if (axiosError.isCorsError || axiosError.code === 'ERR_NETWORK' || axiosError.message === 'Network Error') {
          errorMessage = "Connection error. Please ensure the backend server is running and CORS is properly configured.";
        }
      }
      
      // Set form errors - this is synchronous and prevents flicker
      setError("root", {
        type: "manual",
        message: errorMessage,
      });
      
      // Also set field-level errors for visual feedback (red borders)
      setError("email", {
        type: "manual",
        message: "Email or password is incorrect",
      });
      setError("password", {
        type: "manual",
        message: "Email or password is incorrect",
      });
    }
  }, [loginMutation, setError, clearErrors]);

  // CRITICAL: Show full-page loader while checking authentication
  // This prevents any flash of the login form for authenticated users
  // Based on: https://theodorusclarence.com/blog/nextjs-redirect-no-flashing
  if (isCheckingAuth) {
    return (
      <div className="h-screen flex items-center justify-center bg-[#0f172a]">
        <div className="text-center">
          <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-500"></div>
          <p className="mt-4 text-gray-400">Loading...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="h-screen flex bg-[#0f172a]">
      {/* LEFT SIDE - Form */}
      <div className="w-full lg:max-w-[50%] lg:w-1/2 h-full bg-[#0f172a] flex items-center justify-center">
        <div className="w-full max-w-xl p-10 flex flex-col justify-center">
          {/* Logo */}
          <div className="mb-10">
            <Logo />
          </div>

          <h2 className="text-3xl font-bold text-white">Sign in to your account</h2>
          <p className="mt-2 text-sm text-gray-400">
            Don&apos;t have an account?{" "}
            <Link href="/register" className="text-indigo-400 hover:text-indigo-300">
              Create an account
            </Link>
          </p>

          <form 
            ref={formRef}
            className="mt-10 space-y-6" 
            onSubmit={(e) => {
              // CRITICAL: Prevent default form submission behavior
              // This is the primary fix recommended by Next.js documentation
              e.preventDefault();
              e.stopPropagation();
              
              // Prevent event bubbling completely
              const nativeEvent = e.nativeEvent as Event;
              if (nativeEvent.stopImmediatePropagation) {
                nativeEvent.stopImmediatePropagation();
              }
              
              // Call react-hook-form's handleSubmit
              handleSubmit(onSubmit)(e);
              
              // Return false to prevent any default behavior
              return false;
            }}
            noValidate
          >
            {/* General Error Message - Reserve space to prevent layout shift */}
            {/* CRITICAL FIX: Use errors.root instead of separate state */}
            <div className="min-h-[80px]">
              {errors.root && (
                <div 
                  data-error-banner
                  className="rounded-lg bg-red-500/10 border border-red-500/20 p-4"
                >
                  <div className="flex items-start gap-3">
                    <svg
                      className="w-5 h-5 text-red-400 mt-0.5 flex-shrink-0"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth={2}
                        d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                      />
                    </svg>
                    <div>
                      <p className="text-sm font-medium text-red-400">
                        {errors.root.message}
                      </p>
                      <p className="text-xs text-red-300/80 mt-1">
                        Please check your email and password and try again.
                      </p>
                    </div>
                  </div>
                </div>
              )}
            </div>

            {/* Email */}
            <Input
              id="email"
              type="email"
              label="Email address"
              autoComplete="email"
              placeholder="you@my.fisk.edu"
              error={errors.email?.message}
              {...register("email", {
                onChange: (e) => {
                  // Only clear errors if user is actually typing (not from form reset)
                  const currentValue = (e.target as HTMLInputElement).value;
                  // Only clear if there's actual content and errors exist
                  if (currentValue.length > 0 && (errors.email || errors.root)) {
                    clearErrors("email");
                    clearErrors("root"); // Clear root error when user starts typing
                  }
                },
              })}
            />

            {/* Password */}
            <PasswordInput
              id="password"
              label="Password"
              autoComplete="current-password"
              placeholder="••••••••"
              error={errors.password?.message}
              {...register("password", {
                onChange: (e) => {
                  // Only clear errors if user is actually typing (not from form reset)
                  const currentValue = (e.target as HTMLInputElement).value;
                  // Only clear if there's actual content and errors exist
                  if (currentValue.length > 0 && (errors.password || errors.root)) {
                    clearErrors("password");
                    clearErrors("root"); // Clear root error when user starts typing
                  }
                },
              })}
            />

            {/* Remember + Forgot */}
            <div className="flex items-center justify-between">
              <Checkbox
                id="remember"
                checked={rememberMe}
                onChange={(e) => setRememberMe(e.target.checked)}
                label="Remember me"
              />
              <Link
                href="/forgot-password"
                className="text-indigo-400 hover:text-indigo-300 text-sm"
              >
                Forgot password?
              </Link>
            </div>

            {/* Submit Button */}
            <Button
              type="submit"
              fullWidth
              disabled={isSubmitting || loginMutation.isPending}
            >
              {isSubmitting || loginMutation.isPending ? "Signing in..." : "Sign in"}
            </Button>
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
