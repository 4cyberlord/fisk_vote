"use client";

import { useParams } from "next/navigation";
import { useElection } from "@/hooks/useElections";
import { formatDate } from "@/lib/dateUtils";
import { PositionSection } from "@/components/elections/PositionSection";
import { useServerTime } from "@/hooks/useServerTime";

export default function ElectionDetailPage() {
  const params = useParams();
  const electionId = params?.id ? parseInt(params.id as string) : null;
  const { data: election, isLoading, error } = useElection(electionId);
  
  // Use Nashville server time for accurate status
  const { getElectionStatus, getElectionTimeRemaining } = useServerTime();

  const getStatusBadgeColor = (status: string) => {
    switch (status) {
      case "Open":
        return "bg-green-100 text-green-800 border-green-200";
      case "Upcoming":
        return "bg-blue-100 text-blue-800 border-blue-200";
      case "Closed":
        return "bg-gray-100 text-gray-800 border-gray-200";
      default:
        return "bg-gray-100 text-gray-800 border-gray-200";
    }
  };

  const getElectionTypeLabel = (type: string) => {
    const labels: Record<string, string> = {
      single: "Single Choice",
      multiple: "Multiple Choice",
      referendum: "Referendum",
      ranked: "Ranked Choice",
      poll: "Poll",
    };
    return labels[type] || type;
  };

  // Calculate status using Nashville server time (from World Time API)
  const liveStatus = election 
    ? getElectionStatus(election.start_timestamp, election.end_timestamp, election.status)
    : null;
  
  // Use live status for display, fallback to backend status
  const displayStatus = liveStatus || election?.current_status || "Closed";
  
  // Get time remaining using Nashville server time
  const timeRemaining = displayStatus === "Open" 
    ? getElectionTimeRemaining(election?.end_timestamp)
    : null;

  // Loading State
  if (isLoading) {
    return (
      <div className="p-8">
        <div className="max-w-7xl mx-auto">
          <div className="animate-pulse space-y-6">
            <div className="h-8 bg-gray-200 rounded w-1/4"></div>
            <div className="h-64 bg-gray-200 rounded"></div>
            <div className="h-48 bg-gray-200 rounded"></div>
          </div>
        </div>
      </div>
    );
  }

  // Error State
  if (error || !election) {
    return (
      <div className="p-8">
        <div className="max-w-7xl mx-auto">
          <div className="mb-6">
            <button
              onClick={() => window.history.back()}
              className="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 hover:border-gray-400 transition-all duration-200 shadow-sm hover:shadow-md"
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
                  d="M15 19l-7-7 7-7"
                />
              </svg>
              Back to Elections
            </button>
          </div>
          <div className="bg-red-50 border border-red-200 rounded-lg p-8 text-center">
            <svg
              className="mx-auto h-12 w-12 text-red-400 mb-4"
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
            <h2 className="text-xl font-semibold text-red-900 mb-2">
              Election Not Found
            </h2>
            <p className="text-red-700">
              {error
                ? "Failed to load election details. Please try again."
                : "The election you're looking for doesn't exist or you don't have access to it."}
            </p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="p-8 bg-gray-50 min-h-screen">
      <div className="max-w-7xl mx-auto">
        {/* Back Button */}
        <div className="mb-6">
          <button
            onClick={() => window.history.back()}
            className="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 hover:border-gray-400 transition-all duration-200 shadow-sm hover:shadow-md"
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
                d="M15 19l-7-7 7-7"
              />
            </svg>
            Back to Elections
          </button>
        </div>

        {/* Election Header Card */}
        <div className="bg-white border border-gray-200 rounded-lg shadow-sm mb-6 overflow-hidden">
          <div className="p-8">
            <div className="flex items-start justify-between mb-4">
              <div className="flex-1">
                <div className="flex items-center gap-3 mb-3">
                  <h1 className="text-3xl font-bold text-gray-900">
                    {election.title}
                  </h1>
                  <span
                    className={`px-4 py-1 rounded-full text-sm font-medium border ${getStatusBadgeColor(
                      displayStatus
                    )}`}
                  >
                    {displayStatus}
                  </span>
                  {election.has_voted && (
                    <span className="px-3 py-1 rounded-full text-xs font-medium bg-indigo-100 text-indigo-800">
                      ✓ Voted
                    </span>
                  )}
                </div>
                {timeRemaining && (
                  <p className="text-sm text-indigo-600 font-medium mb-2">
                    ⏰ {timeRemaining}
                  </p>
                )}
              </div>
            </div>

            <p className="text-gray-700 text-base leading-relaxed mb-6">
              {election.description || "--"}
            </p>

            {/* Election Metadata */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 pt-6 border-t border-gray-200">
              <div>
                <p className="text-xs font-medium text-gray-500 uppercase mb-1">
                  Election Type
                </p>
                <p className="text-sm font-semibold text-gray-900">
                  {election.type ? getElectionTypeLabel(election.type) : "--"}
                </p>
              </div>
              <div>
                <p className="text-xs font-medium text-gray-500 uppercase mb-1">
                  Start Date
                </p>
                <p className="text-sm font-semibold text-gray-900">
                  {formatDate(election.start_timestamp || election.start_time)}
                </p>
              </div>
              <div>
                <p className="text-xs font-medium text-gray-500 uppercase mb-1">
                  End Date
                </p>
                <p className="text-sm font-semibold text-gray-900">
                  {formatDate(election.end_timestamp || election.end_time)}
                </p>
              </div>
              <div>
                <p className="text-xs font-medium text-gray-500 uppercase mb-1">
                  Positions
                </p>
                <p className="text-sm font-semibold text-gray-900">
                  {election.positions?.length || 0} position
                  {election.positions?.length !== 1 ? "s" : ""}
                </p>
              </div>
            </div>

            {/* Election Rules */}
            <div className="mt-6 pt-6 border-t border-gray-200">
              <h3 className="text-sm font-semibold text-gray-900 mb-3">
                Election Rules
              </h3>
              <div className="flex flex-wrap gap-4 text-sm text-gray-600">
                {election.max_selection && (
                  <span className="flex items-center gap-1">
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
                    Max {election.max_selection} selection
                    {election.max_selection > 1 ? "s" : ""}
                  </span>
                )}
                {election.allow_write_in && (
                  <span className="flex items-center gap-1">
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
                        d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"
                      />
                    </svg>
                    Write-in allowed
                  </span>
                )}
                {election.allow_abstain && (
                  <span className="flex items-center gap-1">
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
                        d="M6 18L18 6M6 6l12 12"
                      />
                    </svg>
                    Abstain allowed
                  </span>
                )}
              </div>
            </div>
          </div>
        </div>

        {/* Positions Section */}
        {election.positions && election.positions.length > 0 ? (
          <div className="space-y-6">
            <h2 className="text-2xl font-bold text-gray-900">
              Positions & Candidates
            </h2>

            {election.positions.map((position) => (
              <PositionSection key={position.id} position={position} />
            ))}
          </div>
        ) : (
          <div className="bg-white border border-gray-200 rounded-lg p-12 text-center">
            <svg
              className="mx-auto h-12 w-12 text-gray-400 mb-4"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
              />
            </svg>
            <h3 className="text-lg font-medium text-gray-900 mb-2">
              No Positions Available
            </h3>
            <p className="text-gray-500">
              This election doesn&apos;t have any positions yet.
            </p>
          </div>
        )}

        {/* Voting Section (Placeholder for future implementation) */}
        {displayStatus === "Open" && !election.has_voted && (
          <div className="mt-8 bg-indigo-50 border border-indigo-200 rounded-lg p-6">
            <div className="flex items-center justify-between">
              <div>
                <h3 className="text-lg font-semibold text-indigo-900 mb-1">
                  Ready to Vote?
                </h3>
                <p className="text-sm text-indigo-700">
                  Cast your vote for the candidates you support.
                </p>
              </div>
              <button
                disabled
                className="px-6 py-3 bg-indigo-600 text-white rounded-lg font-medium hover:bg-indigo-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Vote Now
              </button>
            </div>
          </div>
        )}

      </div>
    </div>
  );
}
