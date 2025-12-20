"use client";

import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Cell,
  ReferenceLine,
} from "recharts";
import { useAllElectionsTurnout } from "@/hooks/useElections";
import { BarChart2, TrendingUp, Users, Target, CheckCircle2 } from "lucide-react";
import { motion } from "framer-motion";
import * as TooltipPrimitive from "@radix-ui/react-tooltip";

interface TurnoutDataPoint {
  name: string;
  participationRate: number;
  participationGoal: number;
  totalVoted: number;
  totalEligible: number;
  status: string;
}

export function ElectionTurnoutChart() {
  const { data: electionsTurnout, isLoading, error } = useAllElectionsTurnout();

  if (isLoading) {
    return (
      <div className="bg-white border border-gray-200 rounded-xl p-6 shadow-sm">
        <div className="animate-pulse">
          <div className="h-6 bg-gray-200 rounded w-1/3 mb-4"></div>
          <div className="h-64 bg-gray-100 rounded"></div>
        </div>
      </div>
    );
  }

  if (error || !electionsTurnout || electionsTurnout.length === 0) {
    return (
      <div className="bg-white border border-gray-200 rounded-xl p-6 shadow-sm">
        <div className="flex flex-col items-center justify-center h-64 text-center">
          <div className="w-16 h-16 rounded-full bg-gray-100 flex items-center justify-center mb-3">
            <BarChart2 className="w-8 h-8 text-gray-400" />
          </div>
          <p className="text-sm text-gray-500">
            No turnout data available. Once elections have turnout data, it will appear here.
          </p>
        </div>
      </div>
    );
  }

  // Prepare chart data
  const chartData: TurnoutDataPoint[] = electionsTurnout
    .filter((item) => item.turnout !== null)
    .map((item) => ({
      name:
        item.election.title.length > 20
          ? `${item.election.title.substring(0, 20)}...`
          : item.election.title,
      participationRate: item.turnout!.turnout.participation_rate,
      participationGoal: item.turnout!.turnout.participation_goal,
      totalVoted: item.turnout!.turnout.total_voted,
      totalEligible: item.turnout!.turnout.total_eligible_voters,
      status: item.turnout!.status,
    }))
    .sort((a, b) => b.participationRate - a.participationRate)
    .slice(0, 10); // Show top 10 elections

  if (chartData.length === 0) {
    return (
      <div className="bg-white border border-gray-200 rounded-xl p-6 shadow-sm">
        <div className="flex flex-col items-center justify-center h-64 text-center">
          <div className="w-16 h-16 rounded-full bg-gray-100 flex items-center justify-center mb-3">
            <BarChart2 className="w-8 h-8 text-gray-400" />
          </div>
          <p className="text-sm text-gray-500">
            No turnout data available for any elections.
          </p>
        </div>
      </div>
    );
  }

  // Calculate average participation rate
  const avgParticipationRate =
    chartData.reduce((sum, item) => sum + item.participationRate, 0) /
    chartData.length;

  // Custom tooltip matching dashboard style
  const CustomTooltip = ({ active, payload }: any) => {
    if (active && payload && payload.length) {
      const data = payload[0].payload as TurnoutDataPoint;
      const fullTitle = electionsTurnout.find(
        (item) =>
          item.turnout?.turnout.participation_rate === data.participationRate
      )?.election.title || data.name;
      return (
        <div className="bg-white border border-gray-200 rounded-lg shadow-lg p-3">
          <p className="text-sm font-semibold text-gray-900 mb-2">
            {fullTitle}
          </p>
          <div className="space-y-1.5 text-xs">
            <div className="flex items-center justify-between gap-4">
              <span className="text-gray-600">Participation:</span>
              <span className="font-semibold text-gray-900">
                {data.participationRate.toFixed(1)}%
              </span>
            </div>
            <div className="flex items-center justify-between gap-4">
              <span className="text-gray-600">Goal:</span>
              <span className="font-semibold text-gray-900">
                {data.participationGoal}%
              </span>
            </div>
            <div className="flex items-center justify-between gap-4">
              <span className="text-gray-600">Votes:</span>
              <span className="font-semibold text-gray-900">
                {data.totalVoted.toLocaleString()} / {data.totalEligible.toLocaleString()}
              </span>
            </div>
          </div>
        </div>
      );
    }
    return null;
  };

  // Get gradient ID and color based on participation rate vs goal
  const getBarGradient = (rate: number, goal: number) => {
    const percentage = (rate / goal) * 100;
    if (percentage >= 100) return { id: "goalAchieved", color: "#10b981" };
    if (percentage >= 75) return { id: "closeToGoal", color: "#3b82f6" };
    if (percentage >= 50) return { id: "halfway", color: "#f59e0b" };
    return { id: "belowGoal", color: "#ef4444" };
  };

  // Get status badge color
  const getStatusColor = (status: string) => {
    switch (status) {
      case "active":
        return "text-green-600 bg-green-50 border-green-200";
      case "closed":
        return "text-gray-600 bg-gray-50 border-gray-200";
      case "upcoming":
        return "text-blue-600 bg-blue-50 border-blue-200";
      default:
        return "text-gray-600 bg-gray-50 border-gray-200";
    }
  };

  // Count elections by status
  const goalAchieved = chartData.filter(
    (item) => item.participationRate >= item.participationGoal
  ).length;
  const closeToGoal = chartData.filter(
    (item) =>
      item.participationRate >= item.participationGoal * 0.75 &&
      item.participationRate < item.participationGoal
  ).length;
  const belowGoal = chartData.length - goalAchieved - closeToGoal;

  // Calculate total stats
  const totalVoted = chartData.reduce((sum, item) => sum + item.totalVoted, 0);
  const totalEligible = chartData.reduce((sum, item) => sum + item.totalEligible, 0);

  return (
    <div className="bg-white border border-gray-200 rounded-xl p-6 shadow-sm">
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div>
          <h2 className="text-lg font-semibold text-gray-900">
            Election Turnout Statistics
          </h2>
          <p className="text-xs text-gray-500 mt-0.5">
            Participation rates across all elections
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
                <BarChart2 className="w-4 h-4" />
              </button>
            </TooltipPrimitive.Trigger>
            <TooltipPrimitive.Content className="rounded-md bg-gray-900 px-2 py-1 text-xs text-white shadow-sm">
              Shows participation rates for each election compared to the 80% goal.
            </TooltipPrimitive.Content>
          </TooltipPrimitive.Root>
        </TooltipPrimitive.Provider>
      </div>

      {/* Top Stats Row */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
        <motion.div
          className="bg-gradient-to-br from-indigo-50 to-indigo-100/50 border border-indigo-200 rounded-lg p-4"
          initial={{ opacity: 0, scale: 0.95 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 0.1 }}
        >
          <div className="flex items-center gap-2 mb-2">
            <Users className="w-4 h-4 text-indigo-600" />
            <p className="text-xs font-semibold text-indigo-700 uppercase tracking-wide">
              Total Voters
            </p>
          </div>
          <p className="text-2xl font-bold text-indigo-900">
            {totalVoted.toLocaleString()}
          </p>
          <p className="text-xs text-indigo-600 mt-1">
            of {totalEligible.toLocaleString()} eligible
          </p>
        </motion.div>

        <motion.div
          className="bg-gradient-to-br from-green-50 to-green-100/50 border border-green-200 rounded-lg p-4"
          initial={{ opacity: 0, scale: 0.95 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 0.15 }}
        >
          <div className="flex items-center gap-2 mb-2">
            <Target className="w-4 h-4 text-green-600" />
            <p className="text-xs font-semibold text-green-700 uppercase tracking-wide">
              Avg Participation
            </p>
          </div>
          <p className="text-2xl font-bold text-green-900">
            {avgParticipationRate.toFixed(1)}%
          </p>
          <p className="text-xs text-green-600 mt-1">
            across all elections
          </p>
        </motion.div>

        <motion.div
          className="bg-gradient-to-br from-blue-50 to-blue-100/50 border border-blue-200 rounded-lg p-4"
          initial={{ opacity: 0, scale: 0.95 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 0.2 }}
        >
          <div className="flex items-center gap-2 mb-2">
            <CheckCircle2 className="w-4 h-4 text-blue-600" />
            <p className="text-xs font-semibold text-blue-700 uppercase tracking-wide">
              Goal Achieved
            </p>
          </div>
          <p className="text-2xl font-bold text-blue-900">{goalAchieved}</p>
          <p className="text-xs text-blue-600 mt-1">
            {chartData.length > 0
              ? `${((goalAchieved / chartData.length) * 100).toFixed(0)}% of elections`
              : "elections"}
          </p>
        </motion.div>

        <motion.div
          className="bg-gradient-to-br from-purple-50 to-purple-100/50 border border-purple-200 rounded-lg p-4"
          initial={{ opacity: 0, scale: 0.95 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 0.25 }}
        >
          <div className="flex items-center gap-2 mb-2">
            <TrendingUp className="w-4 h-4 text-purple-600" />
            <p className="text-xs font-semibold text-purple-700 uppercase tracking-wide">
              Total Elections
            </p>
          </div>
          <p className="text-2xl font-bold text-purple-900">{chartData.length}</p>
          <p className="text-xs text-purple-600 mt-1">
            with turnout data
          </p>
        </motion.div>
      </div>

      {/* Chart */}
      <motion.div
        className="w-full"
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5, delay: 0.3 }}
      >
        <ResponsiveContainer width="100%" height={450}>
          <BarChart
            data={chartData}
            layout="vertical"
            margin={{ top: 20, right: 30, left: 120, bottom: 20 }}
          >
            <defs>
              <linearGradient id="goalAchieved" x1="0" y1="0" x2="1" y2="0">
                <stop offset="0%" stopColor="#10b981" stopOpacity={1} />
                <stop offset="100%" stopColor="#059669" stopOpacity={0.9} />
              </linearGradient>
              <linearGradient id="closeToGoal" x1="0" y1="0" x2="1" y2="0">
                <stop offset="0%" stopColor="#3b82f6" stopOpacity={1} />
                <stop offset="100%" stopColor="#2563eb" stopOpacity={0.9} />
              </linearGradient>
              <linearGradient id="halfway" x1="0" y1="0" x2="1" y2="0">
                <stop offset="0%" stopColor="#f59e0b" stopOpacity={1} />
                <stop offset="100%" stopColor="#d97706" stopOpacity={0.9} />
              </linearGradient>
              <linearGradient id="belowGoal" x1="0" y1="0" x2="1" y2="0">
                <stop offset="0%" stopColor="#ef4444" stopOpacity={1} />
                <stop offset="100%" stopColor="#dc2626" stopOpacity={0.9} />
              </linearGradient>
            </defs>
            <CartesianGrid
              strokeDasharray="3 3"
              horizontal={true}
              vertical={false}
              stroke="#e5e7eb"
              opacity={0.5}
            />
            <XAxis
              type="number"
              domain={[0, 100]}
              tick={{ fontSize: 11, fill: "#6b7280" }}
              axisLine={{ stroke: "#e5e7eb" }}
              tickLine={{ stroke: "#e5e7eb" }}
              label={{
                value: "Participation Rate (%)",
                position: "insideBottom",
                offset: -5,
                style: { textAnchor: "middle", fill: "#6b7280", fontSize: 12 },
              }}
            />
            <YAxis
              type="category"
              dataKey="name"
              width={110}
              tick={{ fontSize: 11, fill: "#6b7280" }}
              axisLine={{ stroke: "#e5e7eb" }}
              tickLine={{ stroke: "#e5e7eb" }}
            />
            <Tooltip
              content={<CustomTooltip />}
              cursor={{ fill: "rgba(99, 102, 241, 0.08)" }}
              animationDuration={200}
            />
            <ReferenceLine
              x={80}
              stroke="#9ca3af"
              strokeDasharray="5 5"
              strokeWidth={2}
              label={{ value: "Goal (80%)", position: "top", fill: "#6b7280", fontSize: 11 }}
            />
            <Bar
              dataKey="participationRate"
              name="Participation Rate"
              radius={[0, 8, 8, 0]}
              animationBegin={0}
              animationDuration={800}
              animationEasing="ease-out"
            >
              {chartData.map((entry, index) => {
                const gradient = getBarGradient(
                  entry.participationRate,
                  entry.participationGoal
                );
                return (
                  <Cell
                    key={`cell-${index}`}
                    fill={`url(#${gradient.id})`}
                  />
                );
              })}
            </Bar>
          </BarChart>
        </ResponsiveContainer>
      </motion.div>

      {/* Bottom Stats Grid */}
      <div className="mt-6 pt-6 border-t border-gray-100">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          <div className="text-center p-3 bg-gray-50 rounded-lg">
            <div className="flex items-center justify-center gap-2 mb-1">
              <div className="w-2.5 h-2.5 rounded-full bg-green-500" />
              <p className="text-xs font-medium text-gray-600">Goal Achieved</p>
            </div>
            <p className="text-xl font-bold text-gray-900">{goalAchieved}</p>
          </div>
          <div className="text-center p-3 bg-gray-50 rounded-lg">
            <div className="flex items-center justify-center gap-2 mb-1">
              <div className="w-2.5 h-2.5 rounded-full bg-blue-500" />
              <p className="text-xs font-medium text-gray-600">Close to Goal</p>
            </div>
            <p className="text-xl font-bold text-gray-900">{closeToGoal}</p>
          </div>
          <div className="text-center p-3 bg-gray-50 rounded-lg">
            <div className="flex items-center justify-center gap-2 mb-1">
              <div className="w-2.5 h-2.5 rounded-full bg-orange-500" />
              <p className="text-xs font-medium text-gray-600">Below Goal</p>
            </div>
            <p className="text-xl font-bold text-gray-900">{belowGoal}</p>
          </div>
          <div className="text-center p-3 bg-gray-50 rounded-lg">
            <div className="flex items-center justify-center gap-2 mb-1">
              <div className="w-2.5 h-2.5 rounded-full bg-purple-500" />
              <p className="text-xs font-medium text-gray-600">Total</p>
            </div>
            <p className="text-xl font-bold text-gray-900">{chartData.length}</p>
          </div>
        </div>
      </div>
    </div>
  );
}
