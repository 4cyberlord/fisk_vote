"use client";

import { useMemo, useState } from "react";
import { useMyVotes } from "@/hooks/useElections";
import dayjs from "dayjs";
import Link from "next/link";
import {
  ColumnDef,
  flexRender,
  getCoreRowModel,
  getSortedRowModel,
  getFilteredRowModel,
  getPaginationRowModel,
  useReactTable,
  SortingState,
} from "@tanstack/react-table";
import { Search, ChevronUp, ChevronDown, ChevronsUpDown, Eye } from "lucide-react";

type VoteEntry = NonNullable<ReturnType<typeof useMyVotes>["data"]>[number];

function VotesTable({ votes }: { votes: VoteEntry[] }) {
  const [sorting, setSorting] = useState<SortingState>([
    { id: "voted_at", desc: true },
  ]);
  const [globalFilter, setGlobalFilter] = useState("");

  const columns = useMemo<ColumnDef<VoteEntry>[]>(
    () => [
      {
        header: ({ column }) => (
          <button
            onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}
            className="flex items-center gap-1 hover:text-gray-900"
          >
            Election
            {column.getIsSorted() === "asc" ? (
              <ChevronUp className="w-4 h-4" />
            ) : column.getIsSorted() === "desc" ? (
              <ChevronDown className="w-4 h-4" />
            ) : (
              <ChevronsUpDown className="w-4 h-4 opacity-50" />
            )}
          </button>
        ),
        accessorKey: "election.title",
        cell: ({ row }) => (
          <div>
            <p className="font-medium text-gray-900">{row.original.election.title}</p>
            {row.original.election.description && (
              <p className="text-xs text-gray-500 line-clamp-1 mt-0.5">
                {row.original.election.description}
              </p>
            )}
          </div>
        ),
      },
      {
        header: ({ column }) => (
          <button
            onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}
            className="flex items-center gap-1 hover:text-gray-900"
          >
            Status
            {column.getIsSorted() === "asc" ? (
              <ChevronUp className="w-4 h-4" />
            ) : column.getIsSorted() === "desc" ? (
              <ChevronDown className="w-4 h-4" />
            ) : (
              <ChevronsUpDown className="w-4 h-4 opacity-50" />
            )}
          </button>
        ),
        accessorKey: "election.current_status",
        cell: ({ row }) => {
          const status = row.original.election.current_status;
          const statusColors: Record<string, string> = {
            Open: "bg-green-100 text-green-800 border-green-200",
            Closed: "bg-gray-100 text-gray-800 border-gray-200",
            Upcoming: "bg-blue-100 text-blue-800 border-blue-200",
          };
          return (
            <span
              className={`text-xs px-2 py-1 rounded-full border ${
                statusColors[status] || "bg-gray-100 text-gray-800 border-gray-200"
              }`}
            >
              {status}
            </span>
          );
        },
      },
      {
        header: ({ column }) => (
          <button
            onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}
            className="flex items-center gap-1 hover:text-gray-900"
          >
            Voted On
            {column.getIsSorted() === "asc" ? (
              <ChevronUp className="w-4 h-4" />
            ) : column.getIsSorted() === "desc" ? (
              <ChevronDown className="w-4 h-4" />
            ) : (
              <ChevronsUpDown className="w-4 h-4 opacity-50" />
            )}
          </button>
        ),
        accessorFn: (row) => new Date(row.voted_at).getTime(),
        id: "voted_at",
        cell: ({ row }) => (
          <div>
            <p className="text-sm text-gray-900">
              {dayjs(row.original.voted_at).format("MMM D, YYYY")}
            </p>
            <p className="text-xs text-gray-500">
              {dayjs(row.original.voted_at).format("h:mm A")}
            </p>
          </div>
        ),
      },
      {
        header: "Positions",
        accessorFn: (row) => row.positions.length,
        cell: ({ row }) => (
          <span className="text-sm text-gray-700">{row.original.positions.length}</span>
        ),
      },
      {
        header: "",
        id: "actions",
        cell: ({ row }) => (
          <Link
            href={`/dashboard/elections/${row.original.election.id}`}
            className="inline-flex items-center gap-1 text-indigo-600 hover:text-indigo-700 font-medium text-sm"
          >
            <Eye className="w-4 h-4" />
            View
          </Link>
        ),
      },
    ],
    []
  );

  const filteredData = useMemo(() => {
    if (!globalFilter) return votes;
    const searchLower = globalFilter.toLowerCase();
    return votes.filter(
      (v) =>
        v.election.title.toLowerCase().includes(searchLower) ||
        (v.election.description &&
          v.election.description.toLowerCase().includes(searchLower))
    );
  }, [votes, globalFilter]);

  const table = useReactTable({
    data: filteredData,
    columns,
    state: {
      sorting,
      globalFilter,
    },
    onSortingChange: setSorting,
    onGlobalFilterChange: setGlobalFilter,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
    initialState: {
      pagination: {
        pageSize: 10,
      },
    },
  });

  return (
    <div className="bg-white border border-gray-200 rounded-xl shadow-sm">
      <div className="px-6 py-4 border-b border-gray-200">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h2 className="text-lg font-semibold text-gray-900">Vote History (Table View)</h2>
            <p className="text-xs text-gray-500 mt-1">
              Sort and search through your voting history.
            </p>
          </div>
        </div>

        {/* Search */}
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
          <input
            type="text"
            placeholder="Search vote history..."
            value={globalFilter}
            onChange={(e) => setGlobalFilter(e.target.value)}
            className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 text-sm"
          />
        </div>
      </div>

      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-200 text-sm">
          <thead className="bg-gray-50">
            {table.getHeaderGroups().map((headerGroup) => (
              <tr key={headerGroup.id}>
                {headerGroup.headers.map((header) => (
                  <th
                    key={header.id}
                    className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wide"
                  >
                    {header.isPlaceholder
                      ? null
                      : flexRender(
                          header.column.columnDef.header,
                          header.getContext()
                        )}
                  </th>
                ))}
              </tr>
            ))}
          </thead>
          <tbody className="bg-white divide-y divide-gray-100">
            {table.getRowModel().rows.length === 0 ? (
              <tr>
                <td colSpan={columns.length} className="px-4 py-12 text-center text-gray-500">
                  No votes found matching your search.
                </td>
              </tr>
            ) : (
              table.getRowModel().rows.map((row) => (
                <tr key={row.id} className="hover:bg-indigo-50/50 transition-colors">
                  {row.getVisibleCells().map((cell) => (
                    <td key={cell.id} className="px-4 py-3">
                      {flexRender(cell.column.columnDef.cell, cell.getContext())}
                    </td>
                  ))}
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* Pagination */}
      {table.getPageCount() > 1 && (
        <div className="px-6 py-4 border-t border-gray-200 flex items-center justify-between">
          <div className="text-sm text-gray-700">
            Showing{" "}
            <span className="font-medium">
              {table.getState().pagination.pageIndex *
                table.getState().pagination.pageSize +
                1}
            </span>{" "}
            to{" "}
            <span className="font-medium">
              {Math.min(
                (table.getState().pagination.pageIndex + 1) *
                  table.getState().pagination.pageSize,
                table.getFilteredRowModel().rows.length
              )}
            </span>{" "}
            of <span className="font-medium">{table.getFilteredRowModel().rows.length}</span>{" "}
            results
          </div>
          <div className="flex items-center gap-2">
            <button
              onClick={() => table.previousPage()}
              disabled={!table.getCanPreviousPage()}
              className="px-3 py-1.5 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Previous
            </button>
            <span className="text-sm text-gray-700">
              Page {table.getState().pagination.pageIndex + 1} of {table.getPageCount()}
            </span>
            <button
              onClick={() => table.nextPage()}
              disabled={!table.getCanNextPage()}
              className="px-3 py-1.5 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Next
            </button>
          </div>
        </div>
      )}
    </div>
  );
}

export default function VoteHistoryPage() {
  const { data: votes, isLoading, error } = useMyVotes();

  return (
    <div className="h-full overflow-y-auto bg-gray-50">
      <div className="p-8 max-w-7xl mx-auto">
        <div className="mb-6 flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">My Votes</h1>
            <p className="text-gray-600 mt-2">
              A quick overview of the elections you&apos;ve participated in.
            </p>
          </div>
          <Link
            href="/dashboard/vote"
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
            Back to Cast Page
          </Link>
        </div>

        {isLoading ? (
          <div className="flex items-center justify-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600"></div>
          </div>
        ) : error ? (
          <div className="bg-red-50 border border-red-200 rounded-lg p-6 text-center">
            <h2 className="text-lg font-semibold text-red-900 mb-2">
              Unable to load your vote history
            </h2>
            <p className="text-red-700">
              {error instanceof Error
                ? error.message
                : "Something went wrong while fetching your votes."}
            </p>
          </div>
        ) : !votes || votes.length === 0 ? (
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
              No Votes Recorded Yet
            </h3>
            <p className="text-gray-500">
              Once you cast votes in elections, they will appear here for your reference.
            </p>
          </div>
        ) : (
          <>
            {/* Table View */}
            <div className="mb-6">
              <VotesTable votes={votes} />
            </div>

            {/* Card View */}
            <div className="space-y-6">
              <h2 className="text-xl font-semibold text-gray-900 mb-4">Detailed View</h2>
              {votes.map((entry) => (
              <div
                key={`${entry.election.id}-${entry.voted_at}`}
                className="bg-white border border-gray-200 rounded-lg shadow-sm p-6"
              >
                <div className="flex items-start justify-between gap-4 mb-4">
                  <div>
                    <h2 className="text-xl font-semibold text-gray-900">
                      {entry.election.title}
                    </h2>
                    <p className="text-gray-600 text-sm mt-1">
                      {entry.election.description || "No description provided."}
                    </p>
                    <p className="text-xs text-gray-500 mt-2">
                      Voted on{" "}
                      {entry.voted_at
                        ? dayjs(entry.voted_at).format("MMM D, YYYY [at] h:mm A")
                        : "--"}
                    </p>
                  </div>
                  <span
                    className={`px-3 py-1 rounded-full text-xs font-medium border ${
                      entry.election.current_status === "Open"
                        ? "bg-green-50 text-green-800 border-green-200"
                        : entry.election.current_status === "Closed"
                        ? "bg-gray-50 text-gray-800 border-gray-200"
                        : "bg-blue-50 text-blue-800 border-blue-200"
                    }`}
                  >
                    {entry.election.current_status}
                  </span>
                </div>

                <div className="mt-4 border-t border-gray-200 pt-4">
                  <h3 className="text-sm font-semibold text-gray-900 mb-3">
                    Your selections
                  </h3>

                  <div className="space-y-4">
                    {entry.positions.map((position) => {
                      const fieldKey = `position_${position.id}`;
                      const abstainKey = `${fieldKey}_abstain`;
                      const positionVote = entry.vote_data[fieldKey] as
                        | { candidate_id?: number; candidate_ids?: number[]; rankings?: Array<{ candidate_id: number; rank: number }> | Record<string, number> }
                        | undefined;
                      const abstained = Boolean(entry.vote_data[abstainKey]);

                      let content: JSX.Element;

                      if (abstained) {
                        content = (
                          <p className="text-sm text-gray-500 italic">
                            You chose to abstain from this position.
                          </p>
                        );
                      } else if (!positionVote) {
                        content = (
                          <p className="text-sm text-gray-500 italic">
                            No selection recorded for this position.
                          </p>
                        );
                      } else if (position.type === "single" && positionVote.candidate_id) {
                        const candidate = position.candidates.find(
                          (c) => c.id === positionVote.candidate_id
                        );

                        content = (
                          <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg">
                            <div className="h-8 w-8 rounded-full bg-indigo-600 flex items-center justify-center text-white text-xs font-semibold overflow-hidden">
                              {candidate?.user?.first_name?.[0] || "--"}
                              {candidate?.user?.last_name?.[0] || ""}
                            </div>
                            <div>
                              <p className="text-sm font-medium text-gray-900">
                                {candidate?.user?.name ||
                                  (candidate?.user?.first_name && candidate?.user?.last_name
                                    ? `${candidate.user.first_name} ${candidate.user.last_name}`
                                    : "Unknown candidate")}
                              </p>
                              {candidate?.tagline && (
                                <p className="text-xs text-gray-600">{candidate.tagline}</p>
                              )}
                            </div>
                          </div>
                        );
                      } else if (position.type === "multiple" && positionVote.candidate_ids) {
                        const ids = positionVote.candidate_ids;
                        const selectedCandidates = position.candidates.filter((c) =>
                          ids.includes(c.id)
                        );

                        content = selectedCandidates.length ? (
                          <div className="space-y-2">
                            {selectedCandidates.map((candidate) => (
                              <div
                                key={candidate.id}
                                className="flex items-center gap-3 p-2 bg-gray-50 rounded-lg"
                              >
                                <div className="h-7 w-7 rounded-full bg-indigo-600 flex items-center justify-center text-white text-xs font-semibold overflow-hidden">
                                  {candidate.user?.first_name?.[0] || "--"}
                                  {candidate.user?.last_name?.[0] || ""}
                                </div>
                                <p className="text-sm text-gray-900">
                                  {candidate.user?.name ||
                                    (candidate.user?.first_name && candidate.user?.last_name
                                      ? `${candidate.user.first_name} ${candidate.user.last_name}`
                                      : "Unknown candidate")}
                                </p>
                              </div>
                            ))}
                          </div>
                        ) : (
                          <p className="text-sm text-gray-500 italic">
                            No valid candidates found for this selection.
                          </p>
                        );
                      } else if (position.type === "ranked" && positionVote.rankings) {
                        const rankings = positionVote.rankings;
                        
                        // Handle both array format [{candidate_id, rank}, ...] and object format {candidate_id: rank}
                        let entriesRanked: Array<{ candidate_id: number; rank: number }>;
                        
                        if (Array.isArray(rankings)) {
                          // New format: array of objects
                          entriesRanked = rankings.sort((a, b) => a.rank - b.rank);
                        } else {
                          // Legacy format: object with candidate_id as key and rank as value
                          entriesRanked = Object.entries(rankings)
                            .map(([candidateId, rank]) => ({
                              candidate_id: parseInt(candidateId, 10),
                              rank: rank as number,
                            }))
                            .sort((a, b) => a.rank - b.rank);
                        }

                        content = entriesRanked.length > 0 ? (
                          <ol className="space-y-2 list-decimal list-inside">
                            {entriesRanked.map((entry) => {
                              const candidate = position.candidates.find((c) => c.id === entry.candidate_id);
                              return (
                                <li key={entry.candidate_id} className="text-sm text-gray-900">
                                  <span className="font-medium">
                                    {candidate?.user?.name ||
                                      (candidate?.user?.first_name && candidate?.user?.last_name
                                        ? `${candidate.user.first_name} ${candidate.user.last_name}`
                                        : "Unknown candidate")}
                                  </span>{" "}
                                  <span className="text-gray-500">(Rank {entry.rank})</span>
                                </li>
                              );
                            })}
                          </ol>
                        ) : (
                          <p className="text-sm text-gray-500 italic">
                            No rankings recorded for this position.
                          </p>
                        );
                      } else {
                        content = (
                          <p className="text-sm text-gray-500 italic">
                            Vote data for this position could not be interpreted.
                          </p>
                        );
                      }

                      return (
                        <div
                          key={position.id}
                          className="border border-gray-200 rounded-lg p-4 bg-gray-50"
                        >
                          <h4 className="text-sm font-semibold text-gray-900 mb-1">
                            {position.name}
                          </h4>
                          <p className="text-xs text-gray-500 mb-3">
                            {position.description || "No additional description."}
                          </p>
                          {content}
                        </div>
                      );
                    })}
                  </div>
                </div>
              </div>
            ))}
            </div>
          </>
        )}
      </div>
    </div>
  );
}


