"use client";

import { useState, useMemo } from "react";
import { useAllResults } from "@/hooks/useElections";
import Link from "next/link";
import dayjs from "dayjs";
import { motion } from "framer-motion";
import { Trophy, Calendar, Users, ArrowRight } from "lucide-react";
import { Pagination } from "@/components";

const ITEMS_PER_PAGE = 9; // 3 columns × 3 rows

export default function ResultsPage() {
  const [currentPage, setCurrentPage] = useState(1);
  const { data: results, isLoading, error } = useAllResults();

  // Paginate results
  const paginatedResults = useMemo(() => {
    if (!results) return [];
    const startIndex = (currentPage - 1) * ITEMS_PER_PAGE;
    const endIndex = startIndex + ITEMS_PER_PAGE;
    return results.slice(startIndex, endIndex);
  }, [results, currentPage]);

  const totalPages = Math.ceil((results?.length || 0) / ITEMS_PER_PAGE);

  return (
    <div className="h-full overflow-y-auto bg-gray-50">
      <div className="p-8 max-w-7xl mx-auto">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: -10 }}
          animate={{ opacity: 1, y: 0 }}
          className="mb-8"
        >
          <h1 className="text-3xl font-bold text-gray-900">Election Results</h1>
          <p className="text-gray-600 mt-2">
            View results from completed elections
          </p>
        </motion.div>

        {/* Loading State */}
        {isLoading && (
          <div className="flex items-center justify-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600"></div>
          </div>
        )}

        {/* Error State */}
        {error && (
          <div className="bg-red-50 border border-red-200 rounded-lg p-6 text-center">
            <p className="text-red-600 font-medium mb-2">
              Failed to load results
            </p>
            <p className="text-red-500 text-sm">
              {error instanceof Error ? error.message : "Please try again later."}
            </p>
            <button
              onClick={() => window.location.reload()}
              className="mt-4 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
            >
              Retry
            </button>
          </div>
        )}

        {/* Results List */}
        {!isLoading && !error && (
          <>
            {(!results || results.length === 0) ? (
              <div className="bg-white border border-gray-200 rounded-lg p-12 text-center">
                <Trophy className="mx-auto h-12 w-12 text-gray-400 mb-4" />
                <h3 className="text-lg font-medium text-gray-900 mb-2">
                  No Results Available
                </h3>
                <p className="text-gray-500">
                  Results will appear here once elections are closed.
                </p>
              </div>
            ) : (
              <>
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                  {paginatedResults.map((election) => (
                  <motion.div
                    key={election.id}
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ duration: 0.3 }}
                  >
                    <Link href={`/dashboard/results/${election.id}`}>
                      <div className="bg-white border border-gray-200 rounded-xl p-6 hover:shadow-lg transition-all duration-200 hover:border-indigo-300 h-full flex flex-col">
                        <div className="flex items-start justify-between mb-4">
                          <div className="flex-1">
                            <h3 className="text-lg font-semibold text-gray-900 mb-2 line-clamp-2">
                              {election.title}
                            </h3>
                            {election.description && (
                              <p className="text-sm text-gray-600 line-clamp-2 mb-4">
                                {election.description}
                              </p>
                            )}
                          </div>
                          <div className="ml-4 flex-shrink-0">
                            <div className="w-12 h-12 rounded-full bg-gradient-to-br from-indigo-500 to-purple-600 flex items-center justify-center">
                              <Trophy className="w-6 h-6 text-white" />
                            </div>
                          </div>
                        </div>

                        <div className="mt-auto space-y-3">
                          <div className="flex items-center gap-2 text-sm text-gray-600">
                            <Calendar className="w-4 h-4" />
                            <span>
                              Ended {dayjs(election.end_time).format("MMM D, YYYY")}
                            </span>
                          </div>
                          <div className="flex items-center gap-2 text-sm text-gray-600">
                            <Users className="w-4 h-4" />
                            <span>{election.total_votes} total votes</span>
                          </div>
                          <div className="pt-3 border-t border-gray-200">
                            <div className="flex items-center gap-2 text-indigo-600 font-medium text-sm">
                              <span>View Results</span>
                              <ArrowRight className="w-4 h-4" />
                            </div>
                          </div>
                        </div>
                      </div>
                    </Link>
                  </motion.div>
                  ))}
                </div>
                <Pagination
                  currentPage={currentPage}
                  totalPages={totalPages}
                  onPageChange={setCurrentPage}
                  itemsPerPage={ITEMS_PER_PAGE}
                  totalItems={results?.length}
                />
              </>
            )}
          </>
        )}
      </div>
    </div>
  );
}

