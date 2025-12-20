"use client";

import Link from "next/link";
import dayjs, { formatDate, parseBackendDate, nowInAppTimezone } from "@/lib/dayjs";
import { motion } from "framer-motion";
import "react-day-picker/dist/style.css";
import {
  Bar,
  BarChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip as RechartsTooltip,
  XAxis,
  YAxis,
  Cell,
  Legend,
  Line,
  LineChart,
} from "recharts";
import * as TooltipPrimitive from "@radix-ui/react-tooltip";
import * as DialogPrimitive from "@radix-ui/react-dialog";
import { DayPicker } from "react-day-picker";
import {
  Vote,
  History,
  UserCircle2,
  Info,
  BarChart2,
  CalendarDays,
} from "lucide-react";
import { ElectionTurnoutChart } from "@/components/dashboard/ElectionTurnoutChart";
import { useCurrentUser } from "@/hooks/useAuth";
import {
  useActiveElections,
  useAllElections,
  useMyVotes,
} from "@/hooks/useElections";
import { Pagination } from "@/components";
import { useState, useMemo } from "react";

const ACTIVE_ELECTIONS_PER_PAGE = 9;
const RECENT_ACTIVITY_PER_PAGE = 15;

export default function DashboardPage() {
  const [activeElectionsPage, setActiveElectionsPage] = useState(1);
  const [recentActivityPage, setRecentActivityPage] = useState(1);
  const { data: userData } = useCurrentUser();
  const {
    data: activeElections,
    isLoading: isLoadingActive,
    error: activeError,
  } = useActiveElections();
  const { data: allElections } = useAllElections();
  const { data: myVotes, isLoading: isLoadingVotes } = useMyVotes();

  // Paginate active elections for the dashboard section
  const paginatedActiveElections = useMemo(() => {
    if (!activeElections) return [];
    const startIndex = (activeElectionsPage - 1) * ACTIVE_ELECTIONS_PER_PAGE;
    const endIndex = startIndex + ACTIVE_ELECTIONS_PER_PAGE;
    return activeElections.slice(startIndex, endIndex);
  }, [activeElections, activeElectionsPage]);

  const activeElectionsTotalPages = Math.ceil(
    (activeElections?.length || 0) / ACTIVE_ELECTIONS_PER_PAGE
  );

  const user = userData?.data;

  const totalActive = activeElections?.length || 0;
  const totalElections = allElections?.length || 0;
  const votesCast = myVotes?.length || 0;

  const sortedRecentVotes = useMemo(() => {
    if (!myVotes) return [];
    return [...myVotes].sort((a, b) => {
      if (!a.voted_at || !b.voted_at) return 0;
      return dayjs(b.voted_at).valueOf() - dayjs(a.voted_at).valueOf();
    });
  }, [myVotes]);

  const recentActivityTotalPages = Math.ceil(
    sortedRecentVotes.length / RECENT_ACTIVITY_PER_PAGE
  );

  const safeRecentActivityPage = Math.min(
    recentActivityPage,
    Math.max(recentActivityTotalPages || 1, 1)
  );

  const paginatedRecentVotes = useMemo(() => {
    const startIndex = (safeRecentActivityPage - 1) * RECENT_ACTIVITY_PER_PAGE;
    const endIndex = startIndex + RECENT_ACTIVITY_PER_PAGE;
    return sortedRecentVotes.slice(startIndex, endIndex);
  }, [sortedRecentVotes, safeRecentActivityPage]);

  // Derived data for charts
  const statusCounts = (allElections || []).reduce(
    (acc, election) => {
      const status = election.current_status || "Closed";
      if (status === "Open") acc.open += 1;
      else if (status === "Upcoming") acc.upcoming += 1;
      else acc.closed += 1;
      return acc;
    },
    { open: 0, upcoming: 0, closed: 0 }
  );

  const electionStatusData = [
    { name: "Open", value: statusCounts.open, color: "#10b981", label: "Open Elections" },
    { name: "Upcoming", value: statusCounts.upcoming, color: "#3b82f6", label: "Upcoming Elections" },
    { name: "Closed", value: statusCounts.closed, color: "#6b7280", label: "Closed Elections" },
  ];

  // Custom tooltip for election status
  const ElectionStatusTooltip = ({ active, payload }: any) => {
    if (active && payload && payload.length) {
      const data = payload[0].payload;
      return (
        <div className="bg-white border border-gray-200 rounded-lg shadow-lg p-3">
          <p className="text-sm font-semibold text-gray-900 mb-1">{data.label}</p>
          <div className="flex items-center gap-2">
            <div
              className="w-3 h-3 rounded-full"
              style={{ backgroundColor: data.color }}
            />
            <p className="text-sm text-gray-700">
              <span className="font-semibold text-gray-900">{data.value}</span>{" "}
              {data.value === 1 ? "election" : "elections"}
            </p>
          </div>
        </div>
      );
    }
    return null;
  };

  // Custom tooltip for voting activity
  const VotingActivityTooltip = ({ active, payload }: any) => {
    if (active && payload && payload.length) {
      const data = payload[0].payload;
      return (
        <div className="bg-white border border-gray-200 rounded-lg shadow-lg p-3">
          <p className="text-sm font-semibold text-gray-900 mb-1">{data.date}</p>
          <div className="flex items-center gap-2">
            <div className="w-3 h-3 rounded-full bg-green-500" />
            <p className="text-sm text-gray-700">
              <span className="font-semibold text-gray-900">{data.votes}</span>{" "}
              {data.votes === 1 ? "vote cast" : "votes cast"}
            </p>
          </div>
        </div>
      );
    }
    return null;
  };

  const votesOverTimeMap: Record<string, number> = {};
  (myVotes || []).forEach((entry) => {
    if (!entry.voted_at) return;
    const dayKey = formatDate(entry.voted_at, "YYYY-MM-DD");
    votesOverTimeMap[dayKey] = (votesOverTimeMap[dayKey] || 0) + 1;
  });

  const votesOverTimeData = Object.entries(votesOverTimeMap)
    .sort(([a], [b]) => (a < b ? -1 : 1))
    .map(([date, count]) => ({
      date: formatDate(date, "MMM D"),
      votes: count,
    }));

  const nextClosing = activeElections
    ? [...activeElections].sort(
        (a, b) =>
          new Date(a.end_time).getTime() - new Date(b.end_time).getTime()
      )[0]
    : null;

  const getGreeting = () => {
    const hour = new Date().getHours();
    if (hour < 12) return "Good morning";
    if (hour < 18) return "Good afternoon";
    return "Good evening";
  };

  const displayName =
    (user?.first_name && user?.last_name
      ? `${user.first_name} ${user.last_name}`
      : user?.name) || "Student";

  return (
    <div className="h-full overflow-y-auto bg-gray-50">
      <div className="p-8 max-w-7xl mx-auto space-y-8">
        {/* Header + Quick actions */}
        <motion.div
          className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4"
          initial={{ opacity: 0, y: -8 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.35 }}
        >
          <div>
            <h1 className="text-3xl font-bold text-gray-900">
              {getGreeting()}, {displayName}
            </h1>
            <p className="text-gray-600 mt-2">
              Here&apos;s a quick overview of your elections and voting activity.
            </p>
          </div>
          <div className="flex flex-wrap gap-3">
            <Link
              href="/dashboard/vote"
              className="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-indigo-600 rounded-lg shadow-sm hover:bg-indigo-700 transition-colors"
            >
              <Vote className="w-4 h-4" />
              Cast a vote
            </Link>
            <Link
              href="/dashboard/vote/history"
              className="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-indigo-700 bg-indigo-50 border border-indigo-200 rounded-lg hover:bg-indigo-100 transition-colors"
            >
              <History className="w-4 h-4" />
              My vote history
            </Link>
            <Link
              href="/dashboard/profile"
              className="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
            >
              <UserCircle2 className="w-4 h-4" />
              Profile
            </Link>

            {/* How voting works dialog */}
            <DialogPrimitive.Root>
              <DialogPrimitive.Trigger asChild>
                <button
                  type="button"
                  className="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-gray-600 bg-white border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
                >
                  <Info className="w-4 h-4" />
                  How voting works
                </button>
              </DialogPrimitive.Trigger>
              <DialogPrimitive.Portal>
                <DialogPrimitive.Overlay className="fixed inset-0 bg-black/30 z-[9998]" />
                <DialogPrimitive.Content className="fixed inset-0 z-[9999] flex items-center justify-center px-4">
                  <div className="bg-white rounded-xl shadow-xl max-w-lg w-full p-6 border border-gray-200">
                    <div className="flex items-start justify-between mb-3">
                      <DialogPrimitive.Title className="text-lg font-semibold text-gray-900">
                        How voting works
                      </DialogPrimitive.Title>
                      <DialogPrimitive.Close className="text-gray-400 hover:text-gray-600">
                        <span className="sr-only">Close</span>
                        ✕
                      </DialogPrimitive.Close>
                    </div>
                    <DialogPrimitive.Description asChild>
                      <div className="text-sm text-gray-600 space-y-2">
                        <p>
                          Each election can have multiple positions (for example President,
                          Vice President), and each position can have several approved
                          candidates.
                        </p>
                        <p>
                          When you cast a ballot, you select candidates for each position
                          according to the election rules (single choice, multiple choice, or
                          ranked choice). Your ballot is stored securely, and you can only
                          vote once per election.
                        </p>
                        <p>
                          You can always review elections you&apos;ve participated in from
                          the &quot;My vote history&quot; section of your dashboard.
                        </p>
                      </div>
                    </DialogPrimitive.Description>
                  </div>
                </DialogPrimitive.Content>
              </DialogPrimitive.Portal>
            </DialogPrimitive.Root>
          </div>
        </motion.div>

        {/* Top cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <motion.div
            className="bg-white border border-gray-200 rounded-xl p-6 shadow-sm flex flex-col justify-between"
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.05 }}
          >
            <div>
              <p className="text-xs font-semibold text-indigo-600 uppercase tracking-wide">
                Active elections
              </p>
              <p className="mt-2 text-3xl font-bold text-gray-900">
                {activeError ? "—" : totalActive}
              </p>
            </div>
            <p className="mt-3 text-sm text-gray-500">
              Elections currently open and available for you to vote in.
            </p>
          </motion.div>

          <motion.div
            className="bg-white border border-gray-200 rounded-xl p-6 shadow-sm flex flex-col justify-between"
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
          >
            <div>
              <p className="text-xs font-semibold text-green-600 uppercase tracking-wide">
                Elections participated
              </p>
              <p className="mt-2 text-3xl font-bold text-gray-900">
                {isLoadingVotes ? "…" : votesCast}
              </p>
            </div>
            <p className="mt-3 text-sm text-gray-500">
              Total elections where you successfully cast a vote.
            </p>
          </motion.div>

          <motion.div
            className="bg-white border border-gray-200 rounded-xl p-6 shadow-sm flex flex-col justify-between"
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.15 }}
          >
            <div>
              <p className="text-xs font-semibold text-gray-600 uppercase tracking-wide">
                All elections
              </p>
              <p className="mt-2 text-3xl font-bold text-gray-900">
                {totalElections}
              </p>
            </div>
            <p className="mt-3 text-sm text-gray-500">
              Includes active, upcoming, and recently closed elections you&apos;re
              eligible for.
            </p>
          </motion.div>
        </div>

        {/* Row 1: What's happening now + Profile */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* What's happening now - takes 2 columns */}
          <div className="lg:col-span-2">
            <div className="bg-white border border-gray-200 rounded-xl p-6 shadow-sm">
              <div className="flex items-center justify-between mb-4">
                <h2 className="text-lg font-semibold text-gray-900">
                  What&apos;s happening now
                </h2>
                <Link
                  href="/dashboard/elections"
                  className="text-sm font-medium text-indigo-600 hover:text-indigo-700"
                >
                  View all elections
                </Link>
              </div>

              {activeError ? (
                <p className="text-sm text-red-600">
                  Failed to load active elections. Please try again later.
                </p>
              ) : !nextClosing ? (
                <p className="text-sm text-gray-500">
                  There are no active elections at the moment. Check back later.
                </p>
              ) : (
                <div className="border border-indigo-100 rounded-lg p-5 bg-indigo-50/70">
                  <p className="text-xs font-semibold text-indigo-700 uppercase tracking-wide mb-2">
                    Closing soon
                  </p>
                  <h3 className="text-lg font-semibold text-gray-900 mb-2">
                    {nextClosing.title}
                  </h3>
                  <p className="text-sm text-gray-600 mb-4 line-clamp-2">
                    {nextClosing.description || "No additional description."}
                  </p>
                  <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
                    <div className="text-sm text-gray-700 space-y-1">
                      <p>
                        Ends{" "}
                        <span className="font-medium">
                          {formatDate(nextClosing.end_time)}
                        </span>
                      </p>
                      <p className="text-xs text-gray-500">
                        Positions: {nextClosing.positions_count} • Candidates:{" "}
                        {nextClosing.candidates_count}
                      </p>
                    </div>
                    <Link
                      href={`/dashboard/vote/${nextClosing.id}`}
                      className="group inline-flex items-center gap-2 px-5 py-2.5 text-sm font-semibold text-white bg-gradient-to-r from-indigo-600 to-indigo-500 rounded-lg hover:from-indigo-700 hover:to-indigo-600 shadow-md hover:shadow-lg transition-all self-start sm:self-auto"
                    >
                      <svg
                        className="w-4 h-4"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                      >
                        <path
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          strokeWidth={2}
                          d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
                        />
                      </svg>
                      Vote Now
                      <svg
                        className="w-4 h-4 transition-transform group-hover:translate-x-1"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                      >
                        <path
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          strokeWidth={2}
                          d="M13 7l5 5m0 0l-5 5m5-5H6"
                        />
                      </svg>
                    </Link>
                  </div>
                </div>
              )}
            </div>
          </div>

          {/* Profile summary - takes 1 column */}
          <div className="bg-white border border-gray-200 rounded-xl p-6 shadow-sm">
            <h2 className="text-lg font-semibold text-gray-900 mb-3">
              Your profile
            </h2>
            <p className="text-sm text-gray-600 mb-4">
              Keep your details up to date so you don&apos;t miss eligible elections.
            </p>

            <dl className="space-y-3 text-sm text-gray-700 mb-4">
              <div className="flex justify-between">
                <dt className="text-gray-500">Name</dt>
                <dd className="font-medium text-right">{displayName}</dd>
              </div>
              <div className="flex justify-between">
                <dt className="text-gray-500">Fisk email</dt>
                <dd className="font-medium truncate max-w-[60%] text-right">
                  {user?.email || "—"}
                </dd>
              </div>
              <div className="flex justify-between">
                <dt className="text-gray-500">Student ID</dt>
                <dd className="font-medium">{user?.student_id || "—"}</dd>
              </div>
            </dl>

            <Link
              href="/dashboard/profile"
              className="inline-flex items-center gap-2 text-sm font-medium text-indigo-600 hover:text-indigo-700"
            >
              Review profile
              <svg
                className="w-3 h-3"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M9 5l7 7-7 7"
                />
              </svg>
            </Link>
          </div>
        </div>

        {/* Row 2: Charts side by side */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Election overview chart */}
          <div className="bg-white border border-gray-200 rounded-xl p-6 shadow-sm">
            <div className="flex items-center justify-between mb-4">
              <div>
                <h2 className="text-lg font-semibold text-gray-900">
                  Election overview
                </h2>
                <p className="text-xs text-gray-500 mt-0.5">
                  Distribution by status
                </p>
              </div>
              <TooltipPrimitive.Provider delayDuration={150}>
                <TooltipPrimitive.Root>
                  <TooltipPrimitive.Trigger asChild>
                    <button
                      type="button"
                      className="inline-flex items-center justify-center rounded-full p-1.5 text-gray-400 hover:text-gray-600 hover:bg-gray-50 transition-colors"
                      aria-label="What does this chart show?"
                    >
                      <Info className="w-4 h-4" />
                    </button>
                  </TooltipPrimitive.Trigger>
                  <TooltipPrimitive.Content className="rounded-md bg-gray-900 px-2 py-1 text-xs text-white shadow-sm">
                    Number of elections in each status (Open, Upcoming, Closed).
                  </TooltipPrimitive.Content>
                </TooltipPrimitive.Root>
              </TooltipPrimitive.Provider>
            </div>
            {totalElections === 0 ? (
              <div className="flex flex-col items-center justify-center h-64 text-center">
                <div className="w-16 h-16 rounded-full bg-gray-100 flex items-center justify-center mb-3">
                  <BarChart2 className="w-8 h-8 text-gray-400" />
                </div>
                <p className="text-sm text-gray-500">
                  Once elections are created, you&apos;ll see a visual breakdown here.
                </p>
              </div>
            ) : (
              <motion.div
                className="h-64 w-full"
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.5 }}
              >
                <ResponsiveContainer width="100%" height="100%" minWidth={0} minHeight={256}>
                  <BarChart
                    data={electionStatusData}
                    margin={{ top: 10, right: 10, left: 0, bottom: 5 }}
                  >
                    <defs>
                      <linearGradient id="openGradient" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="0%" stopColor="#10b981" stopOpacity={1} />
                        <stop offset="100%" stopColor="#059669" stopOpacity={0.8} />
                      </linearGradient>
                      <linearGradient id="upcomingGradient" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="0%" stopColor="#3b82f6" stopOpacity={1} />
                        <stop offset="100%" stopColor="#2563eb" stopOpacity={0.8} />
                      </linearGradient>
                      <linearGradient id="closedGradient" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="0%" stopColor="#6b7280" stopOpacity={1} />
                        <stop offset="100%" stopColor="#4b5563" stopOpacity={0.8} />
                      </linearGradient>
                    </defs>
                    <CartesianGrid
                      strokeDasharray="3 3"
                      vertical={false}
                      stroke="#e5e7eb"
                      opacity={0.5}
                    />
                    <XAxis
                      dataKey="name"
                      tick={{ fontSize: 12, fill: "#6b7280" }}
                      axisLine={{ stroke: "#e5e7eb" }}
                      tickLine={{ stroke: "#e5e7eb" }}
                    />
                    <YAxis
                      allowDecimals={false}
                      tick={{ fontSize: 12, fill: "#6b7280" }}
                      axisLine={{ stroke: "#e5e7eb" }}
                      tickLine={{ stroke: "#e5e7eb" }}
                    />
                    <RechartsTooltip
                      content={<ElectionStatusTooltip />}
                      cursor={{ fill: "rgba(99, 102, 241, 0.08)" }}
                      animationDuration={200}
                    />
                    <Bar
                      dataKey="value"
                      radius={[8, 8, 0, 0]}
                      animationBegin={0}
                      animationDuration={800}
                      animationEasing="ease-out"
                    >
                      {electionStatusData.map((entry, index) => (
                        <Cell
                          key={`cell-${index}`}
                          fill={
                            entry.name === "Open"
                              ? "url(#openGradient)"
                              : entry.name === "Upcoming"
                              ? "url(#upcomingGradient)"
                              : "url(#closedGradient)"
                          }
                        />
                      ))}
                    </Bar>
                  </BarChart>
                </ResponsiveContainer>
              </motion.div>
            )}
            {/* Statistics summary */}
            {totalElections > 0 && (
              <div className="mt-4 pt-4 border-t border-gray-100">
                <div className="grid grid-cols-3 gap-3">
                  {electionStatusData.map((item) => (
                    <div key={item.name} className="text-center">
                      <div className="flex items-center justify-center gap-1.5 mb-1">
                        <div
                          className="w-2 h-2 rounded-full"
                          style={{ backgroundColor: item.color }}
                        />
                        <p className="text-xs font-medium text-gray-600">
                          {item.name}
                        </p>
                      </div>
                      <p className="text-lg font-bold text-gray-900">{item.value}</p>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>

          {/* Voting activity chart */}
          <div className="bg-white border border-gray-200 rounded-xl p-6 shadow-sm">
            <div className="mb-4">
              <h2 className="text-lg font-semibold text-gray-900">
                Voting activity
              </h2>
              <p className="text-xs text-gray-500 mt-0.5">
                Your voting pattern over time
              </p>
            </div>
            {votesOverTimeData.length === 0 ? (
              <div className="flex flex-col items-center justify-center h-64 text-center">
                <div className="w-16 h-16 rounded-full bg-gray-100 flex items-center justify-center mb-3">
                  <History className="w-8 h-8 text-gray-400" />
                </div>
                <p className="text-sm text-gray-500">
                  Once you cast votes on different days, your activity trend will
                  appear here.
                </p>
              </div>
            ) : (
              <motion.div
                className="h-64 w-full"
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.5, delay: 0.1 }}
              >
                <ResponsiveContainer width="100%" height="100%" minWidth={0} minHeight={256}>
                  <BarChart
                    data={votesOverTimeData}
                    margin={{ top: 10, right: 10, left: 0, bottom: 5 }}
                  >
                    <defs>
                      <linearGradient id="voteGradient" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="0%" stopColor="#22c55e" stopOpacity={1} />
                        <stop offset="100%" stopColor="#16a34a" stopOpacity={0.8} />
                      </linearGradient>
                    </defs>
                    <CartesianGrid
                      strokeDasharray="3 3"
                      vertical={false}
                      stroke="#e5e7eb"
                      opacity={0.5}
                    />
                    <XAxis
                      dataKey="date"
                      tick={{ fontSize: 11, fill: "#6b7280" }}
                      axisLine={{ stroke: "#e5e7eb" }}
                      tickLine={{ stroke: "#e5e7eb" }}
                    />
                    <YAxis
                      allowDecimals={false}
                      tick={{ fontSize: 11, fill: "#6b7280" }}
                      axisLine={{ stroke: "#e5e7eb" }}
                      tickLine={{ stroke: "#e5e7eb" }}
                    />
                    <RechartsTooltip
                      content={<VotingActivityTooltip />}
                      cursor={{ fill: "rgba(34, 197, 94, 0.08)" }}
                      animationDuration={200}
                    />
                    <Bar
                      dataKey="votes"
                      fill="url(#voteGradient)"
                      radius={[8, 8, 0, 0]}
                      animationBegin={0}
                      animationDuration={800}
                      animationEasing="ease-out"
                    />
                  </BarChart>
                </ResponsiveContainer>
              </motion.div>
            )}
            {/* Voting statistics */}
            {votesOverTimeData.length > 0 && (
              <div className="mt-4 pt-4 border-t border-gray-100">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-xs text-gray-500">Total votes</p>
                    <p className="text-lg font-bold text-gray-900 mt-0.5">
                      {votesCast}
                    </p>
                  </div>
                  <div className="text-right">
                    <p className="text-xs text-gray-500">Active days</p>
                    <p className="text-lg font-bold text-gray-900 mt-0.5">
                      {votesOverTimeData.length}
                    </p>
                  </div>
                  <div className="text-right">
                    <p className="text-xs text-gray-500">Avg per day</p>
                    <p className="text-lg font-bold text-gray-900 mt-0.5">
                      {votesOverTimeData.length > 0
                        ? (votesCast / votesOverTimeData.length).toFixed(1)
                        : "0"}
                    </p>
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Election Turnout Statistics - Full Width Card */}
        <ElectionTurnoutChart />

        {/* Row 3: Active elections, Calendar, Recent activity */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Active elections list */}
          <div className="bg-white border border-gray-200 rounded-xl p-6 shadow-sm">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-lg font-semibold text-gray-900">
                Active elections
              </h2>
              <Link
                href="/dashboard/vote"
                className="text-sm font-medium text-indigo-600 hover:text-indigo-700"
              >
                Cast a vote
              </Link>
            </div>

            {activeError ? (
              <p className="text-sm text-red-600">
                Failed to load active elections.
              </p>
            ) : !activeElections || activeElections.length === 0 ? (
              <p className="text-sm text-gray-500">
                No active elections at this time.
              </p>
            ) : (
              <>
                <div className="space-y-3">
                  {paginatedActiveElections.map((election) => (
                    <Link
                      key={election.id}
                      href={`/dashboard/elections/${election.id}`}
                      className="flex items-center justify-between gap-3 border border-gray-200 rounded-lg px-4 py-3 hover:border-indigo-300 hover:shadow-sm transition-all bg-white"
                    >
                      <div className="flex-1 min-w-0">
                        <p className="text-sm font-medium text-gray-900 line-clamp-1">
                          {election.title}
                        </p>
                        <p className="text-xs text-gray-500 mt-0.5">
                          {formatDate(election.end_time)}
                        </p>
                      </div>
                      <div className="flex items-center gap-2 flex-shrink-0">
                        {election.has_voted && (
                          <span className="inline-flex items-center gap-1 px-2 py-1 rounded-full text-[11px] font-medium bg-green-50 text-green-700 border border-green-200">
                            <svg
                              className="w-3 h-3"
                              fill="none"
                              stroke="currentColor"
                              viewBox="0 0 24 24"
                            >
                              <path
                                strokeLinecap="round"
                                strokeLinejoin="round"
                                strokeWidth={2}
                                d="M5 13l4 4L19 7"
                              />
                            </svg>
                            Voted
                          </span>
                        )}
                        <span className="px-2.5 py-1 rounded-full text-[11px] font-medium bg-indigo-50 text-indigo-700 border border-indigo-200">
                          {election.current_status}
                        </span>
                      </div>
                    </Link>
                  ))}
                </div>
                {activeElectionsTotalPages > 1 && (
                  <div className="mt-1">
                    <Pagination
                      currentPage={activeElectionsPage}
                      totalPages={activeElectionsTotalPages}
                      onPageChange={setActiveElectionsPage}
                    />
                  </div>
                )}
              </>
            )}
          </div>

          {/* Election calendar */}
          <motion.div
            className="bg-white border border-gray-200 rounded-xl p-6 shadow-sm"
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.2 }}
          >
            <div className="flex items-center justify-between mb-5">
              <div>
                <h2 className="text-lg font-bold text-gray-900">
                  Election calendar
                </h2>
                <p className="text-xs text-gray-600 mt-1 font-medium">
                  Upcoming election dates
                </p>
              </div>
              <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-indigo-500 to-purple-600 flex items-center justify-center shadow-lg shadow-indigo-200">
                <CalendarDays className="w-6 h-6 text-white" />
              </div>
            </div>

            {totalElections === 0 ? (
              <div className="flex flex-col items-center justify-center py-12 text-center">
                <div className="w-16 h-16 rounded-full bg-gray-100 flex items-center justify-center mb-3">
                  <CalendarDays className="w-8 h-8 text-gray-400" />
                </div>
                <p className="text-sm text-gray-500">
                  When elections are scheduled, their dates will be highlighted here.
                </p>
              </div>
            ) : (
              <>
                {/* Calendar */}
                <div className="border-2 border-indigo-100 rounded-2xl p-5 bg-gradient-to-br from-indigo-50 via-white to-purple-50 mb-4 shadow-sm">
                  <style jsx global>{`
                    .rdp {
                      --rdp-cell-size: 40px;
                      --rdp-accent-color: #6366f1;
                      --rdp-background-color: #eef2ff;
                      --rdp-accent-color-dark: #4f46e5;
                      --rdp-background-color-dark: #1e293b;
                      --rdp-outline: 2px solid var(--rdp-accent-color);
                      --rdp-outline-selected: 2px solid var(--rdp-accent-color);
                      margin: 0;
                    }
                    .election-calendar {
                      color: #1f2937;
                    }
                    .election-calendar .rdp-caption_label,
                    .election-calendar .rdp-button,
                    .election-calendar .rdp-day {
                      color: inherit;
                    }
                    .rdp-months {
                      display: flex;
                      justify-content: center;
                    }
                    .rdp-month {
                      margin: 0;
                    }
                    .rdp-table {
                      width: 100%;
                      max-width: none;
                      border-collapse: collapse;
                    }
                    .rdp-with_weeknumber .rdp-table {
                      border-collapse: separate;
                    }
                    .rdp-caption {
                      display: flex !important;
                      align-items: center;
                      justify-content: space-between;
                      padding: 0.75rem 0.5rem;
                      font-weight: 700;
                      color: #111827 !important;
                      margin-bottom: 0.75rem;
                      font-size: 1.125rem !important;
                      background-color: transparent !important;
                    }
                    .rdp-caption_label {
                      color: #111827 !important;
                      font-weight: 700 !important;
                      font-size: 1.125rem !important;
                      opacity: 1 !important;
                      visibility: visible !important;
                      display: block !important;
                    }
                    .rdp-caption_dropdowns {
                      color: #111827 !important;
                      opacity: 1 !important;
                    }
                    .rdp-multiple_months .rdp-caption {
                      position: relative;
                      display: block;
                      text-align: center;
                    }
                    .rdp-nav {
                      display: flex;
                      flex-wrap: wrap;
                      justify-content: flex-start;
                      gap: 0.5rem;
                    }
                    .rdp-multiple_months .rdp-caption_start .rdp-nav,
                    .rdp-multiple_months .rdp-caption_end .rdp-nav {
                      position: absolute;
                      top: 50%;
                      transform: translateY(-50%);
                    }
                    .rdp-multiple_months .rdp-caption_start .rdp-nav {
                      left: 0;
                    }
                    .rdp-multiple_months .rdp-caption_end .rdp-nav {
                      right: 0;
                    }
                    .rdp-button_reset {
                      appearance: none;
                      position: relative;
                      margin: 0;
                      padding: 0;
                      cursor: default;
                      color: inherit;
                      border: 0;
                      background-color: transparent;
                      font: inherit;
                    }
                    .rdp-button {
                      border: 2px solid transparent;
                    }
                    .rdp-button[disabled] {
                      opacity: 0.3;
                    }
                    .rdp-button:not([disabled]) {
                      cursor: pointer;
                    }
                    .rdp-button:focus:not([disabled]) {
                      color: inherit;
                      border: var(--rdp-outline);
                    }
                    .rdp-button:active:not([disabled]) {
                      opacity: 0.7;
                    }
                    .rdp-nav_button {
                      display: inline-flex;
                      align-items: center;
                      justify-content: center;
                      width: 2.25rem;
                      height: 2.25rem;
                      border-radius: 0.5rem;
                      color: #4b5563;
                      background-color: white;
                      border: 1px solid #e5e7eb;
                      transition: all 0.2s;
                      font-weight: 600;
                    }
                    .rdp-nav_button:hover:not([disabled]) {
                      background-color: #6366f1;
                      color: white;
                      border-color: #6366f1;
                      transform: scale(1.05);
                    }
                    .rdp-nav_icon {
                      width: 1.125rem;
                      height: 1.125rem;
                    }
                    .rdp-head_cell {
                      vertical-align: middle;
                      font-size: 0.75rem;
                      font-weight: 700;
                      text-align: center;
                      color: #374151 !important;
                      padding: 0.75rem 0.5rem;
                      text-transform: uppercase;
                      letter-spacing: 0.1em;
                      opacity: 1 !important;
                    }
                    .rdp-tbody {
                      border: 0;
                    }
                    .rdp-tfoot {
                      border: 0;
                    }
                    .rdp-cell {
                      width: var(--rdp-cell-size);
                      max-width: var(--rdp-cell-size);
                      height: var(--rdp-cell-size);
                      text-align: center;
                      font-size: 0.875rem;
                      position: relative;
                      padding: 2px;
                    }
                    .rdp-button.rdp-day {
                      width: 100%;
                      height: 100%;
                      border-radius: 0.625rem;
                      color: #1f2937 !important;
                      background-color: white;
                      border: 1px solid #e5e7eb;
                      transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
                      font-weight: 600;
                      opacity: 1 !important;
                    }
                    .rdp-button.rdp-day:hover:not([disabled]):not(.rdp-day_selected):not(.rdp-day_outside):not(.electionDays):not(.electionStart):not(.electionEnd) {
                      background-color: #f3f4f6;
                      color: #1f2937;
                      border-color: #d1d5db;
                      transform: translateY(-1px);
                      box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
                    }
                    .rdp-day_today:not(.rdp-day_outside):not(.electionDays):not(.electionStart):not(.electionEnd) {
                      font-weight: 700;
                      color: #6366f1;
                      background-color: #eef2ff;
                      border: 2px solid #6366f1;
                    }
                    .rdp-day_selected,
                    .rdp-day_selected:focus-visible,
                    .rdp-day_selected:hover {
                      color: white;
                      opacity: 1;
                      background-color: var(--rdp-accent-color);
                    }
                    .rdp-day_outside {
                      color: #6b7280 !important;
                      opacity: 1 !important;
                      background-color: #f3f4f6 !important;
                      border-color: #e5e7eb !important;
                      font-weight: 500 !important;
                    }
                    .rdp-day_outside .rdp-button {
                      color: #6b7280 !important;
                      opacity: 1 !important;
                    }
                    .rdp-day_disabled {
                      color: #9ca3af !important;
                      background-color: #f9fafb !important;
                      opacity: 1 !important;
                    }
                    .rdp-day_disabled .rdp-button {
                      color: #9ca3af !important;
                      opacity: 1 !important;
                    }
                    .rdp-day_range_start.rdp-day_range_end .rdp-button {
                      border-radius: 0.625rem;
                    }
                    .rdp-day_range_end .rdp-button,
                    .rdp-day_range_start .rdp-button {
                      border-radius: 0.625rem;
                    }
                    .rdp-day_range_middle {
                      border-radius: 0;
                    }
                    .electionDays {
                      background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%) !important;
                      color: white !important;
                      font-weight: 700 !important;
                      border-radius: 0.625rem !important;
                      box-shadow: 0 4px 12px rgba(99, 102, 241, 0.4) !important;
                      border: 2px solid rgba(255, 255, 255, 0.3) !important;
                      transform: scale(1);
                    }
                    .electionDays:hover {
                      background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%) !important;
                      transform: scale(1.08) !important;
                      box-shadow: 0 6px 16px rgba(99, 102, 241, 0.5) !important;
                      z-index: 10;
                      position: relative;
                    }
                    .electionStart {
                      background: linear-gradient(135deg, #10b981 0%, #059669 100%) !important;
                      color: white !important;
                      font-weight: 700 !important;
                      border-radius: 0.625rem !important;
                      box-shadow: 0 4px 12px rgba(16, 185, 129, 0.4) !important;
                      border: 2px solid rgba(255, 255, 255, 0.3) !important;
                    }
                    .electionStart:hover {
                      background: linear-gradient(135deg, #059669 0%, #047857 100%) !important;
                      transform: scale(1.08) !important;
                      box-shadow: 0 6px 16px rgba(16, 185, 129, 0.5) !important;
                      z-index: 10;
                      position: relative;
                    }
                    .electionEnd {
                      background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%) !important;
                      color: white !important;
                      font-weight: 700 !important;
                      border-radius: 0.625rem !important;
                      box-shadow: 0 4px 12px rgba(239, 68, 68, 0.4) !important;
                      border: 2px solid rgba(255, 255, 255, 0.3) !important;
                    }
                    .electionEnd:hover {
                      background: linear-gradient(135deg, #dc2626 0%, #b91c1c 100%) !important;
                      transform: scale(1.08) !important;
                      box-shadow: 0 6px 16px rgba(239, 68, 68, 0.5) !important;
                      z-index: 10;
                      position: relative;
                    }
                  `}</style>
                  <DayPicker
                    mode="single"
                    showOutsideDays
                    disabled
                    className="election-calendar"
                    modifiers={{
                      electionStart: (allElections || []).map((election) => {
                        const date = new Date(election.start_time);
                        return new Date(date.getFullYear(), date.getMonth(), date.getDate());
                      }),
                      electionEnd: (allElections || []).map((election) => {
                        const date = new Date(election.end_time);
                        return new Date(date.getFullYear(), date.getMonth(), date.getDate());
                      }),
                      electionDays: (allElections || []).flatMap((election) => {
                        const start = new Date(election.start_time);
                        const end = new Date(election.end_time);
                        const startDate = new Date(start.getFullYear(), start.getMonth(), start.getDate());
                        const endDate = new Date(end.getFullYear(), end.getMonth(), end.getDate());
                        const days = [];
                        const current = new Date(startDate);
                        while (current <= endDate) {
                          days.push(new Date(current));
                          current.setDate(current.getDate() + 1);
                        }
                        return days;
                      }),
                    }}
                    modifiersClassNames={{
                      electionStart: "electionStart",
                      electionEnd: "electionEnd",
                      electionDays: "electionDays",
                    }}
                  />
                </div>

                {/* Legend */}
                <div className="space-y-3 mb-4 p-3 bg-gradient-to-r from-gray-50 to-indigo-50 rounded-xl border border-gray-200">
                  <p className="text-xs font-bold text-gray-800 uppercase tracking-wider">
                    Legend
                  </p>
                  <div className="flex flex-wrap gap-4 text-xs">
                    <div className="flex items-center gap-2.5">
                      <div className="w-5 h-5 rounded-lg bg-gradient-to-br from-green-500 to-green-600 shadow-md border-2 border-white"></div>
                      <span className="text-gray-700 font-medium">Start date</span>
                    </div>
                    <div className="flex items-center gap-2.5">
                      <div className="w-5 h-5 rounded-lg bg-gradient-to-br from-indigo-500 to-purple-600 shadow-md border-2 border-white"></div>
                      <span className="text-gray-700 font-medium">Active period</span>
                    </div>
                    <div className="flex items-center gap-2.5">
                      <div className="w-5 h-5 rounded-lg bg-gradient-to-br from-red-500 to-red-600 shadow-md border-2 border-white"></div>
                      <span className="text-gray-700 font-medium">End date</span>
                    </div>
                  </div>
                </div>

                {/* Upcoming elections summary */}
                {activeElections && activeElections.length > 0 && (
                  <div className="border-t-2 border-indigo-100 pt-5 mt-5">
                    <div className="flex items-center gap-2 mb-4">
                      <div className="w-1.5 h-1.5 rounded-full bg-indigo-500"></div>
                      <p className="text-xs font-bold text-gray-800 uppercase tracking-wider">
                        Upcoming Elections
                      </p>
                    </div>
                    <div className="space-y-2.5">
                      {activeElections
                        .slice(0, 3)
                        .sort(
                          (a, b) =>
                            new Date(a.end_time).getTime() -
                            new Date(b.end_time).getTime()
                        )
                        .map((election) => (
                          <Link
                            key={election.id}
                            href={`/dashboard/elections/${election.id}`}
                            className="flex items-center gap-3 p-3 rounded-xl bg-gradient-to-r from-indigo-50 to-purple-50 hover:from-indigo-100 hover:to-purple-100 border border-indigo-200 hover:border-indigo-300 transition-all duration-200 hover:shadow-md group"
                          >
                            <div className="w-3 h-3 rounded-full bg-gradient-to-br from-indigo-500 to-purple-600 flex-shrink-0 shadow-sm group-hover:scale-125 transition-transform"></div>
                            <div className="flex-1 min-w-0">
                              <p className="text-xs font-semibold text-gray-900 line-clamp-1 group-hover:text-indigo-700 transition-colors">
                                {election.title}
                              </p>
                              <p className="text-[10px] text-gray-600 mt-0.5 font-medium">
                                Ends {formatDate(election.end_time, "MMM d, yyyy")}
                              </p>
                            </div>
                            <svg
                              className="w-4 h-4 text-indigo-400 group-hover:text-indigo-600 group-hover:translate-x-1 transition-all"
                              fill="none"
                              stroke="currentColor"
                              viewBox="0 0 24 24"
                            >
                              <path
                                strokeLinecap="round"
                                strokeLinejoin="round"
                                strokeWidth={2}
                                d="M9 5l7 7-7 7"
                              />
                            </svg>
                          </Link>
                        ))}
                    </div>
                  </div>
                )}
              </>
            )}
          </motion.div>

          {/* Recent activity */}
          <div className="bg-white border border-gray-200 rounded-xl p-6 shadow-sm">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">
              Recent activity
            </h2>
            {isLoadingVotes ? (
              <p className="text-sm text-gray-500">
                Loading your recent votes…
              </p>
            ) : sortedRecentVotes.length === 0 ? (
              <p className="text-sm text-gray-500">
                You haven&apos;t cast any votes yet. When you do, your latest
                activity will appear here.
              </p>
            ) : (
              <>
                <ul className="space-y-3 text-sm text-gray-700">
                  {paginatedRecentVotes.map((entry) => (
                    <li key={`${entry.election.id}-${entry.voted_at}`}>
                      <div className="flex items-start gap-2">
                        <span className="mt-0.5 h-2 w-2 rounded-full bg-indigo-500 flex-shrink-0" />
                        <div>
                          <p className="font-medium text-gray-900">
                            Voted in {entry.election.title}
                          </p>
                          <p className="text-xs text-gray-500">
                            {entry.voted_at
                              ? formatDate(entry.voted_at)
                              : "Date not available"}
                          </p>
                        </div>
                      </div>
                    </li>
                  ))}
                </ul>
                {recentActivityTotalPages > 1 && (
                  <div className="mt-1">
                    <Pagination
                      currentPage={safeRecentActivityPage}
                      totalPages={recentActivityTotalPages}
                      onPageChange={setRecentActivityPage}
                      itemsPerPage={RECENT_ACTIVITY_PER_PAGE}
                      totalItems={sortedRecentVotes.length}
                    />
                  </div>
                )}
              </>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
