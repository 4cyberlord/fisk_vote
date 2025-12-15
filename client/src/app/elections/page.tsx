"use client";

import { useMemo, useState } from "react";
import dayjs from "@/lib/dayjs";
import { formatDate } from "@/lib/dateUtils";
import { CalendarDays, Clock, MapPin, ArrowRight, Loader2 } from "lucide-react";
import Link from "next/link";
import { usePublicElections } from "@/hooks/usePublicElections";
import { PublicHeader } from "@/components/layout/PublicHeader";
import { PublicFooter } from "@/components/layout/PublicFooter";
import { Pagination } from "@/components";

const STATUS_TABS = ["All", "Open", "Upcoming", "Closed"] as const;
type StatusTab = (typeof STATUS_TABS)[number];

export default function PublicElectionsPage() {
  const { data, isLoading, error } = usePublicElections();
  const [activeTab, setActiveTab] = useState<StatusTab>("All");
  const [currentPage, setCurrentPage] = useState(1);
  const PAGE_SIZE = 27;

  const elections = data?.data ?? [];

  const filteredElections = useMemo(() => {
    const base =
      activeTab === "All"
        ? elections
        : elections.filter((election) => election.current_status === activeTab);
    return base;
  }, [activeTab, elections]);

  const totalPages = Math.max(1, Math.ceil(filteredElections.length / PAGE_SIZE));

  const paginatedElections = useMemo(() => {
    const startIndex = (currentPage - 1) * PAGE_SIZE;
    return filteredElections.slice(startIndex, startIndex + PAGE_SIZE);
  }, [filteredElections, currentPage]);

  const meta = data?.meta;

  const getStatusBadgeClasses = (status: string) => {
    switch (status) {
      case "Open":
        return "bg-emerald-100 text-emerald-800";
      case "Upcoming":
        return "bg-blue-100 text-blue-800";
      case "Closed":
        return "bg-gray-200 text-gray-700";
      default:
        return "bg-gray-100 text-gray-600";
    }
  };

  const getTypeLabel = (type: string) => {
    switch (type) {
      case "single":
        return "Single-choice";
      case "multiple":
        return "Multi-choice";
      case "ranked":
        return "Ranked-choice";
      case "referendum":
        return "Referendum";
      case "poll":
        return "Quick poll";
      default:
        return "Election";
    }
  };

  return (
    <div className="min-h-screen bg-white text-slate-900 flex flex-col">
      <PublicHeader />
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10 flex-1 w-full">
        {/* Hero */}
        <section className="mb-10">
          <div className="rounded-3xl bg-gradient-to-r from-[#f4ba1b] via-amber-400 to-yellow-300 px-6 py-8 sm:px-10 sm:py-10 shadow-lg relative overflow-hidden">
            <div className="absolute inset-0 opacity-10 pointer-events-none">
              <div className="absolute -top-10 -right-10 w-52 h-52 rounded-full border border-white/40" />
              <div className="absolute top-10 right-16 w-40 h-40 rounded-full border border-white/30" />
            </div>

            <div className="relative flex flex-col lg:flex-row items-start lg:items-center justify-between gap-8">
              <div className="max-w-2xl">
                <p className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-white/15 text-xs font-semibold text-white mb-3 backdrop-blur">
                  <CalendarDays className="w-4 h-4" />
                  Campus Elections Hub
                </p>
                <h1 className="text-3xl sm:text-4xl font-extrabold text-gray-900 tracking-tight">
                  Explore campus elections — open, upcoming, and past
                </h1>
                <p className="mt-3 text-sm sm:text-base font-medium text-gray-900/80 max-w-xl">
                  Stay informed about every election happening on campus. Discover who&apos;s
                  running, when to vote, and how your voice shapes student leadership.
                </p>
              </div>

              {meta && (
                <div className="grid grid-cols-3 gap-3 bg-white/90 rounded-2xl px-4 py-3 shadow-sm border border-yellow-100 min-w-[260px]">
                  <div>
                    <p className="text-[11px] font-bold text-gray-600 uppercase tracking-wide">
                      Open now
                    </p>
                    <p className="mt-1 text-2xl font-bold text-gray-900">
                      {meta.open ?? 0}
                    </p>
                  </div>
                  <div>
                    <p className="text-[11px] font-bold text-gray-600 uppercase tracking-wide">
                      Upcoming
                    </p>
                    <p className="mt-1 text-2xl font-bold text-gray-900">
                      {meta.upcoming ?? 0}
                    </p>
                  </div>
                  <div>
                    <p className="text-[11px] font-bold text-gray-600 uppercase tracking-wide">
                      Completed
                    </p>
                    <p className="mt-1 text-2xl font-bold text-gray-900">
                      {meta.closed ?? 0}
                    </p>
                  </div>
                </div>
              )}
            </div>
          </div>
        </section>

        {/* Tabs */}
        <section className="mb-6">
          <div className="flex flex-wrap items-center justify-between gap-4">
            <div className="inline-flex items-center gap-1 rounded-full bg-white border border-gray-200 p-1 shadow-sm">
              {STATUS_TABS.map((tab) => (
                <button
                  key={tab}
                  type="button"
                  onClick={() => {
                    setActiveTab(tab);
                    setCurrentPage(1);
                  }}
                  className={`px-3 sm:px-4 py-1.5 rounded-full text-xs sm:text-sm font-semibold transition-all ${
                    activeTab === tab
                      ? "bg-gray-900 text-white shadow-sm"
                      : "text-gray-600 hover:text-gray-900"
                  }`}
                >
                  {tab === "Open" ? "Open now" : tab === "Closed" ? "Past" : tab}
                </button>
              ))}
            </div>
            <p className="text-xs sm:text-sm font-medium text-gray-600">
              Showing{" "}
              <span className="font-bold text-gray-900">
                {filteredElections.length}
              </span>{" "}
              {activeTab === "All" ? "elections" : `${activeTab.toLowerCase()} elections`}
            </p>
          </div>
        </section>

        {/* Content */}
        {isLoading && (
          <div className="mt-10 flex justify-center">
            <div className="flex flex-col items-center gap-3 text-gray-600">
              <Loader2 className="w-6 h-6 animate-spin" />
              <p className="text-sm font-medium">Loading elections...</p>
            </div>
          </div>
        )}

        {error && !isLoading && (
          <div className="mt-10 rounded-xl border border-red-200 bg-red-50 px-5 py-4 text-sm font-medium text-red-700">
            We couldn&apos;t load the elections right now. Please refresh the page and try
            again.
          </div>
        )}

        {!isLoading && !error && filteredElections.length === 0 && (
          <div className="mt-10 rounded-xl border-2 border-dashed border-gray-200 bg-gray-50/50 px-6 py-12 text-center">
            <CalendarDays className="w-12 h-12 mx-auto text-gray-300 mb-4" />
            <p className="text-base font-semibold text-gray-900 mb-2">
              No elections in this category yet
            </p>
            <p className="text-sm text-gray-600 max-w-md mx-auto">
              Check back soon for new campus elections, or explore another tab above to see
              upcoming or past contests.
            </p>
          </div>
        )}

        {!isLoading && !error && filteredElections.length > 0 && (
          <section aria-label="Elections list" className="space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-5">
              {paginatedElections.map((election) => {
                const status = election.current_status ?? "Unknown";
                const now = dayjs();
                const startsIn =
                  election.start_time && dayjs(election.start_time).isAfter(now)
                    ? now.to(dayjs(election.start_time))
                    : null;
                const endsIn =
                  election.end_time && dayjs(election.end_time).isAfter(now)
                    ? now.to(dayjs(election.end_time))
                    : null;

                return (
                  <article
                    key={election.id}
                    className="group relative rounded-xl bg-white border border-gray-200/80 shadow-sm hover:shadow-lg hover:border-gray-300 transition-all duration-200 overflow-hidden"
                  >
                    {/* Top accent bar based on status */}
                    <div className={`h-1 w-full ${
                      status === "Open" ? "bg-emerald-500" : 
                      status === "Upcoming" ? "bg-blue-500" : 
                      "bg-gray-300"
                    }`} />
                    
                    <div className="p-5">
                      {/* Header */}
                      <div className="flex items-start justify-between gap-3 mb-3">
                        <div className="flex-1 min-w-0">
                          <span className="inline-flex items-center gap-1.5 text-[10px] font-semibold uppercase tracking-wider text-gray-500 mb-2">
                            <span className="w-1.5 h-1.5 rounded-full bg-amber-400" />
                            {getTypeLabel(election.type)}
                          </span>
                          <h2 className="text-lg font-semibold text-gray-900 leading-snug line-clamp-2">
                            {election.title}
                          </h2>
                        </div>
                        <span
                          className={`shrink-0 px-2.5 py-1 rounded-md text-[10px] font-bold uppercase tracking-wide ${getStatusBadgeClasses(
                            status
                          )}`}
                        >
                          {status}
                        </span>
                      </div>

                      {/* Description */}
                      {election.description && (
                        <p className="text-[13px] text-gray-600 leading-relaxed line-clamp-2 mb-4">
                          {election.description}
                        </p>
                      )}

                      {/* Date/Time Info */}
                      <div className="space-y-2 mb-4">
                        {(election.start_timestamp || election.start_time) && (
                          <div className="flex items-center gap-2 text-[13px] text-gray-700">
                            <Clock className="w-4 h-4 text-gray-400 shrink-0" />
                            <span>
                              <span className="font-medium text-gray-500">Starts:</span>{" "}
                              <span className="font-semibold">
                                {formatDate(election.start_timestamp || election.start_time, "MMM d, yyyy")}
                              </span>
                              <span className="text-gray-400 mx-1">·</span>
                              <span className="text-gray-600">
                                {formatDate(election.start_timestamp || election.start_time, "h:mm a")}
                              </span>
                            </span>
                          </div>
                        )}
                        {(election.end_timestamp || election.end_time) && (
                          <div className="flex items-center gap-2 text-[13px] text-gray-700">
                            <Clock className="w-4 h-4 text-gray-400 shrink-0" />
                            <span>
                              <span className="font-medium text-gray-500">Ends:</span>{" "}
                              <span className="font-semibold">
                                {formatDate(election.end_timestamp || election.end_time, "MMM d, yyyy")}
                              </span>
                              <span className="text-gray-400 mx-1">·</span>
                              <span className="text-gray-600">
                                {formatDate(election.end_timestamp || election.end_time, "h:mm a")}
                              </span>
                            </span>
                          </div>
                        )}
                      </div>

                      {/* Stats Row */}
                      <div className="flex items-center justify-between py-3 border-t border-gray-100">
                        <div className="flex items-center gap-4">
                          <div className="text-center">
                            <p className="text-lg font-bold text-gray-900">{election.positions_count}</p>
                            <p className="text-[10px] font-medium uppercase tracking-wide text-gray-500">
                              Position{election.positions_count === 1 ? "" : "s"}
                            </p>
                          </div>
                          <div className="w-px h-8 bg-gray-200" />
                          <div className="text-center">
                            <p className="text-lg font-bold text-gray-900">{election.candidates_count}</p>
                            <p className="text-[10px] font-medium uppercase tracking-wide text-gray-500">
                              Candidate{election.candidates_count === 1 ? "" : "s"}
                            </p>
                          </div>
                        </div>
                        {(startsIn || endsIn) && (
                          <span className={`text-xs font-semibold px-2 py-1 rounded ${
                            status === "Open" ? "text-emerald-700 bg-emerald-50" : 
                            status === "Upcoming" ? "text-blue-700 bg-blue-50" : 
                            "text-gray-600"
                          }`}>
                            {status === "Open" && endsIn
                              ? `Closes ${endsIn}`
                              : status === "Upcoming" && startsIn
                              ? `Opens ${startsIn}`
                              : ""}
                          </span>
                        )}
                      </div>

                      {/* Footer */}
                      <div className="flex justify-between items-center pt-3 border-t border-gray-100">
                        <p className="text-xs text-gray-500">
                          Sign in to participate
                        </p>
                        <Link
                          href="/login"
                          className="inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-semibold text-white bg-gray-900 rounded-lg hover:bg-gray-800 transition-colors"
                        >
                          View details
                          <ArrowRight className="w-3.5 h-3.5 transition-transform group-hover:translate-x-0.5" />
                        </Link>
                      </div>
                    </div>
                  </article>
                );
              })}
            </div>
            {totalPages > 1 && (
              <div className="pt-4 border-t border-gray-100">
                <Pagination
                  currentPage={currentPage}
                  totalPages={totalPages}
                  onPageChange={setCurrentPage}
                  totalItems={filteredElections.length}
                  itemsPerPage={PAGE_SIZE}
                />
              </div>
            )}
          </section>
        )}
      </main>
      <PublicFooter />
    </div>
  );
}


