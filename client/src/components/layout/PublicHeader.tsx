"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect } from "react";
import { useAuth } from "@/hooks/useAuth";

export function PublicHeader() {
  const { isAuthenticated, checkAuth, token, user } = useAuth();
  const pathname = usePathname();

  // Validate authentication when navigating to different pages
  useEffect(() => {
    // Only validate if we think we're authenticated (to avoid unnecessary checks)
    if (isAuthenticated || token) {
      // Re-validate token to ensure it's still valid
      checkAuth();
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [pathname]); // Only check on pathname change to avoid loops

  // Only show "My account" if user is authenticated AND has a valid token AND user data
  const shouldShowMyAccount = isAuthenticated && token && user;

  // Helper function to check if a link is active
  const isActive = (href: string) => {
    if (href === "/") {
      return pathname === "/";
    }
    return pathname.startsWith(href);
  };

  return (
    <div className="sticky top-0 z-50 w-full">
      {/* Top contact / quick links bar */}
      <div className="w-full bg-[#06244d] text-white text-xs sm:text-sm shadow-md">
        <div className="max-w-7xl mx-auto flex flex-col sm:flex-row items-center justify-between py-2 px-4 gap-2 sm:gap-0">
          {/* Left Contact Info */}
          <div className="flex items-center gap-4 sm:gap-6">
            {/* Phone */}
            <div className="flex items-center gap-2">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                className="h-4 w-4 text-yellow-400"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
                strokeWidth={2}
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  d="M3 5a2 2 0 012-2h1.28a2 2 0 011.94 1.52l.72 3a2 2 0 01-.91 2.21l-.92.55a11.04 11.04 0 005.51 5.51l.55-.92a2 2 0 012.21-.91l3 .72A2 2 0 0121 18.72V20a2 2 0 01-2 2h-1A16 16 0 013 5V5z"
                />
              </svg>
              <span className="text-white/80">(+1) 615‑000‑0000</span>
            </div>

            {/* Divider */}
            <div className="hidden sm:block w-px h-4 bg-white/30" />

            {/* Email */}
            <div className="hidden sm:flex items-center gap-2">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                className="h-4 w-4 text-yellow-400"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
                strokeWidth={2}
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8m-18 8h18a2 2 0 002-2V6a2 2 0 00-2-2H3a2 2 0 00-2 2v10a2 2 0 002 2z"
                />
              </svg>
              <span className="text-white/80">elections@fisk.edu</span>
            </div>
          </div>

          {/* Right (Login / Register / Social Icons) */}
          <div className="flex items-center gap-4 sm:gap-6">
            {shouldShowMyAccount ? (
              <Link href="/dashboard" className="hover:underline text-white/90">
                Go to dashboard
              </Link>
            ) : (
              <>
                <Link href="/login" className="hover:underline text-white/90">
                  Log in
                </Link>
                <Link href="/register" className="hover:underline text-white/90">
                  Register
                </Link>
              </>
            )}

            {/* Divider */}
            <div className="hidden sm:block w-px h-4 bg-white/30" />

            {/* Social Icons */}
            <div className="flex items-center gap-3 text-white">
              {/* X / Twitter */}
              <a
                href="https://x.com/fiskuniversity"
                target="_blank"
                rel="noreferrer"
                aria-label="Fisk University on X (Twitter)"
              >
                <svg
                  className="h-4 w-4 cursor-pointer hover:text-gray-300"
                  viewBox="0 0 24 24"
                  fill="currentColor"
                >
                  <path d="M18.244 2.25h3.308l-7.227 8.26L22 21.75h-6.343l-4.948-6.479-5.657 6.479H1.744l7.73-8.852L2 2.25h6.453l4.534 5.993 5.257-5.993z" />
                </svg>
              </a>
              {/* Facebook */}
              <a
                href="https://www.facebook.com/FiskUniv/"
                target="_blank"
                rel="noreferrer"
                aria-label="Fisk University on Facebook"
              >
                <svg
                  className="h-4 w-4 cursor-pointer hover:text-gray-300"
                  xmlns="http://www.w3.org/2000/svg"
                  fill="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path d="M22 12a10 10 0 10-11.5 9.87v-7h-2v-3h2v-2.3c0-2 1.2-3.1 3-3.1.9 0 1.8.07 2 .1v2.3h-1.1c-1 0-1.3.49-1.3 1.2V12h2.5l-.4 3h-2.1v7A10 10 0 0022 12z" />
                </svg>
              </a>
              {/* Instagram */}
              <a
                href="https://www.instagram.com/fiskuniversity/"
                target="_blank"
                rel="noreferrer"
                aria-label="Fisk University on Instagram"
              >
                <svg
                  className="h-4 w-4 cursor-pointer hover:text-gray-300"
                  fill="currentColor"
                  xmlns="http://www.w3.org/2000/svg"
                  viewBox="0 0 24 24"
                >
                  <path d="M7 2C4.24 2 2 4.24 2 7v10c0 2.76 2.24 5 5 5h10c2.76 0 5-2.24 5-5V7c0-2.76-2.24-5-5-5H7zm10 2c1.66 0 3 1.34 3 3v10c0 1.66-1.34 3-3 3H7c-1.66 0-3-1.34-3-3V7c0-1.66 1.34-3 3-3h10zm-5 3.5A5.51 5.51 0 006.5 13 5.5 5.5 0 1012 7.5zm0 2A3.5 3.5 0 1112 14a3.5 3.5 0 010-7zm4.75-.88a1.12 1.12 0 11-2.24 0 1.12 1.12 0 012.24 0z" />
                </svg>
              </a>
              {/* LinkedIn */}
              <a
                href="https://www.linkedin.com/school/fisk-university/"
                target="_blank"
                rel="noreferrer"
                aria-label="Fisk University on LinkedIn"
              >
                <svg
                  className="h-4 w-4 cursor-pointer hover:text-gray-300"
                  xmlns="http://www.w3.org/2000/svg"
                  fill="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path d="M4.98 3.5C4.98 4.88 3.88 6 2.5 6S0 4.88 0 3.5 1.12 1 2.5 1 4.98 2.12 4.98 3.5zM.5 8h4V24h-4V8zm7 0h3.8v2.04h.05c.53-1 1.83-2.04 3.77-2.04 4.03 0 4.78 2.67 4.78 6.14V24h-4v-7.88c0-1.88-.03-4.3-2.62-4.3-2.62 0-3.02 2.05-3.02 4.17V24h-4V8z" />
                </svg>
              </a>
            </div>
          </div>
        </div>
      </div>

      {/* Main navigation bar (centered links) */}
      <nav className="w-full bg-white border-b border-slate-100 shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-14 flex items-center justify-between gap-4">
          {/* Logo / Brand */}
          <div className="flex items-center gap-2">
            <div className="h-8 w-8 rounded-full bg-gradient-to-br from-slate-900 to-[#f4ba1b] flex items-center justify-center text-[11px] font-bold text-white shadow-sm">
              FV
            </div>
            <div className="leading-tight">
              <p className="text-xs sm:text-sm font-semibold text-slate-900">Fisk Voting System</p>
              <p className="hidden sm:block text-[10px] text-slate-500">Modern campus elections</p>
            </div>
          </div>

          {/* Centered nav links */}
          <div className="flex-1 flex justify-center">
            <div className="hidden md:flex items-center gap-5 text-xs sm:text-sm font-medium">
              <Link
                href="/"
                className={`relative transition-colors ${
                  isActive("/")
                    ? "text-slate-900 font-semibold"
                    : "text-slate-600 hover:text-slate-900"
                }`}
              >
                Home
                {isActive("/") && (
                  <span className="absolute -bottom-1 left-0 right-0 h-0.5 bg-[#f4ba1b] rounded-full" />
                )}
              </Link>
              <Link
                href="/elections"
                className={`relative transition-colors ${
                  isActive("/elections")
                    ? "text-slate-900 font-semibold"
                    : "text-slate-600 hover:text-slate-900"
                }`}
              >
                Elections
                {isActive("/elections") && (
                  <span className="absolute -bottom-1 left-0 right-0 h-0.5 bg-[#f4ba1b] rounded-full" />
                )}
              </Link>
              <Link
                href="/dashboard/calendar"
                className={`relative transition-colors ${
                  isActive("/dashboard/calendar")
                    ? "text-slate-900 font-semibold"
                    : "text-slate-600 hover:text-slate-900"
                }`}
              >
                Calendar
                {isActive("/dashboard/calendar") && (
                  <span className="absolute -bottom-1 left-0 right-0 h-0.5 bg-[#f4ba1b] rounded-full" />
                )}
              </Link>
              <Link
                href="/blog"
                className={`relative transition-colors ${
                  isActive("/blog")
                    ? "text-slate-900 font-semibold"
                    : "text-slate-600 hover:text-slate-900"
                }`}
              >
                Blog &amp; News
                {isActive("/blog") && (
                  <span className="absolute -bottom-1 left-0 right-0 h-0.5 bg-[#f4ba1b] rounded-full" />
                )}
              </Link>
              <Link
                href="/events"
                className={`relative transition-colors ${
                  isActive("/events")
                    ? "text-slate-900 font-semibold"
                    : "text-slate-600 hover:text-slate-900"
                }`}
              >
                Events
                {isActive("/events") && (
                  <span className="absolute -bottom-1 left-0 right-0 h-0.5 bg-[#f4ba1b] rounded-full" />
                )}
              </Link>
              <Link
                href="/about"
                className={`relative transition-colors ${
                  isActive("/about")
                    ? "text-slate-900 font-semibold"
                    : "text-slate-600 hover:text-slate-900"
                }`}
              >
                About Us
                {isActive("/about") && (
                  <span className="absolute -bottom-1 left-0 right-0 h-0.5 bg-[#f4ba1b] rounded-full" />
                )}
              </Link>
              <Link
                href="/faq"
                className={`relative transition-colors ${
                  isActive("/faq")
                    ? "text-slate-900 font-semibold"
                    : "text-slate-600 hover:text-slate-900"
                }`}
              >
                FAQ
                {isActive("/faq") && (
                  <span className="absolute -bottom-1 left-0 right-0 h-0.5 bg-[#f4ba1b] rounded-full" />
                )}
              </Link>
              {shouldShowMyAccount && (
                <Link
                  href="/dashboard/settings"
                  className={`relative transition-colors ${
                    isActive("/dashboard/settings")
                      ? "text-slate-900 font-semibold"
                      : "text-slate-600 hover:text-slate-900"
                  }`}
                >
                  My account
                  {isActive("/dashboard/settings") && (
                    <span className="absolute -bottom-1 left-0 right-0 h-0.5 bg-[#f4ba1b] rounded-full" />
                  )}
                </Link>
              )}
            </div>
          </div>

          {/* Right spacer to balance layout */}
          <div className="w-8" />
        </div>
      </nav>
    </div>
  );
}


