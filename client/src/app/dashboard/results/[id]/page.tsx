"use client";

import { useParams, useRouter } from "next/navigation";
import { useElectionResults } from "@/hooks/useElections";
import dayjs from "@/lib/dayjs";
import { motion } from "framer-motion";
import {
  Trophy,
  Users,
  Calendar,
  ArrowLeft,
  TrendingUp,
  CheckCircle2,
} from "lucide-react";
import {
  Bar,
  BarChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip as RechartsTooltip,
  XAxis,
  YAxis,
  Cell,
} from "recharts";
import Avatar, { genConfig } from "react-nice-avatar";
import { useMemo } from "react";

export default function ElectionResultsPage() {
  const params = useParams();
  const router = useRouter();
  const electionId = params?.id ? parseInt(params.id as string) : null;
  const { data: results, isLoading, error } = useElectionResults(electionId);

  // Generate avatar config for candidates
  const getCandidateAvatar = (candidate: any) => {
    const seed = candidate.candidate_name || `candidate-${candidate.candidate_id}`;
    const config = genConfig(seed);
    return config;
  };

  if (isLoading) {
    return (
      <div className="h-full overflow-y-auto bg-gray-50">
        <div className="flex items-center justify-center h-full">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600"></div>
        </div>
      </div>
    );
  }

  if (error || !results) {
    return (
      <div className="h-full overflow-y-auto bg-gray-50">
        <div className="p-8 max-w-7xl mx-auto">
          <div className="bg-red-50 border border-red-200 rounded-lg p-6 text-center">
            <h2 className="text-lg font-semibold text-red-900 mb-2">
              Unable to load results
            </h2>
            <p className="text-red-700">
              {error instanceof Error
                ? error.message
                : "Results are only available after the election closes."}
            </p>
            <button
              onClick={() => router.push("/dashboard/results")}
              className="mt-4 text-sm text-red-600 hover:text-red-700"
            >
              ← Back to Results
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="h-full overflow-y-auto bg-gray-50">
      <div className="p-8 max-w-7xl mx-auto">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: -10 }}
          animate={{ opacity: 1, y: 0 }}
          className="mb-8"
        >
          <button
            onClick={() => router.push("/dashboard/results")}
            className="flex items-center gap-2 text-gray-600 hover:text-gray-900 mb-4 transition-colors"
          >
            <ArrowLeft className="w-4 h-4" />
            <span>Back to Results</span>
          </button>

          <div className="flex items-start justify-between">
            <div>
              <h1 className="text-3xl font-bold text-gray-900">
                {results.election.title}
              </h1>
              <p className="text-gray-600 mt-2">
                {results.election.description || "Election results"}
              </p>
            </div>
            <div className="flex items-center gap-2 px-4 py-2 bg-gray-100 rounded-lg">
              <Trophy className="w-5 h-5 text-indigo-600" />
              <span className="font-semibold text-gray-900">Results</span>
            </div>
          </div>
        </motion.div>

        {/* Summary Cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <motion.div
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="bg-white border border-gray-200 rounded-xl p-6 shadow-sm"
          >
            <div className="flex items-center gap-3 mb-2">
              <div className="w-10 h-10 rounded-lg bg-indigo-100 flex items-center justify-center">
                <Users className="w-5 h-5 text-indigo-600" />
              </div>
              <div>
                <p className="text-sm text-gray-500">Total Votes</p>
                <p className="text-2xl font-bold text-gray-900">
                  {results.total_votes}
                </p>
              </div>
            </div>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="bg-white border border-gray-200 rounded-xl p-6 shadow-sm"
          >
            <div className="flex items-center gap-3 mb-2">
              <div className="w-10 h-10 rounded-lg bg-green-100 flex items-center justify-center">
                <CheckCircle2 className="w-5 h-5 text-green-600" />
              </div>
              <div>
                <p className="text-sm text-gray-500">Unique Voters</p>
                <p className="text-2xl font-bold text-gray-900">
                  {results.unique_voters}
                </p>
              </div>
            </div>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3 }}
            className="bg-white border border-gray-200 rounded-xl p-6 shadow-sm"
          >
            <div className="flex items-center gap-3 mb-2">
              <div className="w-10 h-10 rounded-lg bg-purple-100 flex items-center justify-center">
                <TrendingUp className="w-5 h-5 text-purple-600" />
              </div>
              <div>
                <p className="text-sm text-gray-500">Positions</p>
                <p className="text-2xl font-bold text-gray-900">
                  {results.positions.length}
                </p>
              </div>
            </div>
          </motion.div>
        </div>

        {/* Position Results */}
        <div className="space-y-6">
          {results.positions.map((position, index) => (
            <motion.div
              key={position.position_id}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.1 * (index + 1) }}
              className="bg-white border border-gray-200 rounded-xl p-6 shadow-sm"
            >
              {/* Position Header */}
              <div className="mb-6">
                <div className="flex items-start justify-between mb-2">
                  <div>
                    <h2 className="text-2xl font-bold text-gray-900">
                      {position.position_name}
                    </h2>
                    {position.position_description && (
                      <p className="text-gray-600 mt-1">
                        {position.position_description}
                      </p>
                    )}
                  </div>
                  <span className="px-3 py-1 rounded-full text-xs font-medium bg-indigo-100 text-indigo-800 capitalize">
                    {position.position_type}
                  </span>
                </div>
                <div className="flex items-center gap-6 mt-4 text-sm text-gray-600">
                  <div className="flex items-center gap-2">
                    <Users className="w-4 h-4" />
                    <span>
                      <strong>{position.total_votes}</strong> total votes
                    </span>
                  </div>
                  <div className="flex items-center gap-2">
                    <CheckCircle2 className="w-4 h-4" />
                    <span>
                      <strong>{position.valid_votes}</strong> valid votes
                    </span>
                  </div>
                  {position.abstentions > 0 && (
                    <div className="flex items-center gap-2">
                      <span>
                        <strong>{position.abstentions}</strong> abstentions
                      </span>
                    </div>
                  )}
                </div>
              </div>

              {/* Winners */}
              {position.winners.length > 0 && (
                <div className="mb-6 p-4 bg-gradient-to-r from-green-50 to-emerald-50 border-2 border-green-200 rounded-lg">
                  <div className="flex items-center gap-2 mb-3">
                    <Trophy className="w-5 h-5 text-green-600" />
                    <h3 className="font-bold text-green-900">
                      Winner{position.winners.length > 1 ? "s" : ""}
                    </h3>
                  </div>
                  <div className="space-y-2">
                    {position.winners.map((winner) => (
                      <div
                        key={winner.candidate_id}
                        className="flex items-center justify-between p-3 bg-white rounded-lg"
                      >
                        <div className="flex items-center gap-3">
                          <div className="w-10 h-10 rounded-full overflow-hidden bg-indigo-600 flex items-center justify-center flex-shrink-0">
                            {winner.candidate_photo ? (
                              <img
                                src={winner.candidate_photo}
                                alt={winner.candidate_name}
                                className="w-10 h-10 object-cover"
                              />
                            ) : (
                              <Avatar
                                className="w-10 h-10"
                                {...getCandidateAvatar(winner)}
                              />
                            )}
                          </div>
                          <div>
                            <p className="font-semibold text-gray-900">
                              {winner.candidate_name}
                            </p>
                            {winner.candidate_tagline && (
                              <p className="text-xs text-gray-500">
                                {winner.candidate_tagline}
                              </p>
                            )}
                          </div>
                        </div>
                        <div className="text-right">
                          <p className="text-lg font-bold text-green-700">
                            {winner.votes} votes
                          </p>
                          <p className="text-sm text-gray-600">
                            {winner.percentage}%
                          </p>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* Results Chart */}
              {position.candidates.length > 0 && (
                <div className="mb-6">
                  <h3 className="text-lg font-semibold text-gray-900 mb-4">
                    Vote Distribution
                  </h3>
                  <div className="h-64 w-full">
                    <ResponsiveContainer width="100%" height="100%" minWidth={0} minHeight={256}>
                      <BarChart
                        data={position.candidates
                          .sort((a, b) => b.votes - a.votes)
                          .map((c) => ({
                            name:
                              c.candidate_name.length > 15
                                ? c.candidate_name.substring(0, 15) + "..."
                                : c.candidate_name,
                            votes: c.votes,
                            percentage: c.percentage,
                            isWinner: position.winners.some(
                              (w) => w.candidate_id === c.candidate_id
                            ),
                          }))}
                        margin={{ top: 10, right: 10, left: 0, bottom: 5 }}
                      >
                        <CartesianGrid
                          strokeDasharray="3 3"
                          vertical={false}
                          stroke="#e5e7eb"
                          opacity={0.5}
                        />
                        <XAxis
                          dataKey="name"
                          tick={{ fontSize: 11, fill: "#6b7280" }}
                          angle={-45}
                          textAnchor="end"
                          height={80}
                        />
                        <YAxis
                          allowDecimals={false}
                          tick={{ fontSize: 11, fill: "#6b7280" }}
                        />
                        <RechartsTooltip
                          content={({ active, payload }) => {
                            if (active && payload && payload.length) {
                              const data = payload[0].payload;
                              return (
                                <div className="rounded-lg border border-gray-200 bg-white p-3 text-sm shadow-lg">
                                  <p className="font-semibold text-gray-900">
                                    {data.name}
                                  </p>
                                  <p className="text-gray-700">
                                    {data.votes} votes ({data.percentage}%)
                                  </p>
                                  {data.isWinner && (
                                    <p className="text-green-600 font-medium mt-1">
                                      Winner
                                    </p>
                                  )}
                                </div>
                              );
                            }
                            return null;
                          }}
                        />
                        <Bar dataKey="votes" radius={[8, 8, 0, 0]}>
                          {position.candidates
                            .sort((a, b) => b.votes - a.votes)
                            .map((c, index) => {
                              const isWinner = position.winners.some(
                                (w) => w.candidate_id === c.candidate_id
                              );
                              return (
                                <Cell
                                  key={`cell-${index}`}
                                  fill={
                                    isWinner
                                      ? "#22c55e"
                                      : index % 2 === 0
                                      ? "#6366f1"
                                      : "#8b5cf6"
                                  }
                                />
                              );
                            })}
                        </Bar>
                      </BarChart>
                    </ResponsiveContainer>
                  </div>
                </div>
              )}

              {/* Detailed Results Table */}
              <div className="overflow-x-auto">
                <table className="min-w-full divide-y divide-gray-200">
                  <thead className="bg-gray-50">
                    <tr>
                      <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                        Rank
                      </th>
                      <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                        Candidate
                      </th>
                      <th className="px-4 py-3 text-right text-xs font-semibold text-gray-700 uppercase tracking-wider">
                        Votes
                      </th>
                      <th className="px-4 py-3 text-right text-xs font-semibold text-gray-700 uppercase tracking-wider">
                        Percentage
                      </th>
                    </tr>
                  </thead>
                  <tbody className="bg-white divide-y divide-gray-200">
                    {position.candidates
                      .sort((a, b) => (b.rank || 999) - (a.rank || 999))
                      .map((candidate) => {
                        const isWinner = position.winners.some(
                          (w) => w.candidate_id === candidate.candidate_id
                        );
                        return (
                          <tr
                            key={candidate.candidate_id}
                            className={
                              isWinner
                                ? "bg-green-50 border-l-4 border-green-500"
                                : "hover:bg-gray-50"
                            }
                          >
                            <td className="px-4 py-4 whitespace-nowrap">
                              {candidate.rank ? (
                                <span
                                  className={`inline-flex items-center justify-center w-8 h-8 rounded-full font-bold ${
                                    isWinner
                                      ? "bg-green-600 text-white"
                                      : "bg-indigo-100 text-indigo-800"
                                  }`}
                                >
                                  {candidate.rank}
                                </span>
                              ) : (
                                <span className="text-gray-400">—</span>
                              )}
                            </td>
                            <td className="px-4 py-4">
                              <div className="flex items-center gap-3">
                                <div className="w-10 h-10 rounded-full overflow-hidden bg-indigo-600 flex items-center justify-center flex-shrink-0">
                                  {candidate.candidate_photo ? (
                                    <img
                                      src={candidate.candidate_photo}
                                      alt={candidate.candidate_name}
                                      className="w-10 h-10 object-cover"
                                    />
                                  ) : (
                                    <Avatar
                                      className="w-10 h-10"
                                      {...getCandidateAvatar(candidate)}
                                    />
                                  )}
                                </div>
                                <div>
                                  <p className="font-medium text-gray-900">
                                    {candidate.candidate_name}
                                    {isWinner && (
                                      <Trophy className="w-4 h-4 text-green-600 inline-block ml-2" />
                                    )}
                                  </p>
                                  {candidate.candidate_tagline && (
                                    <p className="text-sm text-gray-500">
                                      {candidate.candidate_tagline}
                                    </p>
                                  )}
                                </div>
                              </div>
                            </td>
                            <td className="px-4 py-4 whitespace-nowrap text-right font-semibold text-gray-900">
                              {candidate.votes}
                            </td>
                            <td className="px-4 py-4 whitespace-nowrap text-right">
                              <div className="flex items-center justify-end gap-2">
                                <div className="w-24 bg-gray-200 rounded-full h-2">
                                  <div
                                    className={`h-2 rounded-full ${
                                      isWinner
                                        ? "bg-green-600"
                                        : "bg-indigo-600"
                                    }`}
                                    style={{
                                      width: `${Math.min(
                                        candidate.percentage,
                                        100
                                      )}%`,
                                    }}
                                  />
                                </div>
                                <span className="text-sm font-medium text-gray-700 w-12 text-right">
                                  {candidate.percentage}%
                                </span>
                              </div>
                            </td>
                          </tr>
                        );
                      })}
                  </tbody>
                </table>
              </div>
            </motion.div>
          ))}
        </div>

        {results.positions.length === 0 && (
          <div className="bg-white border border-gray-200 rounded-lg p-12 text-center">
            <p className="text-gray-500">No positions found for this election.</p>
          </div>
        )}
      </div>
    </div>
  );
}

