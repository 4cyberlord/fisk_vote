"use client";

import { useState, useMemo, useEffect } from "react";
import { useActiveElections } from "@/hooks/useElections";
import Link from "next/link";
import dayjs from "dayjs";
import { Pagination } from "@/components";

const ITEMS_PER_PAGE = 9; // 3 columns × 3 rows

export default function VotePage() {
  const [currentPage, setCurrentPage] = useState(1);
  const {
    data: activeElections,
    isLoading: isLoadingActiveElections,
    error: activeElectionsError,
  } = useActiveElections();

  // Paginate elections
  const paginatedElections = useMemo(() => {
    if (!activeElections) return [];
    const startIndex = (currentPage - 1) * ITEMS_PER_PAGE;
    const endIndex = startIndex + ITEMS_PER_PAGE;
    return activeElections.slice(startIndex, endIndex);
  }, [activeElections, currentPage]);

  const totalPages = Math.ceil((activeElections?.length || 0) / ITEMS_PER_PAGE);

  // Reset to page 1 when elections change and current page is out of bounds
  useEffect(() => {
    if (currentPage > totalPages && totalPages > 0) {
      setCurrentPage(1);
    }
  }, [totalPages, currentPage]);

  return (
    <div className="h-full overflow-y-auto bg-gray-50">
      <div className="p-8 max-w-7xl mx-auto">
        <div className="mb-8 flex items-center justify-between gap-4">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">Cast Your Vote</h1>
            <p className="text-gray-600 mt-2">
              Select an election to cast your vote.
            </p>
          </div>
          <Link
            href="/dashboard/vote/history"
            className="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-indigo-700 bg-indigo-50 border border-indigo-200 rounded-lg hover:bg-indigo-100 hover:border-indigo-300 transition-all duration-200"
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
                d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"
              />
            </svg>
            My vote history
          </Link>
        </div>

        {isLoadingActiveElections ? (
          <div className="flex items-center justify-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600"></div>
          </div>
        ) : activeElectionsError ? (
          <div className="bg-red-50 border border-red-200 rounded-lg p-6 text-center">
            <p className="text-red-600">Failed to load active elections.</p>
          </div>
        ) : activeElections && activeElections.length > 0 ? (
          <>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {paginatedElections.map((election) => (
              <Link
                href={`/dashboard/vote/${election.id}`}
                key={election.id}
                className="block bg-white border border-gray-200 rounded-lg p-6 hover:shadow-lg transition-all hover:border-indigo-300"
              >
                <div className="flex items-center justify-between mb-3">
                  <h3 className="text-lg font-semibold text-gray-900 truncate flex-1">
                    {election.title}
                  </h3>
                  <span className="px-3 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800 border border-green-200 ml-2">
                    {election.current_status}
                  </span>
                </div>
                {election.description && (
                  <p className="text-gray-600 text-sm mb-4 line-clamp-2">
                    {election.description}
                  </p>
                )}
                <div className="flex items-center gap-4 text-sm text-gray-500">
                  <div className="flex items-center gap-1">
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
                        d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"
                      />
                    </svg>
                    <span>
                      {dayjs(election.start_time).format("MMM D")} -{" "}
                      {dayjs(election.end_time).format("MMM D, YYYY")}
                    </span>
                  </div>
                </div>
                {election.has_voted && (
                  <div className="mt-4 pt-4 border-t border-gray-200">
                    <span className="inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-medium bg-indigo-100 text-indigo-800">
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
                      Already Voted
                    </span>
                  </div>
                )}
              </Link>
              ))}
            </div>
            <Pagination
              currentPage={currentPage}
              totalPages={totalPages}
              onPageChange={setCurrentPage}
              itemsPerPage={ITEMS_PER_PAGE}
              totalItems={activeElections.length}
            />
          </>
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
                d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
              />
            </svg>
            <h3 className="text-lg font-medium text-gray-900 mb-2">
              No Active Elections
            </h3>
            <p className="text-gray-500">
              There are no active elections available for voting at this time.
            </p>
          </div>
        )}
      </div>
    </div>
  );
}

