"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { Home, ArrowLeft, Search, Compass } from "lucide-react";
import { PublicHeader } from "@/components/layout/PublicHeader";
import { PublicFooter } from "@/components/layout/PublicFooter";
import { Button } from "@/components";

export default function NotFound() {
  const router = useRouter();

  return (
    <div className="min-h-screen bg-white text-slate-900 flex flex-col">
      <PublicHeader />
      <main className="flex-1 flex items-center justify-center px-4 sm:px-6 lg:px-8 py-16 sm:py-20 lg:py-24">
        <div className="max-w-3xl mx-auto w-full">
          {/* Main Content Container */}
          <div className="text-center">
            {/* 404 Number Display */}
            <div className="mb-8">
              <div className="relative inline-block">
                <h1 className="text-[120px] sm:text-[160px] lg:text-[200px] font-extrabold text-transparent bg-clip-text bg-gradient-to-br from-slate-900 via-slate-700 to-slate-500 leading-none tracking-tight">
                  404
                </h1>
                {/* Decorative element */}
                <div className="absolute -top-4 -right-4 sm:-top-6 sm:-right-6">
                  <div className="w-16 h-16 sm:w-20 sm:h-20 rounded-full bg-gradient-to-br from-[#f4ba1b]/20 to-amber-200/20 blur-xl" />
                </div>
              </div>
            </div>

            {/* Main Heading */}
            <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-slate-900 mb-4">
              Page Not Found
            </h2>
            <p className="text-lg sm:text-xl text-slate-600 mb-2 max-w-xl mx-auto">
              The page you&apos;re looking for doesn&apos;t exist or has been moved.
            </p>
            <p className="text-sm sm:text-base text-slate-500 mb-12 max-w-lg mx-auto">
              Don&apos;t worry, let&apos;s get you back on track!{" "}
              <span className="inline-block" role="img" aria-label="Waving hand">
                👋
              </span>
            </p>

            {/* Quick Actions Grid */}
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-12 max-w-2xl mx-auto">
              <button
                onClick={() => router.back()}
                className="group flex flex-col items-center gap-3 p-6 rounded-xl border-2 border-slate-200 bg-white hover:border-indigo-300 hover:bg-indigo-50/50 transition-all"
              >
                <div className="w-12 h-12 rounded-full bg-slate-100 group-hover:bg-indigo-100 flex items-center justify-center transition-colors">
                  <ArrowLeft className="w-5 h-5 text-slate-600 group-hover:text-indigo-600" />
                </div>
                <div className="text-center">
                  <p className="text-sm font-semibold text-slate-900">Go Back</p>
                  <p className="text-xs text-slate-500 mt-1">Previous page</p>
                </div>
              </button>

              <Link
                href="/"
                className="group flex flex-col items-center gap-3 p-6 rounded-xl border-2 border-[#f4ba1b] bg-gradient-to-br from-[#f4ba1b]/5 to-amber-50/50 hover:from-[#f4ba1b]/10 hover:to-amber-50 transition-all"
              >
                <div className="w-12 h-12 rounded-full bg-[#f4ba1b]/20 group-hover:bg-[#f4ba1b]/30 flex items-center justify-center transition-colors">
                  <Home className="w-5 h-5 text-[#b48100]" />
                </div>
                <div className="text-center">
                  <p className="text-sm font-semibold text-slate-900">Homepage</p>
                  <p className="text-xs text-slate-500 mt-1">Start fresh</p>
                </div>
              </Link>

              <Link
                href="/elections"
                className="group flex flex-col items-center gap-3 p-6 rounded-xl border-2 border-slate-200 bg-white hover:border-indigo-300 hover:bg-indigo-50/50 transition-all"
              >
                <div className="w-12 h-12 rounded-full bg-slate-100 group-hover:bg-indigo-100 flex items-center justify-center transition-colors">
                  <Search className="w-5 h-5 text-slate-600 group-hover:text-indigo-600" />
                </div>
                <div className="text-center">
                  <p className="text-sm font-semibold text-slate-900">Elections</p>
                  <p className="text-xs text-slate-500 mt-1">Browse all</p>
                </div>
              </Link>
            </div>

            {/* Primary CTA Buttons */}
            <div className="flex flex-col sm:flex-row items-center justify-center gap-3 mb-12">
              <Link href="/">
                <Button className="w-full sm:w-auto px-8 py-3 text-sm font-semibold bg-[#f4ba1b] hover:bg-[#e0a518] text-white shadow-md hover:shadow-lg transition-all">
                  <Home className="w-4 h-4 mr-2" />
                  Return to Homepage
                </Button>
              </Link>
              <Link href="/elections">
                <Button
                  variant="outline"
                  className="w-full sm:w-auto px-8 py-3 text-sm font-semibold border-2 border-slate-300 text-slate-700 hover:bg-slate-50 hover:border-slate-400 transition-all"
                >
                  <Compass className="w-4 h-4 mr-2" />
                  Explore Elections
                </Button>
              </Link>
            </div>

            {/* Helpful Links Section */}
            <div className="border-t border-slate-200 pt-8">
              <p className="text-sm font-medium text-slate-700 mb-4">
                Popular pages you might be looking for:
              </p>
              <div className="flex flex-wrap items-center justify-center gap-4 text-sm">
                <Link
                  href="/elections"
                  className="text-indigo-600 hover:text-indigo-700 hover:underline underline-offset-4 transition-colors"
                >
                  Elections
                </Link>
                <span className="text-slate-300">•</span>
                <Link
                  href="/about"
                  className="text-indigo-600 hover:text-indigo-700 hover:underline underline-offset-4 transition-colors"
                >
                  About Us
                </Link>
                <span className="text-slate-300">•</span>
                <Link
                  href="/faq"
                  className="text-indigo-600 hover:text-indigo-700 hover:underline underline-offset-4 transition-colors"
                >
                  FAQ
                </Link>
                <span className="text-slate-300">•</span>
                <Link
                  href="/login"
                  className="text-indigo-600 hover:text-indigo-700 hover:underline underline-offset-4 transition-colors"
                >
                  Login
                </Link>
              </div>
            </div>
          </div>
        </div>
      </main>
      <PublicFooter />
    </div>
  );
}
