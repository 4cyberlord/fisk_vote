"use client";

import { useState, useMemo } from "react";
import { Calendar } from "primereact/calendar";
import type { CalendarDateTemplateEvent } from "primereact/calendar";
import { useCalendarEvents, type CalendarEvent } from "@/hooks/useCalendarEvents";
import { Calendar as CalendarIcon, Clock, CheckCircle2, XCircle, CalendarDays } from "lucide-react";
import dayjs, { formatDate } from "@/lib/dayjs";
import Link from "next/link";
import { Pagination } from "@/components";

const EVENTS_PER_PAGE = 5;
const AGENDA_EVENTS_PER_PAGE = 5;

export default function CalendarPage() {
  const [selectedDate, setSelectedDate] = useState<Date | null>(new Date());
  const [eventsPage, setEventsPage] = useState(1);
  const [agendaPage, setAgendaPage] = useState(1);
  const [viewMode, setViewMode] = useState<"month" | "agenda">("month");

  // Calculate date range for API (3 months before and after current date)
  const startDate = useMemo(() => {
    const baseDate = selectedDate || new Date();
    return dayjs(baseDate).subtract(3, "months").startOf("month").format("YYYY-MM-DD");
  }, [selectedDate]);

  const endDate = useMemo(() => {
    const baseDate = selectedDate || new Date();
    return dayjs(baseDate).add(3, "months").endOf("month").format("YYYY-MM-DD");
  }, [selectedDate]);

  const { data: eventsData, isLoading } = useCalendarEvents({
    start_date: startDate,
    end_date: endDate,
  });

  const events = useMemo(() => eventsData?.data || [], [eventsData?.data]);

  // Group events by date
  const eventsByDate = useMemo(() => {
    const grouped: Record<string, CalendarEvent[]> = {};
    events.forEach((event) => {
      const startDate = dayjs(event.start).format("YYYY-MM-DD");
      const endDate = dayjs(event.end).format("YYYY-MM-DD");
      
      let currentDate = dayjs(startDate);
      const end = dayjs(endDate);
      
      while (currentDate.isBefore(end, "day") || currentDate.isSame(end, "day")) {
        const dateKey = currentDate.format("YYYY-MM-DD");
        if (!grouped[dateKey]) {
          grouped[dateKey] = [];
        }
        grouped[dateKey].push(event);
        currentDate = currentDate.add(1, "day");
      }
    });
    return grouped;
  }, [events]);

  // Get events for selected date
  const selectedDateEvents = useMemo(() => {
    if (!selectedDate) return [];
    const dateKey = dayjs(selectedDate).format("YYYY-MM-DD");
    return eventsByDate[dateKey] || [];
  }, [selectedDate, eventsByDate]);

  // Paginate selected date events
  const paginatedSelectedDateEvents = useMemo(() => {
    const startIndex = (eventsPage - 1) * EVENTS_PER_PAGE;
    const endIndex = startIndex + EVENTS_PER_PAGE;
    return selectedDateEvents.slice(startIndex, endIndex);
  }, [selectedDateEvents, eventsPage]);

  const totalEventsPages = Math.ceil(selectedDateEvents.length / EVENTS_PER_PAGE);


  const getEventColor = (event: CalendarEvent) => {
    const colorMap: Record<string, string> = {
      green: "bg-emerald-500",
      indigo: "bg-blue-500",
      blue: "bg-cyan-500",
      gray: "bg-slate-500",
    };
    return colorMap[event.color] || colorMap.blue;
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case "Open":
        return <CheckCircle2 className="w-4 h-4 text-emerald-600" />;
      case "Upcoming":
        return <Clock className="w-4 h-4 text-blue-600" />;
      case "Closed":
        return <XCircle className="w-4 h-4 text-slate-500" />;
      default:
        return <CalendarIcon className="w-4 h-4 text-gray-600" />;
    }
  };

  // Get upcoming events for agenda view
  const upcomingEvents = useMemo(() => {
    return events
      .filter((e) => e.status === "Upcoming" || e.status === "Open")
      .sort((a, b) => dayjs(a.start).valueOf() - dayjs(b.start).valueOf());
  }, [events]);

  const totalAgendaPages = Math.max(1, Math.ceil(upcomingEvents.length / AGENDA_EVENTS_PER_PAGE));

  const effectiveAgendaPage = Math.min(agendaPage, totalAgendaPages);

  const paginatedAgendaEvents = useMemo(() => {
    const startIndex = (effectiveAgendaPage - 1) * AGENDA_EVENTS_PER_PAGE;
    const endIndex = startIndex + AGENDA_EVENTS_PER_PAGE;
    return upcomingEvents.slice(startIndex, endIndex);
  }, [upcomingEvents, effectiveAgendaPage]);

  const handleViewModeChange = (mode: "month" | "agenda") => {
    setViewMode(mode);
    if (mode === "agenda") {
      setAgendaPage(1);
    }
  };

  return (
    <div className="h-full overflow-y-auto bg-gradient-to-br from-slate-50 via-white to-slate-50">
      <div className="p-8 max-w-7xl mx-auto space-y-8">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-4xl font-extrabold text-slate-900 tracking-tight">Calendar</h1>
            <p className="text-slate-600 mt-2 text-lg">
              Manage and view all your elections and events
            </p>
          </div>
          <div className="flex items-center gap-3">
            <button
              onClick={() => handleViewModeChange("month")}
              className={`px-4 py-2 rounded-xl font-semibold transition-all ${
                viewMode === "month"
                  ? "bg-slate-900 text-white shadow-lg"
                  : "bg-white text-slate-700 border-2 border-slate-200 hover:border-slate-300"
              }`}
            >
              <CalendarDays className="w-4 h-4 inline mr-2" />
              Month
            </button>
            <button
              onClick={() => handleViewModeChange("agenda")}
              className={`px-4 py-2 rounded-xl font-semibold transition-all ${
                viewMode === "agenda"
                  ? "bg-slate-900 text-white shadow-lg"
                  : "bg-white text-slate-700 border-2 border-slate-200 hover:border-slate-300"
              }`}
            >
              <Clock className="w-4 h-4 inline mr-2" />
              Agenda
            </button>
          </div>
        </div>

        {viewMode === "month" ? (
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
            {/* PrimeReact Calendar */}
            <div className="lg:col-span-2">
              <div className="bg-white rounded-xl border border-gray-200 shadow-lg overflow-hidden">
                <div className="p-6">
                  {isLoading ? (
                    <div className="flex items-center justify-center h-64">
                      <div className="animate-spin rounded-full h-8 w-8 border-2 border-gray-200 border-t-indigo-600"></div>
                    </div>
                  ) : (
                    <Calendar
                      value={selectedDate}
                      onChange={(e) => {
                        if (e.value) {
                          setSelectedDate(e.value as Date);
                          setEventsPage(1);
                        }
                      }}
                      inline
                      showButtonBar
                      dateTemplate={(event: CalendarDateTemplateEvent) => {
                        // Construct date from event properties
                        const date = new Date(event.year, event.month, event.day);
                        const dateKey = dayjs(date).format("YYYY-MM-DD");
                        const hasEvents = eventsByDate[dateKey] && eventsByDate[dateKey].length > 0;
                        const isSelected = selectedDate && dayjs(date).isSame(selectedDate, "day");
                        const isToday = dayjs(date).isSame(new Date(), "day");
                        
                        const baseHover =
                          !isSelected && !isToday ? "hover:bg-slate-100 hover:text-slate-900" : "";

                        return (
                          <div
                            className={`w-9 h-9 flex flex-col items-center justify-center relative transition-all rounded-lg ${baseHover} ${
                              isSelected
                                ? "bg-slate-900 text-white shadow-lg"
                                : isToday
                                ? "bg-emerald-100 text-emerald-800 border-2 border-emerald-500 font-bold"
                                : "text-slate-700"
                            }`}
                            style={{
                              backgroundColor: isSelected
                                ? "rgb(15, 23, 42)"
                                : isToday
                                ? "rgb(209, 250, 229)"
                                : undefined,
                            }}
                          >
                            <span className={`text-sm ${isSelected || isToday ? "font-bold" : "font-medium"}`}>
                              {event.day}
                            </span>
                            {hasEvents && (
                              <div
                                className="absolute bottom-0.5 left-1/2 -translate-x-1/2 w-1 h-1 rounded-full"
                                style={{
                                  backgroundColor: isSelected
                                    ? "white"
                                    : isToday
                                    ? "rgb(4, 120, 87)"
                                    : "rgb(71, 85, 105)",
                                }}
                              />
                            )}
                          </div>
                        );
                      }}
                      className="w-full"
                      style={{ width: "100%" }}
                    />
                  )}
                </div>
              </div>

              {/* Selected Date Events */}
              {selectedDate && (
                <div className="mt-6 bg-white rounded-3xl shadow-2xl border border-slate-200 overflow-hidden">
                  <div className="bg-gradient-to-r from-slate-50 to-white px-6 py-5 border-b border-slate-200">
                    <div className="flex items-center justify-between">
                      <div>
                        <h3 className="text-xl font-bold text-slate-900">
                          {dayjs(selectedDate).format("MMMM D, YYYY")}
                        </h3>
                        <p className="text-slate-600 text-sm mt-1">
                          {dayjs(selectedDate).format("dddd")}
                        </p>
                      </div>
                      {selectedDateEvents.length > 0 && (
                        <span className="px-4 py-2 bg-slate-900 text-white rounded-xl font-bold text-sm">
                          {selectedDateEvents.length} {selectedDateEvents.length === 1 ? "Event" : "Events"}
                        </span>
                      )}
                    </div>
                  </div>
                  <div className="p-6">
                    {selectedDateEvents.length > 0 ? (
                      <>
                        <div className="space-y-4">
                          {paginatedSelectedDateEvents.map((event) => (
                            <Link
                              key={event.id}
                              href={`/dashboard/elections/${event.id}`}
                              className="block group"
                            >
                              <div className="flex items-start gap-4 p-4 rounded-2xl border-2 border-slate-200 hover:border-slate-900 hover:shadow-xl transition-all bg-white">
                                <div className={`w-1 h-full min-h-[60px] rounded-full ${getEventColor(event)}`}></div>
                                <div className="flex-1">
                                  <div className="flex items-start justify-between gap-3 mb-2">
                                    <div className="flex items-center gap-2">
                                      {getStatusIcon(event.status)}
                                      <h4 className="font-bold text-slate-900 text-lg group-hover:text-slate-700">
                                        {event.title}
                                      </h4>
                                    </div>
                                    <span className={`px-3 py-1 rounded-full text-xs font-bold ${
                                      event.status === "Open" ? "bg-emerald-100 text-emerald-700" :
                                      event.status === "Upcoming" ? "bg-blue-100 text-blue-700" :
                                      "bg-slate-100 text-slate-700"
                                    }`}>
                                      {event.status}
                                    </span>
                                  </div>
                                  {event.description && (
                                    <p className="text-slate-600 text-sm mb-3 line-clamp-2">
                                      {event.description}
                                    </p>
                                  )}
                                  <div className="flex items-center gap-4 flex-wrap">
                                    <span className="flex items-center gap-2 text-sm font-medium text-slate-700">
                                      <Clock className="w-4 h-4 text-slate-500" />
                                      {event.start_time} - {event.end_time}
                                    </span>
                                    {event.is_eligible && (
                                      <span className="px-3 py-1 bg-emerald-50 text-emerald-700 rounded-lg text-xs font-bold">
                                        Eligible
                                      </span>
                                    )}
                                    {event.has_voted && (
                                      <span className="px-3 py-1 bg-blue-50 text-blue-700 rounded-lg text-xs font-bold">
                                        Voted
                                      </span>
                                    )}
                                  </div>
                                </div>
                              </div>
                            </Link>
                          ))}
                        </div>
                        {totalEventsPages > 1 && (
                          <div className="mt-6 pt-6 border-t border-slate-200">
                            <Pagination
                              currentPage={eventsPage}
                              totalPages={totalEventsPages}
                              onPageChange={setEventsPage}
                              totalItems={selectedDateEvents.length}
                              itemsPerPage={EVENTS_PER_PAGE}
                            />
                          </div>
                        )}
                      </>
                    ) : (
                      <div className="text-center py-12">
                        <CalendarIcon className="w-16 h-16 text-slate-300 mx-auto mb-4" />
                        <p className="text-slate-600 font-semibold text-lg">
                          No events scheduled for this date
                        </p>
                      </div>
                    )}
                  </div>
                </div>
              )}
            </div>

            {/* Sidebar */}
            <div className="space-y-6">
              {/* Quick Stats */}
              <div className="bg-white rounded-3xl shadow-2xl border border-slate-200 p-6">
                <h3 className="text-lg font-bold text-slate-900 mb-4">Quick Stats</h3>
                <div className="space-y-4">
                  <div className="flex justify-between items-center p-3 bg-slate-50 rounded-xl">
                    <span className="text-slate-700 font-medium">Total Events</span>
                    <span className="text-2xl font-bold text-slate-900">
                      {eventsData?.meta.total_events || 0}
                    </span>
                  </div>
                  <div className="flex justify-between items-center p-3 bg-blue-50 rounded-xl">
                    <span className="text-blue-700 font-medium">Upcoming</span>
                    <span className="text-2xl font-bold text-blue-700">
                      {events.filter((e) => e.status === "Upcoming").length}
                    </span>
                  </div>
                  <div className="flex justify-between items-center p-3 bg-emerald-50 rounded-xl">
                    <span className="text-emerald-700 font-medium">Open</span>
                    <span className="text-2xl font-bold text-emerald-700">
                      {events.filter((e) => e.status === "Open").length}
                    </span>
                  </div>
                  <div className="flex justify-between items-center p-3 bg-slate-50 rounded-xl">
                    <span className="text-slate-700 font-medium">Closed</span>
                    <span className="text-2xl font-bold text-slate-700">
                      {events.filter((e) => e.status === "Closed").length}
                    </span>
                  </div>
                </div>
              </div>

              {/* Upcoming Events */}
              <div className="bg-white rounded-3xl shadow-2xl border border-slate-200 p-6">
                <h3 className="text-lg font-bold text-slate-900 mb-4">Upcoming</h3>
                {isLoading ? (
                  <div className="flex items-center justify-center py-8">
                    <div className="animate-spin rounded-full h-6 w-6 border-2 border-slate-200 border-t-slate-900"></div>
                  </div>
                ) : upcomingEvents.length > 0 ? (
                  <div className="space-y-3">
                    {upcomingEvents.slice(0, 5).map((event) => (
                      <Link
                        key={event.id}
                        href={`/dashboard/elections/${event.id}`}
                        className="block p-3 rounded-xl border-2 border-slate-200 hover:border-slate-900 hover:shadow-lg transition-all bg-white"
                      >
                        <div className="flex items-start gap-3">
                          <div className={`w-1 h-full min-h-[40px] rounded-full ${getEventColor(event)}`}></div>
                          <div className="flex-1 min-w-0">
                            <p className="font-bold text-slate-900 text-sm truncate">
                              {event.title}
                            </p>
                            <p className="text-xs text-slate-600 mt-1">
                              {formatDate(event.start, "MMM D")} • {event.start_time}
                            </p>
                          </div>
                        </div>
                      </Link>
                    ))}
                  </div>
                ) : (
                  <p className="text-sm text-slate-600 text-center py-4 font-medium">
                    No upcoming events
                  </p>
                )}
              </div>
            </div>
          </div>
        ) : (
          /* Agenda View */
          <div className="bg-white/90 rounded-3xl shadow-xl border border-slate-100 overflow-hidden">
            <div className="bg-gradient-to-r from-slate-200 to-slate-100 px-8 py-6">
              <h2 className="text-2xl font-bold text-slate-800">Event Agenda</h2>
              <p className="text-slate-500 text-sm mt-1">All upcoming and active events</p>
            </div>
            <div className="p-6">
              {isLoading ? (
                <div className="flex items-center justify-center py-12">
                  <div className="animate-spin rounded-full h-12 w-12 border-4 border-slate-200 border-t-slate-900"></div>
                </div>
              ) : upcomingEvents.length > 0 ? (
                <>
                  <div className="space-y-4">
                    {paginatedAgendaEvents.map((event) => (
                    <Link
                      key={event.id}
                      href={`/dashboard/elections/${event.id}`}
                      className="block group"
                    >
                      <div className="flex items-start gap-6 p-6 rounded-2xl border border-slate-100 hover:border-slate-400 hover:shadow-lg transition-all bg-white/90">
                        <div className="flex-shrink-0">
                          <div
                            className={`w-16 h-16 rounded-2xl ${getEventColor(event)} flex items-center justify-center text-slate-800 font-semibold text-lg shadow-md`}
                            style={{ opacity: 0.75 }}
                          >
                            {formatDate(event.start, "D")}
                          </div>
                          <p className="text-xs font-bold text-slate-500 text-center mt-2 uppercase">
                            {formatDate(event.start, "MMM")}
                          </p>
                        </div>
                        <div className="flex-1">
                          <div className="flex items-start justify-between gap-3 mb-2">
                            <div className="flex items-center gap-2">
                              {getStatusIcon(event.status)}
                              <h4 className="font-bold text-slate-900 text-xl group-hover:text-slate-700">
                                {event.title}
                              </h4>
                            </div>
                            <span className={`px-4 py-2 rounded-xl text-xs font-semibold ${
                              event.status === "Open"
                                ? "bg-emerald-50 text-emerald-600"
                                : event.status === "Upcoming"
                                ? "bg-blue-50 text-blue-600"
                                : "bg-slate-50 text-slate-600"
                            }`}>
                              {event.status}
                            </span>
                          </div>
                          {event.description && (
                            <p className="text-slate-600 mb-4 line-clamp-2">
                              {event.description}
                            </p>
                          )}
                          <div className="flex items-center gap-6 flex-wrap">
                            <span className="flex items-center gap-2 text-sm font-semibold text-slate-700">
                              <Clock className="w-4 h-4 text-slate-500" />
                              {formatDate(event.start, "dddd, MMMM D")} • {event.start_time} - {event.end_time}
                            </span>
                            {event.is_eligible && (
                              <span className="px-3 py-1.5 bg-emerald-50 text-emerald-700 rounded-lg text-xs font-bold">
                                Eligible
                              </span>
                            )}
                            {event.has_voted && (
                              <span className="px-3 py-1.5 bg-blue-50 text-blue-700 rounded-lg text-xs font-bold">
                                Voted
                              </span>
                            )}
                          </div>
                        </div>
                      </div>
                    </Link>
                  ))}
                  </div>

                  {upcomingEvents.length > AGENDA_EVENTS_PER_PAGE && (
                    <div className="mt-6 space-y-3">
                      <div className="text-sm text-slate-500 flex flex-wrap items-center justify-between gap-2">
                        <span>
                          Showing{" "}
                          {upcomingEvents.length
                            ? (effectiveAgendaPage - 1) * AGENDA_EVENTS_PER_PAGE + 1
                            : 0}{" "}
                          -{" "}
                          {Math.min(effectiveAgendaPage * AGENDA_EVENTS_PER_PAGE, upcomingEvents.length)} of{" "}
                          {upcomingEvents.length} events
                        </span>
                        <span>
                          Page {effectiveAgendaPage} of {totalAgendaPages}
                        </span>
                      </div>
                      <Pagination
                        currentPage={effectiveAgendaPage}
                        totalPages={totalAgendaPages}
                        onPageChange={setAgendaPage}
                        itemsPerPage={AGENDA_EVENTS_PER_PAGE}
                        totalItems={upcomingEvents.length}
                      />
                    </div>
                  )}
                </>
              ) : (
                <div className="text-center py-12">
                  <CalendarIcon className="w-16 h-16 text-slate-300 mx-auto mb-4" />
                  <p className="text-slate-600 font-semibold text-lg">
                    No upcoming events
                  </p>
                </div>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
