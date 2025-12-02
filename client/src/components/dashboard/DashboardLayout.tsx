"use client";

import { Logo } from "@/components";
import { useAuth, useLogout, useCurrentUser } from "@/hooks/useAuth";
import { useMemo, useState, useEffect } from "react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import Avatar, { genConfig } from "react-nice-avatar";
import * as DropdownMenuPrimitive from "@radix-ui/react-dropdown-menu";
import { User, Settings, LogOut, ChevronDown, Search } from "lucide-react";

interface DashboardLayoutProps {
  children: React.ReactNode;
}

export function DashboardLayout({ children }: DashboardLayoutProps) {
  const { user: storeUser } = useAuth();
  const { data: currentUserData, isLoading: isLoadingUser } = useCurrentUser();
  const logoutMutation = useLogout();
  const pathname = usePathname();
  const router = useRouter();
  const [isCommandOpen, setIsCommandOpen] = useState(false);
  const [commandQuery, setCommandQuery] = useState("");

  // Get user from API response or fallback to store user
  const apiUser = currentUserData?.data;
  const user = apiUser || storeUser;

  // Get display name
  const getDisplayName = () => {
    if (user?.first_name && user?.last_name) {
      return `${user.first_name} ${user.last_name}`;
    }
    return user?.name || "User";
  };

  // Nice avatar config for top-right user menu (fallback when no profile photo)
  const avatarConfig = useMemo(() => {
    const seed =
      user?.email ||
      user?.student_id ||
      user?.name ||
      "student";
    return genConfig(seed);
  }, [user]);

  // Check if route is active
  const isActive = (path: string) => {
    return pathname === path;
  };

  const commandItems = useMemo(
    () => [
      { label: "Dashboard", href: "/dashboard", category: "Navigation" },
      { label: "Cast your vote", href: "/dashboard/vote", category: "Voting" },
      { label: "My vote history", href: "/dashboard/vote/history", category: "Voting" },
      { label: "Active elections", href: "/dashboard/elections", category: "Elections" },
      { label: "Results", href: "/dashboard/results", category: "Elections" },
      { label: "Calendar", href: "/dashboard/calendar", category: "Elections" },
      { label: "Settings", href: "/dashboard/settings", category: "Account" },
      { label: "Profile", href: "/dashboard/profile", category: "Account" },
      { label: "Audit logs (Settings)", href: "/dashboard/settings?tab=security", category: "Security" },
    ],
    []
  );

  const filteredCommands = useMemo(() => {
    const q = commandQuery.toLowerCase().trim();
    if (!q) return commandItems;
    return commandItems.filter(
      (item) =>
        item.label.toLowerCase().includes(q) ||
        item.category.toLowerCase().includes(q)
    );
  }, [commandItems, commandQuery]);

  const handleCommandSelect = (href: string) => {
    setIsCommandOpen(false);
    setCommandQuery("");
    router.push(href);
  };

  useEffect(() => {
    const handleKeyDown = (event: KeyboardEvent) => {
      if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === "k") {
        event.preventDefault();
        setIsCommandOpen((open) => !open);
      }
      if (event.key === "Escape") {
        setIsCommandOpen(false);
      }
    };

    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, []);

  return (
    <div className="h-screen bg-white flex overflow-hidden">
      {/* SIDEBAR */}
      <aside className="w-64 bg-[#0f172a] text-gray-300 flex flex-col">
        {/* Logo */}
        <div className="p-6">
          <Link href="/dashboard">
            <Logo className="h-8 w-8" />
          </Link>
        </div>

        {/* Nav Items */}
        <nav className="flex-1 px-4 space-y-1">
          <Link
            href="/dashboard"
            className={`flex items-center gap-3 px-3 py-2 rounded-lg ${
              isActive("/dashboard")
                ? "bg-gray-800 text-white"
                : "hover:bg-gray-800"
            }`}
          >
            <svg
              className="h-5 w-5"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                d="M3 12l2-2m0 0l7-7 7 7m-9 2v8m4-8v8"
              />
            </svg>
            Dashboard
          </Link>

          <Link
            href="/dashboard/elections"
            className={`flex items-center gap-3 px-3 py-2 rounded-lg ${
              isActive("/dashboard/elections")
                ? "bg-gray-800 text-white"
                : "hover:bg-gray-800"
            }`}
          >
            <svg
              className="h-5 w-5"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4"
              />
            </svg>
            Elections
          </Link>

          <Link
            href="/dashboard/vote"
            className={`flex items-center gap-3 px-3 py-2 rounded-lg ${
              isActive("/dashboard/vote")
                ? "bg-gray-800 text-white"
                : "hover:bg-gray-800"
            }`}
          >
            <svg
              className="h-5 w-5"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
              />
            </svg>
            Vote
          </Link>

          <Link
            href="/dashboard/results"
            className={`flex items-center gap-3 px-3 py-2 rounded-lg ${
              isActive("/dashboard/results")
                ? "bg-gray-800 text-white"
                : "hover:bg-gray-800"
            }`}
          >
            <svg
              className="h-5 w-5"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                d="M9 12l2 2 4-4M7.835 4.697a3.42 3.42 0 001.946-.806 3.42 3.42 0 014.438 0 3.42 3.42 0 001.946.806 3.42 3.42 0 013.138 3.138 3.42 3.42 0 00.806 1.946 3.42 3.42 0 010 4.438 3.42 3.42 0 00-.806 1.946 3.42 3.42 0 01-3.138 3.138 3.42 3.42 0 00-1.946.806 3.42 3.42 0 01-4.438 0 3.42 3.42 0 00-1.946-.806 3.42 3.42 0 01-3.138-3.138 3.42 3.42 0 00-.806-1.946 3.42 3.42 0 010-4.438 3.42 3.42 0 00.806-1.946 3.42 3.42 0 013.138-3.138z"
              />
            </svg>
            Results
          </Link>

          <Link
            href="/dashboard/calendar"
            className={`flex items-center gap-3 px-3 py-2 rounded-lg ${
              isActive("/dashboard/calendar")
                ? "bg-gray-800 text-white"
                : "hover:bg-gray-800"
            }`}
          >
            <svg
              className="h-5 w-5"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"
              />
            </svg>
            Calendar
          </Link>

          {/* <a
            href="#"
            className="flex items-center gap-3 px-3 py-2 rounded-lg hover:bg-gray-800"
          >
            <svg
              className="h-5 w-5"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7H3v12a2 2 0 002 2z"
              />
            </svg>
            Calendar
          </a>

          <a
            href="#"
            className="flex items-center gap-3 px-3 py-2 rounded-lg hover:bg-gray-800"
          >
            <svg
              className="h-5 w-5"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                d="M12 8v4l3 3m6-11H3v16h18V4z"
              />
            </svg>
            Documents
          </a>

          <a
            href="#"
            className="flex items-center gap-3 px-3 py-2 rounded-lg hover:bg-gray-800"
          >
            <svg
              className="h-5 w-5"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                d="M9 17v2H5v-2a7 7 0 0114 0v2h-4v-2"
              />
            </svg>
            Reports
          </a> */}

          {/* Elections Section - temporarily disabled */}
          {false && (
            <div className="mt-6">
              <p className="text-xs font-semibold uppercase text-gray-400 mb-2">
                Your elections
              </p>
              <a className="flex items-center gap-3 px-3 py-2 rounded-lg hover:bg-gray-800">
                <span className="bg-gray-700 text-gray-300 w-6 h-6 grid place-items-center rounded font-medium">
                  H
                </span>
                Heroicons
              </a>
              <a className="flex items-center gap-3 px-3 py-2 rounded-lg hover:bg-gray-800">
                <span className="bg-gray-700 text-gray-300 w-6 h-6 grid place-items-center rounded font-medium">
                  T
                </span>
                Tailwind Labs
              </a>
              <a className="flex items-center gap-3 px-3 py-2 rounded-lg hover:bg-gray-800">
                <span className="bg-gray-700 text-gray-300 w-6 h-6 grid place-items-center rounded font-medium">
                  W
                </span>
                Workcation
              </a>
            </div>
          )}
        </nav>

        {/* Bottom Settings */}
        <div className="px-4 py-4">
          <Link
            href="/dashboard/settings"
            className={`flex items-center gap-3 px-3 py-2 rounded-lg ${
              isActive("/dashboard/settings")
                ? "bg-gray-800 text-white"
                : "hover:bg-gray-800"
            }`}
          >
            <svg
              className="h-5 w-5"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                d="M12 8c-2.21 0-4 1.79-4 4s1.79 4 4 4
                 4-1.79 4-4-1.79-4-4-4zm9 4c0-.46-.04-.92-.1-1.36l2.1-1.65-2-3.46-2.48 
                 1c-.52-.4-1.08-.73-1.68-.98L16 2h-4l-.84 3.55c-.6.25-1.16.58-1.68.98l-2.48-1-2 
                 3.46 2.1 1.65c-.06.44-.1.9-.1 1.36s.04.92.1 1.36l-2.1 1.65 2 3.46 
                 2.48-1c.52.4 1.08.73 1.68.98L12 22h4l.84-3.55c.6-.25 
                 1.16-.58 1.68-.98l2.48 1 2-3.46-2.1-1.65c.06-.44.1-.9.1-1.36z"
              />
            </svg>
            Settings
          </Link>
        </div>
      </aside>

      {/* MAIN PANEL */}
      <main className="flex-1 flex flex-col">
        {/* TOP BAR */}
        <header className="h-16 border-b border-gray-200 bg-white flex items-center px-6 gap-6 relative">
          {/* Centered search bar */}
          <div className="absolute inset-x-0 flex justify-center pointer-events-none">
            <div className="w-full max-w-md px-16 pointer-events-auto">
              <label htmlFor="dashboard-search" className="sr-only">
                Search
              </label>
              <div className="relative">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400 pointer-events-none" />
                <input
                  id="dashboard-search"
                  type="search"
                  placeholder="Search elections, results, or pages"
                  value={commandQuery}
                  onChange={(e) => {
                    setCommandQuery(e.target.value);
                    if (!isCommandOpen) setIsCommandOpen(true);
                  }}
                  onFocus={() => setIsCommandOpen(true)}
                  className="w-full pl-9 pr-3 py-2 text-sm border border-gray-200 rounded-lg bg-gray-50 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 placeholder:text-gray-400 text-gray-900"
                />
              </div>
            </div>
          </div>

          {/* Right side: bell + user menu */}
          <div className="flex items-center gap-6 ml-auto">
            {/* Bell Icon */}
            <button className="relative">
              <svg
                className="h-6 w-6 text-gray-600"
                fill="none"
                stroke="currentColor"
                strokeWidth="2"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  d="M15 17h5l-1.4-1.4A2 2 0 0118 14V11c0-3.3-2-6-6-6S6 7.7 6 11v3c0 .8-.3 1.6-.9 2.2L4 17h5m3 4a2 2 0 002-2H10a2 2 0 002 2z"
                />
              </svg>
            </button>

            {/* User Menu */}
            <DropdownMenuPrimitive.Root>
              <DropdownMenuPrimitive.Trigger asChild>
                <button
                  className="flex items-center gap-3 hover:opacity-80 transition-opacity"
                  disabled={isLoadingUser}
                >
                  <div className="h-9 w-9 rounded-full overflow-hidden bg-indigo-600 flex items-center justify-center text-white font-medium ring-2 ring-indigo-100">
                    {isLoadingUser ? (
                      "..."
                    ) : (user as { profile_photo?: string | null })?.profile_photo ? (
                      // eslint-disable-next-line @next/next/no-img-element
                      <img
                        src={(user as { profile_photo?: string | null }).profile_photo ?? ""}
                        alt={getDisplayName()}
                        className="h-9 w-9 object-cover"
                        loading="lazy"
                      />
                    ) : (
                      <Avatar className="w-9 h-9" {...avatarConfig} />
                    )}
                  </div>
                  <span className="text-gray-800 font-medium hidden sm:block">
                    {isLoadingUser ? "Loading..." : getDisplayName()}
                  </span>
                  <ChevronDown className="h-4 w-4 text-gray-600 hidden sm:block" />
                </button>
              </DropdownMenuPrimitive.Trigger>
              <DropdownMenuPrimitive.Portal>
                <DropdownMenuPrimitive.Content
                  className="min-w-[200px] bg-white rounded-lg shadow-lg border border-gray-200 py-1 z-50"
                  align="end"
                  sideOffset={8}
                >
                  <div className="px-3 py-2 border-b border-gray-100">
                    <p className="text-sm font-semibold text-gray-900">{getDisplayName()}</p>
                    <p className="text-xs text-gray-500 truncate">{user?.email || ""}</p>
                  </div>
                  <DropdownMenuPrimitive.Item asChild>
                    <Link
                      href="/dashboard/profile"
                      className="flex items-center gap-2 px-3 py-2 text-sm text-gray-700 hover:bg-gray-100 cursor-pointer outline-none"
                    >
                      <User className="w-4 h-4" />
                      Profile
                    </Link>
                  </DropdownMenuPrimitive.Item>
                  <DropdownMenuPrimitive.Item asChild>
                    <Link
                      href="/dashboard/settings"
                      className="flex items-center gap-2 px-3 py-2 text-sm text-gray-700 hover:bg-gray-100 cursor-pointer outline-none"
                    >
                      <Settings className="w-4 h-4" />
                      Settings
                    </Link>
                  </DropdownMenuPrimitive.Item>
                  <DropdownMenuPrimitive.Separator className="h-px bg-gray-200 my-1" />
                  <DropdownMenuPrimitive.Item asChild>
                    <button
                      onClick={() => logoutMutation.mutate()}
                      disabled={logoutMutation.isPending}
                      className="flex items-center gap-2 w-full px-3 py-2 text-sm text-red-600 hover:bg-red-50 cursor-pointer outline-none disabled:opacity-50"
                    >
                      <LogOut className="w-4 h-4" />
                      {logoutMutation.isPending ? "Signing out..." : "Sign Out"}
                    </button>
                  </DropdownMenuPrimitive.Item>
                </DropdownMenuPrimitive.Content>
              </DropdownMenuPrimitive.Portal>
            </DropdownMenuPrimitive.Root>
          </div>
        </header>

        {/* Command Palette */}
        {isCommandOpen && (
          <div
            className="fixed inset-0 z-[9998] flex items-center justify-center px-4 bg-black/30"
            onClick={() => setIsCommandOpen(false)}
          >
            <div
              className="w-full max-w-2xl bg-white rounded-2xl shadow-2xl border border-gray-200 overflow-hidden"
              onClick={(e) => e.stopPropagation()}
            >
              <div className="px-5 py-4 border-b border-gray-100 flex items-center justify-between">
                <p className="text-xs font-medium text-gray-500">
                  Command palette · Start typing to search (or press{" "}
                  <span className="inline-flex items-center gap-1 rounded-md bg-gray-100 px-1.5 py-0.5 text-[10px] font-semibold text-gray-600 border border-gray-200">
                    ⌘K / Ctrl+K
                  </span>
                  )
                </p>
                <button
                  type="button"
                  onClick={() => setIsCommandOpen(false)}
                  className="text-xs text-gray-400 hover:text-gray-600"
                >
                  Esc
                </button>
              </div>
              <div className="max-h-96 overflow-y-auto">
                {filteredCommands.length === 0 ? (
                  <div className="px-4 py-6 text-center text-sm text-gray-500">
                    No matches found for <span className="font-semibold">“{commandQuery}”</span>
                  </div>
                ) : (
                  <ul className="divide-y divide-gray-100">
                    {filteredCommands.map((item) => (
                      <li key={item.href}>
                        <button
                          type="button"
                          onClick={() => handleCommandSelect(item.href)}
                          className="w-full text-left px-4 py-3 hover:bg-gray-50 flex items-center justify-between gap-3"
                        >
                          <div>
                            <p className="text-sm font-medium text-gray-900">
                              {item.label}
                            </p>
                            <p className="text-xs text-gray-500">{item.category}</p>
                          </div>
                          <span className="text-[10px] font-medium text-gray-400 uppercase tracking-wide">
                            Go
                          </span>
                        </button>
                      </li>
                    ))}
                  </ul>
                )}
              </div>
            </div>
          </div>
        )}

        {/* MAIN CONTENT */}
        <section className="flex-1 overflow-y-auto min-h-0 h-full">{children}</section>
      </main>
    </div>
  );
}

