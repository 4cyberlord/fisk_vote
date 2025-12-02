"use client";

import { useMemo, useState } from "react";
import { useAllElections } from "@/hooks/useElections";
import Link from "next/link";
import dayjs from "dayjs";
import relativeTime from "dayjs/plugin/relativeTime";
import customParseFormat from "dayjs/plugin/customParseFormat";
import {
  ColumnDef,
  flexRender,
  getCoreRowModel,
  getSortedRowModel,
  getFilteredRowModel,
  getPaginationRowModel,
  useReactTable,
  SortingState,
  ColumnFiltersState,
} from "@tanstack/react-table";
import { Search, ChevronUp, ChevronDown, ChevronsUpDown, Filter } from "lucide-react";
import * as DropdownMenuPrimitive from "@radix-ui/react-dropdown-menu";
import { Pagination } from "@/components";

// Extend dayjs with plugins
dayjs.extend(relativeTime);
dayjs.extend(customParseFormat);

const ACTIVE_STATUS_LIST_PER_PAGE = 5;

function ElectionsTable({ elections }: { elections: ReturnType<typeof useAllElections>["data"] }) {
  type ElectionRow = NonNullable<typeof elections>[number];
  const [sorting, setSorting] = useState<SortingState>([]);
  const [columnFilters, setColumnFilters] = useState<ColumnFiltersState>([]);
  const [globalFilter, setGlobalFilter] = useState("");
  const [statusFilter, setStatusFilter] = useState<string | null>(null);

  const data = useMemo(() => elections || [], [elections]);

  const columns = useMemo<ColumnDef<ElectionRow>[]>(
    () => [
      {
        header: ({ column }) => (
          <button
            onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}
            className="flex items-center gap-1 hover:text-gray-900"
          >
            Title
            {column.getIsSorted() === "asc" ? (
              <ChevronUp className="w-4 h-4" />
            ) : column.getIsSorted() === "desc" ? (
              <ChevronDown className="w-4 h-4" />
            ) : (
              <ChevronsUpDown className="w-4 h-4 opacity-50" />
            )}
          </button>
        ),
        accessorKey: "title",
        cell: (info) => (
          <Link
            href={`/dashboard/elections/${info.row.original.id}`}
            className="font-medium text-indigo-600 hover:text-indigo-700 line-clamp-1"
          >
            {info.getValue() as string}
          </Link>
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
        accessorKey: "current_status",
        cell: (info) => {
          const status = (info.getValue() as string) || "—";
          const statusColors: Record<string, string> = {
            Open: "bg-green-100 text-green-800 border-green-200",
            Upcoming: "bg-blue-100 text-blue-800 border-blue-200",
            Closed: "bg-gray-100 text-gray-800 border-gray-200",
            Active: "bg-green-100 text-green-800 border-green-200",
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
        filterFn: (row, id, value) => {
          if (!value) return true;
          return row.getValue(id) === value;
        },
      },
      {
        header: ({ column }) => (
          <button
            onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}
            className="flex items-center gap-1 hover:text-gray-900"
          >
            Type
            {column.getIsSorted() === "asc" ? (
              <ChevronUp className="w-4 h-4" />
            ) : column.getIsSorted() === "desc" ? (
              <ChevronDown className="w-4 h-4" />
            ) : (
              <ChevronsUpDown className="w-4 h-4 opacity-50" />
            )}
          </button>
        ),
        accessorKey: "type",
        cell: (info) => (
          <span className="text-xs capitalize text-gray-700">
            {(info.getValue() as string) || "—"}
          </span>
        ),
      },
      {
        header: ({ column }) => (
          <button
            onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}
            className="flex items-center gap-1 hover:text-gray-900"
          >
            Start Date
            {column.getIsSorted() === "asc" ? (
              <ChevronUp className="w-4 h-4" />
            ) : column.getIsSorted() === "desc" ? (
              <ChevronDown className="w-4 h-4" />
            ) : (
              <ChevronsUpDown className="w-4 h-4 opacity-50" />
            )}
          </button>
        ),
        accessorFn: (row) => new Date(row.start_time).getTime(),
        id: "start_time",
        cell: ({ row }) => (
          <span className="text-xs text-gray-600">
            {dayjs(row.original.start_time).format("MMM D, YYYY")}
          </span>
        ),
      },
      {
        header: "Positions",
        accessorKey: "positions_count",
        cell: (info) => (
          <span className="text-sm text-gray-700">{info.getValue() as number}</span>
        ),
      },
      {
        header: "Candidates",
        accessorKey: "candidates_count",
        cell: (info) => (
          <span className="text-sm text-gray-700">{info.getValue() as number}</span>
        ),
      },
      {
        header: "",
        id: "actions",
        cell: ({ row }) => (
          <Link
            href={`/dashboard/elections/${row.original.id}`}
            className="text-indigo-600 hover:text-indigo-700 font-medium text-sm"
          >
            View →
          </Link>
        ),
      },
    ],
    []
  );

  const filteredData = useMemo(() => {
    let filtered = data;
    if (statusFilter) {
      filtered = filtered.filter((e) => e.current_status === statusFilter);
    }
    if (globalFilter) {
      const searchLower = globalFilter.toLowerCase();
      filtered = filtered.filter(
        (e) =>
          e.title.toLowerCase().includes(searchLower) ||
          (e.description && e.description.toLowerCase().includes(searchLower)) ||
          e.type.toLowerCase().includes(searchLower)
      );
    }
    return filtered;
  }, [data, statusFilter, globalFilter]);

  const table = useReactTable({
    data: filteredData,
    columns,
    state: {
      sorting,
      columnFilters,
      globalFilter,
    },
    onSortingChange: setSorting,
    onColumnFiltersChange: setColumnFilters,
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

  const statusOptions = ["Open", "Upcoming", "Closed"];

  return (
    <div className="mt-10 bg-white border border-gray-200 rounded-xl shadow-sm">
      <div className="px-6 py-4 border-b border-gray-200">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h2 className="text-lg font-semibold text-gray-900">
              All elections (table view)
            </h2>
            <p className="text-xs text-gray-500 mt-1">
              Sort, filter, and search elections in a compact view.
            </p>
          </div>
        </div>

        {/* Search and Filter Bar */}
        <div className="flex flex-col sm:flex-row gap-3">
          {/* Search */}
          <div className="flex-1 relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
            <input
              type="text"
              placeholder="Search elections..."
              value={globalFilter}
              onChange={(e) => setGlobalFilter(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 text-sm text-gray-900 bg-white placeholder:text-gray-400"
            />
          </div>

          {/* Status Filter Dropdown */}
          <DropdownMenuPrimitive.Root>
            <DropdownMenuPrimitive.Trigger asChild>
              <button className="inline-flex items-center gap-2 px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 text-sm font-medium text-gray-700">
                <Filter className="w-4 h-4" />
                {statusFilter ? `Status: ${statusFilter}` : "Filter by Status"}
              </button>
            </DropdownMenuPrimitive.Trigger>
            <DropdownMenuPrimitive.Portal>
              <DropdownMenuPrimitive.Content className="bg-white border border-gray-200 rounded-lg shadow-lg p-1 min-w-[180px] z-50">
                <DropdownMenuPrimitive.Item
                  className="px-3 py-2 text-sm text-gray-700 hover:bg-gray-100 rounded cursor-pointer"
                  onClick={() => setStatusFilter(null)}
                >
                  All Statuses
                </DropdownMenuPrimitive.Item>
                <DropdownMenuPrimitive.Separator className="h-px bg-gray-200 my-1" />
                {statusOptions.map((status) => (
                  <DropdownMenuPrimitive.Item
                    key={status}
                    className="px-3 py-2 text-sm text-gray-700 hover:bg-gray-100 rounded cursor-pointer"
                    onClick={() => setStatusFilter(status)}
                  >
                    {status}
                  </DropdownMenuPrimitive.Item>
                ))}
              </DropdownMenuPrimitive.Content>
            </DropdownMenuPrimitive.Portal>
          </DropdownMenuPrimitive.Root>

          {statusFilter && (
            <button
              onClick={() => setStatusFilter(null)}
              className="px-3 py-2 text-sm text-gray-600 hover:text-gray-900"
            >
              Clear filter
            </button>
          )}
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
                <td
                  colSpan={columns.length}
                  className="px-4 py-12 text-center text-gray-500"
                >
                  No elections found matching your criteria.
                </td>
              </tr>
            ) : (
              table.getRowModel().rows.map((row) => (
                <tr
                  key={row.id}
                  className="hover:bg-indigo-50/50 transition-colors"
                >
                  {row.getVisibleCells().map((cell) => (
                    <td key={cell.id} className="px-4 py-3 whitespace-nowrap">
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
              {table.getState().pagination.pageIndex * table.getState().pagination.pageSize + 1}
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

export default function ElectionsPage() {
  const { data: elections, isLoading, error } = useAllElections();
  const [globalFilter, setGlobalFilter] = useState("");
  const [activeStatusPage, setActiveStatusPage] = useState(1);
  const [closedStatusPage, setClosedStatusPage] = useState(1);

  // Filter elections based on search
  const filteredElections = useMemo(() => {
    if (!elections) return [];
    if (!globalFilter) return elections;
    const searchLower = globalFilter.toLowerCase();
    return elections.filter(
      (e) =>
        e.title.toLowerCase().includes(searchLower) ||
        (e.description && e.description.toLowerCase().includes(searchLower)) ||
        e.type.toLowerCase().includes(searchLower) ||
        (e.current_status && e.current_status.toLowerCase().includes(searchLower))
    );
  }, [elections, globalFilter]);

  // Group elections by status
  const groupedElections = filteredElections.reduce(
    (acc, election) => {
      const status = election.current_status || election.status || "Unknown";
      if (!acc[status]) {
        acc[status] = [];
      }
      acc[status].push(election);
      return acc;
    },
    {} as Record<string, typeof filteredElections>
  );

  const statusOrder = ["Open", "Upcoming", "Closed", "Active", "Unknown"];
  const statusLabels: Record<string, string> = {
    Open: "Active Elections",
    Upcoming: "Upcoming Elections",
    Closed: "Closed Elections",
    Active: "Active Elections",
    Unknown: "Other Elections",
  };

  const getStatusBadgeColor = (status: string) => {
    switch (status) {
      case "Open":
        return "bg-green-100 text-green-800 border-green-200";
      case "Upcoming":
        return "bg-blue-100 text-blue-800 border-blue-200";
      case "Closed":
        return "bg-gray-100 text-gray-800 border-gray-200";
      case "Active":
        return "bg-green-100 text-green-800 border-green-200";
      default:
        return "bg-gray-100 text-gray-800 border-gray-200";
    }
  };

  const getStatusBadge = (status: string) => {
    const colorClass = getStatusBadgeColor(status);
    return (
      <span
        className={`px-3 py-1 rounded-full text-xs font-medium border ${colorClass}`}
      >
        {status}
      </span>
    );
  };

  return (
    <div className="p-8">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-3xl font-bold text-gray-900">Elections</h1>
              <p className="text-gray-600 mt-2">
                View all elections you are eligible to participate in
              </p>
            </div>
            <div className="relative w-64">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
              <input
                type="text"
                placeholder="Search elections..."
                value={globalFilter}
                onChange={(e) => {
                  setGlobalFilter(e.target.value);
                  setActiveStatusPage(1);
                  setClosedStatusPage(1);
                }}
                className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 text-sm text-gray-900 bg-white placeholder:text-gray-400"
              />
            </div>
          </div>
        </div>

        {/* Loading State */}
        {isLoading && (
          <div className="text-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600 mx-auto"></div>
            <p className="text-gray-500 mt-4">Loading elections...</p>
          </div>
        )}

        {/* Error State */}
        {error && (
          <div className="bg-red-50 border border-red-200 rounded-lg p-6 text-center">
            <p className="text-red-600">
              Failed to load elections. Please try again later.
            </p>
          </div>
        )}

        {/* Elections List */}
        {!isLoading && !error && elections && (
          <>
            {filteredElections.length === 0 ? (
              <div className="bg-white border border-gray-200 rounded-lg p-12 text-center">
                <Search className="mx-auto h-12 w-12 text-gray-400 mb-4" />
                <h3 className="mt-4 text-lg font-medium text-gray-900">
                  {globalFilter ? "No elections found" : "No elections available"}
                </h3>
                <p className="mt-2 text-sm text-gray-500">
                  {globalFilter
                    ? "Try adjusting your search terms."
                    : "There are no elections available at this time."}
                </p>
                {globalFilter && (
                  <button
                    onClick={() => setGlobalFilter("")}
                    className="mt-4 text-sm text-indigo-600 hover:text-indigo-700"
                  >
                    Clear search
                  </button>
                )}
              </div>
            ) : (
              <div className="space-y-8">
                {statusOrder.map((status) => {
                  const statusElections = groupedElections[status];
                  if (!statusElections || statusElections.length === 0) {
                    return null;
                  }

                  const label = statusLabels[status] || status;
                  const isActiveGroup = label === "Active Elections";
                  const isClosedGroup = label === "Closed Elections";
                  const usesPagination = isActiveGroup || isClosedGroup;

                  const totalPages = usesPagination
                    ? Math.max(1, Math.ceil(statusElections.length / ACTIVE_STATUS_LIST_PER_PAGE))
                    : 1;

                  const currentPage = isActiveGroup
                    ? activeStatusPage
                    : isClosedGroup
                    ? closedStatusPage
                    : 1;

                  const safePage = usesPagination
                    ? Math.min(currentPage, totalPages)
                    : 1;

                  const startIndex = (safePage - 1) * ACTIVE_STATUS_LIST_PER_PAGE;
                  const endIndex = startIndex + ACTIVE_STATUS_LIST_PER_PAGE;

                  const visibleElections = usesPagination
                    ? statusElections.slice(startIndex, endIndex)
                    : statusElections;

                  return (
                    <div key={status}>
                      <h2 className="text-xl font-semibold text-gray-900 mb-4">
                        {label} ({statusElections.length})
                      </h2>
                      <div className="space-y-4">
                        {visibleElections.map((election) => (
                          <Link
                            key={election.id}
                            href={`/dashboard/elections/${election.id}`}
                            className="block"
                          >
                            <div className="bg-white border border-gray-200 rounded-lg p-6 hover:shadow-md transition-all duration-200 hover:border-indigo-300">
                              <div className="flex items-start justify-between">
                                <div className="flex-1">
                                  <div className="flex items-center gap-3 mb-2">
                                    <h3 className="text-lg font-semibold text-gray-900">
                                      {election.title}
                                    </h3>
                                    {getStatusBadge(
                                      election.current_status || election.status || "Unknown"
                                    )}
                                    {election.has_voted && (
                                      <span className="px-2 py-1 rounded text-xs font-medium bg-indigo-100 text-indigo-800">
                                        Voted
                                      </span>
                                    )}
                                  </div>
                                  {election.description && (
                                    <p className="text-gray-600 text-sm mb-4 line-clamp-2">
                                      {election.description}
                                    </p>
                                  )}
                                  <div className="flex items-center gap-6 text-sm text-gray-500">
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
                                        {dayjs(election.start_time).format("MMM D, YYYY")} -{" "}
                                        {dayjs(election.end_time).format("MMM D, YYYY")}
                                      </span>
                                    </div>
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
                                          d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                                        />
                                      </svg>
                                      <span>{election.positions_count} positions</span>
                                    </div>
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
                                          d="M17 20h5v-2a3 3 0 00-3-3h-4m-4 5H3v-2a3 3 0 013-3h4m0-14v4m0 0l-3-3m3 3l3-3"
                                        />
                                      </svg>
                                      <span>{election.candidates_count} candidates</span>
                                    </div>
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
                                          d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"
                                        />
                                      </svg>
                                      <span className="capitalize">{election.type}</span>
                                    </div>
                                  </div>
                                </div>
                                <div className="ml-4">
                                  <svg
                                    className="w-5 h-5 text-gray-400"
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
                                </div>
                              </div>
                            </div>
                          </Link>
                        ))}
                      </div>
                      {usesPagination && totalPages > 1 && (
                        <div className="mt-4">
                          <Pagination
                            currentPage={safePage}
                            totalPages={totalPages}
                            onPageChange={isActiveGroup ? setActiveStatusPage : setClosedStatusPage}
                            itemsPerPage={ACTIVE_STATUS_LIST_PER_PAGE}
                            totalItems={statusElections.length}
                          />
                        </div>
                      )}
                    </div>
                  );
                })}
              </div>
            )}

            {/* Advanced table view */}
            {filteredElections.length > 0 && <ElectionsTable elections={filteredElections} />}
          </>
        )}
      </div>
    </div>
  );
}

