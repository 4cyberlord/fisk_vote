"use client";

import Link from "next/link";
import { useAuth } from "@/hooks/useAuth";

export function PublicFooter() {
  const { isAuthenticated } = useAuth();

  return (
    <footer className="border-t border-slate-200 bg-slate-50 mt-4">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 space-y-6 text-[11px] sm:text-xs text-slate-500">
        <div className="grid grid-cols-1 sm:grid-cols-4 gap-6 border-b border-slate-200 pb-6">
          {/* Product */}
          <div>
            <p className="text-[11px] font-semibold uppercase tracking-[0.16em] text-slate-700 mb-3">
              Product
            </p>
            <ul className="space-y-1.5">
              <li>
                <Link href="/" className="hover:text-slate-900 hover:underline underline-offset-4">
                  Home
                </Link>
              </li>
              <li>
                <Link
                  href="/elections"
                  className="hover:text-slate-900 hover:underline underline-offset-4"
                >
                  Elections
                </Link>
              </li>
              <li>
                <Link
                  href="/dashboard/calendar"
                  className="hover:text-slate-900 hover:underline underline-offset-4"
                >
                  Calendar
                </Link>
              </li>
              <li>
                <Link
                  href="/blog"
                  className="hover:text-slate-900 hover:underline underline-offset-4"
                >
                  Blog &amp; News
                </Link>
              </li>
              <li>
                <Link
                  href="/events"
                  className="hover:text-slate-900 hover:underline underline-offset-4"
                >
                  Events
                </Link>
              </li>
            </ul>
          </div>

          {/* About */}
          <div>
            <p className="text-[11px] font-semibold uppercase tracking-[0.16em] text-slate-700 mb-3">
              About
            </p>
            <ul className="space-y-1.5">
              <li>
                <Link
                  href="/about"
                  className="hover:text-slate-900 hover:underline underline-offset-4"
                >
                  About Us
                </Link>
              </li>
              <li>
                <Link
                  href="/security"
                  className="hover:text-slate-900 hover:underline underline-offset-4"
                >
                  Security &amp; transparency
                </Link>
              </li>
              <li>
                <Link
                  href="/faq"
                  className="hover:text-slate-900 hover:underline underline-offset-4"
                >
                  FAQ
                </Link>
              </li>
              <li>
                <Link
                  href="/contact"
                  className="hover:text-slate-900 hover:underline underline-offset-4"
                >
                  Contact
                </Link>
              </li>
            </ul>
          </div>

          {/* Help & Legal */}
          <div>
            <p className="text-[11px] font-semibold uppercase tracking-[0.16em] text-slate-700 mb-3">
              Help &amp; Legal
            </p>
            <ul className="space-y-1.5">
              <li>
                <Link
                  href="/terms"
                  className="hover:text-slate-900 hover:underline underline-offset-4"
                >
                  Terms of Use
                </Link>
              </li>
              <li>
                <Link
                  href="/privacy"
                  className="hover:text-slate-900 hover:underline underline-offset-4"
                >
                  Privacy Policy
                </Link>
              </li>
              <li>
                <Link
                  href="/cookies"
                  className="hover:text-slate-900 hover:underline underline-offset-4"
                >
                  Cookie Policy
                </Link>
              </li>
              <li>
                <Link
                  href="/support"
                  className="hover:text-slate-900 hover:underline underline-offset-4"
                >
                  Support
                </Link>
              </li>
            </ul>
          </div>

          {/* Account */}
          <div>
            <p className="text-[11px] font-semibold uppercase tracking-[0.16em] text-slate-700 mb-3">
              Account
            </p>
            <ul className="space-y-1.5">
              <li>
                <Link
                  href="/login"
                  className="hover:text-slate-900 hover:underline underline-offset-4"
                >
                  Login
                </Link>
              </li>
              {isAuthenticated && (
                <li>
                  <Link
                    href="/dashboard/settings"
                    className="hover:text-slate-900 hover:underline underline-offset-4"
                  >
                    My account
                  </Link>
                </li>
              )}
            </ul>
          </div>
        </div>

        <div className="flex flex-col sm:flex-row gap-3 sm:items-center sm:justify-between pt-2">
          <div className="space-y-1">
            <p>
              © {new Date().getFullYear()} Fisk Voting System. Demo environment for campus elections.
            </p>
            <p>
              Built with Laravel, Next.js, and a focus on transparency, auditability, and student
              experience.
            </p>
          </div>
          <div className="flex flex-wrap gap-3">
            <span className="text-slate-500/80">Fisk University</span>
            <span className="text-slate-500/80">Secure campus voting</span>
          </div>
        </div>
      </div>
    </footer>
  );
}


