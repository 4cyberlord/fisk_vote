"use client";

import Link from "next/link";
import { useAuth } from "@/hooks/useAuth";
import { Button } from "@/components";
import { PublicHeader } from "@/components/layout/PublicHeader";
import { PublicFooter } from "@/components/layout/PublicFooter";
import { useNextElectionCountdown } from "@/hooks/useNextElection";
import { formatDate } from "@/lib/dateUtils";

export default function HomePage() {
  const { isAuthenticated } = useAuth();
  const { nextElection, countdown, state, isLoading } = useNextElectionCountdown();

  const hasUpcoming = state === "upcoming" && nextElection;

  // Home page is public - no automatic redirects
  // Authenticated users can manually navigate to dashboard via the button

  return (
    <div className="min-h-screen bg-white text-slate-900 flex flex-col">
      <PublicHeader />
      {/* Hero section + all homepage sections */}
      <main className="flex-1 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-8 sm:pt-10 pb-10 sm:pb-16 lg:pb-20 space-y-16">
          {/* Primary hero row */}
          <div className="relative overflow-hidden rounded-3xl bg-gradient-to-r from-[#0a1a44] to-[#8b0000] text-white px-5 sm:px-8 lg:px-10 py-10 sm:py-14 lg:py-16 shadow-2xl">
            {/* Background image overlay */}
            <div
              className="pointer-events-none absolute inset-0 bg-cover bg-right opacity-25 mix-blend-soft-light"
              style={{
                backgroundImage:
                  "url('https://images.pexels.com/photos/15953878/pexels-photo-15953878.jpeg?auto=compress&cs=tinysrgb&w=1200')",
              }}
              aria-hidden="true"
            />

            <div className="relative grid grid-cols-1 lg:grid-cols-2 gap-10 lg:gap-12 items-center">
              {/* Hero copy */}
              <div>
                <span className="inline-flex items-center gap-2 rounded-full bg-[#f4ba1b] px-3 py-1 text-[11px] font-semibold tracking-wide">
                  <span className="text-xs">★</span>
                  Fisk Student Elections
                </span>

                <h1 className="mt-4 text-3xl sm:text-4xl lg:text-5xl font-extrabold leading-tight">
                  A campus‑wide platform for
                  <span className="relative ml-2 inline-block">
                    <span className="text-[#f4ba1b]">real change</span>
                    <span className="absolute left-0 -bottom-1 w-full h-1 rounded-full bg-[#f4ba1b]" />
                  </span>
                </h1>

                <p className="mt-4 text-sm sm:text-base text-slate-100/90 max-w-xl leading-relaxed">
                  Secure, auditable, and built around how Fisk actually runs elections. From student
                  government to residence halls, every ballot lives in one clear, modern experience.
                </p>

                {/* Countdown preview inside hero */}
                <div className="mt-6 inline-flex items-center gap-5 rounded-2xl bg-[#0c1a4a]/90 px-4 py-3 backdrop-blur-md">
                  <div className="text-xs font-semibold text-slate-200 uppercase tracking-[0.18em]">
                    Next major election
                  </div>
                  {isLoading && (
                    <div className="text-xs text-slate-200/80">Loading next election…</div>
                  )}
                  {!isLoading && hasUpcoming && (
                    <div className="flex items-center gap-4 text-center">
                      <div>
                        <p className="text-2xl font-bold tabular-nums">
                          {countdown.days.toString().padStart(2, "0")}
                        </p>
                        <p className="text-[10px] text-slate-200">DAYS</p>
                      </div>
                      <div>
                        <p className="text-2xl font-bold tabular-nums">
                          {countdown.hours.toString().padStart(2, "0")}
                        </p>
                        <p className="text-[10px] text-slate-200">HOURS</p>
                      </div>
                      <div>
                        <p className="text-2xl font-bold tabular-nums">
                          {countdown.minutes.toString().padStart(2, "0")}
                        </p>
                        <p className="text-[10px] text-slate-200">MINUTES</p>
                      </div>
                      <div>
                        <p className="text-2xl font-bold tabular-nums">
                          {countdown.seconds.toString().padStart(2, "0")}
                        </p>
                        <p className="text-[10px] text-slate-200">SECONDS</p>
                      </div>
                    </div>
                  )}
                  {!isLoading && !hasUpcoming && (
                    <div className="text-xs text-slate-200/80">
                      No upcoming elections scheduled yet.
                    </div>
                  )}
                </div>
                {hasUpcoming && (
                  <p className="mt-2 text-xs sm:text-sm text-slate-200/90">
                    {nextElection?.title
                      ? `${nextElection.title} · ${formatDate(
                          nextElection.start_timestamp || nextElection.start_time,
                          "MMM d, yyyy · h:mm a"
                        )}`
                      : "Stay tuned for the next election"}
                  </p>
                )}

                {/* Auth CTAs */}
                {isAuthenticated ? (
                  <div className="mt-6 space-y-2">
                    <div className="flex flex-wrap gap-3">
                      <Link href="/dashboard">
                        <Button className="bg-[#f4ba1b] hover:bg-[#e0a518] px-6 py-2.5 text-sm">
                          Go to my dashboard
                        </Button>
                      </Link>
                    </div>
                    <p className="text-xs sm:text-sm text-slate-200/90">
                      You&apos;re already signed in. Your upcoming and active elections are waiting on your
                      dashboard.
                    </p>
                  </div>
                ) : (
                  <div className="mt-6 space-y-3">
                    <div className="flex flex-wrap gap-3">
                      <Link href="/login">
                        <Button className="bg-[#f4ba1b] hover:bg-[#e0a518] px-6 py-2.5 text-sm">
                          Sign in to vote
                        </Button>
                      </Link>
                      <Link href="/login">
                        <Button
                          variant="outline"
                          className="border-white/60 bg-white/5 px-6 py-2.5 text-sm text-white hover:bg-white/10"
                        >
                          Preview elections
                        </Button>
                      </Link>
                    </div>
                    <p className="text-xs sm:text-sm text-slate-200/90 max-w-md">
                      Only verified Fisk students can cast ballots. Your identity is protected and your vote
                      is counted exactly once.
                    </p>
                  </div>
                )}
              </div>

              {/* Hero visual: candidate-style image + badge */}
              <div className="relative flex justify-center lg:justify-end">
                {/* Vote badge */}
                <div className="absolute -top-1 right-2 sm:top-4 sm:right-4 bg-white text-[#b48100] px-4 py-3 rounded-xl shadow-2xl text-center">
                  <p className="text-xl font-extrabold tracking-wide">VOTE</p>
                  <p className="text-[11px] font-medium text-slate-700">Your voice really matters</p>
                </div>

                {/* Candidate / student crowd image */}
                <img
                  src="https://images.pexels.com/photos/30542136/pexels-photo-30542136.jpeg?auto=compress&cs=tinysrgb&w=1200"
                  alt="Students participating in an election event"
                  className="relative w-[320px] sm:w-[380px] lg:w-[440px] rounded-3xl object-cover grayscale-[0.35] drop-shadow-2xl border border-white/20"
                />
              </div>
            </div>
          </div>

          {/* Upcoming key elections (simple list, no extra countdown) */}
          <section className="border border-slate-200 bg-slate-50 rounded-2xl px-4 sm:px-6 lg:px-8 py-7 sm:py-9 shadow-sm">
            <div className="flex flex-col gap-5">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-[11px] font-semibold tracking-[0.25em] text-rose-600 uppercase mb-1">
                    Upcoming key elections
                  </p>
                  <h2 className="text-lg sm:text-xl font-semibold text-slate-900">
                    A quick look at what&apos;s coming up.
                  </h2>
                </div>
                <Link
                  href="/dashboard/elections"
                  className="hidden sm:inline text-xs font-medium text-indigo-600 hover:text-indigo-700"
                >
                  View full list
                </Link>
              </div>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-xs sm:text-sm">
                <div className="rounded-xl border border-slate-200 bg-white px-4 py-4 flex flex-col gap-1.5">
                  <p className="text-[11px] uppercase tracking-wide text-emerald-600 font-semibold">
                    Student Senate At‑Large
                  </p>
                  <p className="text-slate-900 font-semibold">Campus‑wide representation</p>
                  <p className="text-[11px] text-slate-500">
                    Opens Mar 1 · Multiple‑choice ballot for all enrolled students.
                  </p>
                </div>
                <div className="rounded-xl border border-slate-200 bg-white px-4 py-4 flex flex-col gap-1.5">
                  <p className="text-[11px] uppercase tracking-wide text-blue-600 font-semibold">
                    Residence Hall Reps
                  </p>
                  <p className="text-slate-900 font-semibold">Voice for your living space</p>
                  <p className="text-[11px] text-slate-500">
                    Opens Mar 22 · Single‑choice per hall, focused on housing and facilities.
                  </p>
                </div>
                <div className="rounded-xl border border-slate-200 bg-white px-4 py-4 flex flex-col gap-1.5">
                  <p className="text-[11px] uppercase tracking-wide text-purple-600 font-semibold">
                    Clubs &amp; Organizations
                  </p>
                  <p className="text-slate-900 font-semibold">Officers across student groups</p>
                  <p className="text-[11px] text-slate-500">
                    Rolling · Managed by each org using the same secure voting flow.
                  </p>
                </div>
              </div>
            </div>
          </section>

          {/* Start to success style: explore elections visually */}
          <section className="border border-slate-200 bg-white rounded-2xl shadow-sm">
            <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8 sm:py-12 grid grid-cols-1 lg:grid-cols-2 gap-10 lg:gap-12">
              {/* Left content */}
              <div className="flex flex-col justify-center">
                <p className="text-[11px] sm:text-xs font-semibold text-indigo-600 tracking-[0.22em] uppercase mb-3">
                  START TO PARTICIPATION
                </p>
                <h2 className="text-2xl sm:text-3xl md:text-4xl font-extrabold leading-tight text-slate-900 mb-3">
                  Access to{" "}
                  <span className="relative text-indigo-600">
                    160+
                    <span className="absolute left-0 bottom-1 w-full h-2 bg-amber-300 -z-10 rounded" />
                  </span>{" "}
                  campus‑style elections
                  <br />
                  and{" "}
                  <span className="relative text-indigo-600">
                    500
                    <span className="absolute left-0 bottom-1 w-full h-2 bg-amber-300 -z-10 rounded" />
                  </span>{" "}
                  seeded student scenarios.
                </h2>
                <p className="text-slate-600 text-sm sm:text-base mb-4 leading-relaxed max-w-xl">
                  This demo environment is packed with realistic data so you can see how elections actually
                  feel—from class representatives all the way up to campus‑wide leadership.
                </p>
                <p className="text-slate-500 text-[11px] sm:text-xs mb-6 max-w-xl">
                  Every number here is there to help you test: different election types, eligibility rules,
                  and student situations, without touching your real production data.
                </p>
                {/* Search-style bar (frontend only) */}
                <div className="w-full">
                  <div className="bg-white shadow-lg rounded-xl flex items-center px-4 py-3 border border-slate-200">
                    <input
                      type="text"
                      placeholder="Search elections, positions, or results (UI only)"
                      className="flex-1 text-xs sm:text-sm text-slate-700 placeholder-slate-400 focus:outline-none"
                    />
                    <span className="text-indigo-600 text-lg" aria-hidden="true">
                      🔍
                    </span>
                  </div>
                </div>
              </div>

              {/* Right images */}
              <div className="relative pb-12 lg:pb-16">
                {/* Large main image */}
                <div className="rounded-xl overflow-hidden shadow-lg mb-5">
                  <img
                    src="https://images.unsplash.com/photo-1524178232363-1fb2b075b655?auto=format&fit=crop&w=1200&q=80"
                    alt="Students collaborating during an election campaign"
                    className="w-full h-[280px] sm:h-[340px] md:h-[380px] object-cover"
                  />
                </div>
                {/* Two small images */}
                <div className="grid grid-cols-2 gap-4">
                  <div className="rounded-xl overflow-hidden shadow-lg">
                    <img
                      src="https://images.unsplash.com/photo-1523580846011-d3a5bc25702b?auto=format&fit=crop&w=800&q=80"
                      alt="Student speaking with a small group"
                      className="w-full h-[170px] sm:h-[190px] md:h-[210px] object-cover"
                    />
                  </div>
                  <div className="rounded-xl overflow-hidden shadow-lg">
                    <img
                      src="https://images.unsplash.com/photo-1529699211952-734e80c4d42b?auto=format&fit=crop&w=800&q=80"
                      alt="Students listening during a campus talk"
                      className="w-full h-[170px] sm:h-[190px] md:h-[210px] object-cover"
                    />
                  </div>
                </div>
                {/* Floating notification card */}
                <div className="absolute left-1/2 -translate-x-1/2 -bottom-4 bg-white shadow-xl rounded-2xl px-4 sm:px-5 py-3 flex items-center gap-3 w-[90%] md:w-[75%] border border-slate-100">
                  <div className="bg-amber-400 text-white w-10 h-10 sm:w-12 sm:h-12 rounded-full flex items-center justify-center shadow">
                    <span aria-hidden="true">📅</span>
                  </div>
                  <p className="text-slate-800 text-xs sm:text-sm font-medium">
                    Don&apos;t miss the upcoming{" "}
                    <span className="font-bold">Student Government President</span> election in this demo.
                  </p>
                </div>
              </div>
            </div>
          </section>

          {/* Candidate / leadership style highlight */}
          <section className="w-full bg-slate-50">
            {/* Hero-style candidate strip */}
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-12 sm:pt-16 pb-16 sm:pb-24 grid md:grid-cols-2 gap-10 lg:gap-12 items-center">
              {/* Left content */}
              <div>
                <span className="inline-block px-4 py-1 text-[11px] sm:text-xs font-semibold bg-[#f4ba1b]/10 text-[#b48100] rounded-full">
                  HELLO! THIS COULD BE YOUR CANDIDATE
                </span>
                <h2 className="text-2xl sm:text-3xl md:text-4xl font-bold mt-4 text-slate-900 leading-tight">
                  Promoting{" "}
                  <span className="text-[#f4ba1b]">insight</span> &amp;{" "}
                  <span className="text-indigo-600">leadership</span> across campus.
                </h2>
                <p className="mt-4 text-slate-600 text-sm sm:text-base leading-relaxed max-w-xl">
                  This platform is built for student leaders with real ideas—whether they&apos;re running
                  for president, class rep, or club officer—and for voters who want their voices to count.
                </p>
                <Link href="/dashboard/elections">
                  <Button className="mt-6 px-6 py-2.5 text-sm bg-indigo-600 hover:bg-indigo-700">
                    View all elections
                  </Button>
                </Link>
              </div>

              {/* Right image + cards */}
              <div className="relative">
                <img
                  src="https://images.unsplash.com/photo-1523580846011-d3a5bc25702b?auto=format&fit=crop&w=1400&q=80"
                  className="rounded-2xl shadow-xl w-full h-[320px] sm:h-[380px] md:h-[420px] object-cover"
                  alt="Student leader speaking at an event"
                />

                {/* Active supporters */}
                <div className="absolute top-5 left-5 bg-white/95 backdrop-blur-sm p-4 rounded-xl shadow-md">
                  <p className="text-[11px] sm:text-xs text-slate-500">Active supporters (demo)</p>
                  <p className="text-lg sm:text-xl font-bold text-slate-900">240</p>
                </div>

                {/* Total volunteers */}
                <div className="absolute top-1/2 right-5 -translate-y-1/2 bg-white/95 backdrop-blur-sm p-4 sm:p-5 rounded-xl shadow-md">
                  <p className="text-[11px] sm:text-xs text-slate-500">Total volunteers (demo)</p>
                  <p className="text-lg sm:text-xl font-bold text-slate-900">1,265</p>
                  <div className="flex mt-2">
                    <img
                      src="https://randomuser.me/api/portraits/men/32.jpg"
                      className="h-7 w-7 rounded-full border-2 border-white -ml-1"
                      alt="Volunteer"
                    />
                    <img
                      src="https://randomuser.me/api/portraits/women/44.jpg"
                      className="h-7 w-7 rounded-full border-2 border-white -ml-1"
                      alt="Volunteer"
                    />
                    <img
                      src="https://randomuser.me/api/portraits/men/65.jpg"
                      className="h-7 w-7 rounded-full border-2 border-white -ml-1"
                      alt="Volunteer"
                    />
                  </div>
                </div>

                {/* Certified leader badge */}
                <div className="absolute -bottom-10 left-1/2 -translate-x-1/2">
                  <div className="bg-purple-600 text-white text-center p-6 rounded-full h-28 w-28 sm:h-32 sm:w-32 shadow-lg flex items-center justify-center font-semibold text-[10px] sm:text-xs">
                    Demo leadership-ready interface
                  </div>
                </div>
              </div>
            </div>

            {/* About leadership / about page strip */}
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-14 sm:pb-20 grid md:grid-cols-2 gap-10 lg:gap-12 items-center">
              {/* Image */}
              <div className="relative order-2 md:order-1">
                <div className="absolute top-0 left-0 bg-indigo-100 h-16 w-16 sm:h-20 sm:w-20 rounded-xl opacity-50" />
                <img
                  src="https://images.unsplash.com/photo-1524178232363-1fb2b075b655?auto=format&fit=crop&w=1200&q=80"
                  className="rounded-2xl shadow-xl relative z-10 h-[260px] sm:h-[320px] object-cover w-full"
                  alt="Students in discussion"
                />
                <div className="absolute bottom-0 right-0 bg-[#f4ba1b]/20 h-20 w-20 sm:h-28 sm:w-28 rounded-xl opacity-40" />
              </div>

              {/* Text */}
              <div className="order-1 md:order-2">
                <div className="flex items-center space-x-2">
                  <span className="h-2 w-2 bg-[#f4ba1b] rounded-full" />
                  <p className="text-[11px] sm:text-xs font-semibold tracking-wide text-slate-700">
                    ABOUT THIS PLATFORM
                  </p>
                </div>
                <h3 className="text-xl sm:text-2xl md:text-3xl font-bold text-slate-900 mt-3">
                  A home for student leadership, participation, and fair results.
                </h3>
                <p className="mt-4 text-xs sm:text-sm text-slate-600 leading-relaxed">
                  The Fisk Voting System was designed to feel serious enough for real elections, but simple
                  enough that every student can use it comfortably—on any device, from any location.
                </p>
                <div className="flex items-center mt-5 space-x-4">
                  <div className="bg-slate-100 p-4 rounded-full">
                    <span className="text-indigo-600 text-xl sm:text-2xl font-bold">08+</span>
                  </div>
                  <div>
                    <p className="font-bold text-slate-900 text-sm sm:text-base">Years of patterns</p>
                    <p className="text-[11px] sm:text-xs text-slate-600">
                      UI and flows inspired by years of public service and campus governance experience.
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </section>

          {/* Featured upcoming campaign-style election (refined layout) */}
          <section className="py-12 sm:py-16 bg-white">
            {/* Top badge */}
            <div className="text-center mb-4 sm:mb-6">
              <span className="inline-flex items-center bg-[#f4ba1b]/10 px-4 py-2 rounded-full text-[11px] sm:text-sm font-medium text-slate-700">
                <span className="text-[#f4ba1b] text-base sm:text-lg mr-2">★</span>
                COME AND JOIN US
              </span>
            </div>

            {/* Heading */}
            <h2 className="text-center text-2xl sm:text-3xl md:text-4xl font-extrabold text-slate-900 tracking-wide mb-8 sm:mb-12">
              OUR UPCOMING <span className="text-[#f4ba1b]">CAMPAIGN</span>
            </h2>

            <div className="max-w-6xl mx-auto grid grid-cols-1 md:grid-cols-2 gap-10 px-4 sm:px-6 lg:px-8">
              {/* Left big campaign card */}
              <div className="relative rounded-2xl overflow-hidden shadow-xl group">
                <img
                  src="https://images.pexels.com/photos/30542136/pexels-photo-30542136.jpeg?auto=compress&cs=tinysrgb&w=1200"
                  className="w-full h-[420px] sm:h-[480px] md:h-[520px] object-cover"
                  alt="Students gathered for a campus election event"
                />
                {/* Gradient overlay */}
                <div className="absolute inset-0 bg-gradient-to-t from-black/85 via-black/40 to-black/10" />

                {/* Content */}
                <div className="absolute inset-x-6 bottom-6 text-white">
                  <div className="flex flex-wrap items-center gap-2 sm:gap-3 mb-3">
                    <span className="bg-[#f4ba1b] text-[10px] sm:text-xs px-3 py-1 rounded font-semibold">
                      Campaign
                    </span>
                    <span className="text-xs sm:text-sm opacity-90">
                      Spring 2026 · Student Government President
                    </span>
                  </div>
                  <h3 className="text-lg sm:text-xl md:text-2xl font-bold mb-4">
                    Help shape the next chapter of student leadership at Fisk.
                  </h3>

                  {/* Countdown using existing state */}
                  <div className="flex justify-between max-w-md text-2xl sm:text-3xl font-bold tracking-widest">
                    <div className="flex flex-col items-center flex-1">
                      <span>{countdown.days.toString().padStart(2, "0")}</span>
                      <span className="text-[10px] sm:text-xs font-light tracking-normal">
                        DAYS
                      </span>
                    </div>
                    <div className="flex flex-col items-center flex-1">
                      <span>{countdown.hours.toString().padStart(2, "0")}</span>
                      <span className="text-[10px] sm:text-xs font-light tracking-normal">
                        HOURS
                      </span>
                    </div>
                    <div className="flex flex-col items-center flex-1">
                      <span>{countdown.minutes.toString().padStart(2, "0")}</span>
                      <span className="text-[10px] sm:text-xs font-light tracking-normal">
                        MINUTES
                      </span>
                    </div>
                    <div className="flex flex-col items-center flex-1">
                      <span>{countdown.seconds.toString().padStart(2, "0")}</span>
                      <span className="text-[10px] sm:text-xs font-light tracking-normal">
                        SECONDS
                      </span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Right side list */}
              <div className="space-y-6 sm:space-y-8">
                {/* Item 1 */}
                <article className="border border-slate-200 rounded-xl bg-slate-50 px-4 py-4 sm:px-5 sm:py-5">
                  <div className="flex items-center space-x-3 mb-2">
                    <span className="bg-[#f4ba1b] text-white text-[10px] sm:text-xs px-3 py-1 rounded font-semibold">
                      Campaign
                    </span>
                    <span className="text-xs sm:text-sm text-slate-600">
                      Spring 2026 · President
                    </span>
                  </div>
                  <h3 className="text-sm sm:text-base font-bold text-slate-900 mb-1.5">
                    Student Government President election
                  </h3>
                  <p className="text-[11px] sm:text-xs text-slate-600 leading-relaxed">
                    A campus‑wide vote to select the next primary representative for the student body,
                    using ranked‑choice ballots to ensure broad support.
                  </p>
                </article>

                {/* Item 2 */}
                <article className="border border-slate-200 rounded-xl bg-white px-4 py-4 sm:px-5 sm:py-5">
                  <div className="flex items-center space-x-3 mb-2">
                    <span className="bg-[#f4ba1b] text-white text-[10px] sm:text-xs px-3 py-1 rounded font-semibold">
                      Campaign
                    </span>
                    <span className="text-xs sm:text-sm text-slate-600">
                      Upcoming · Academic year
                    </span>
                  </div>
                  <h3 className="text-sm sm:text-base font-bold text-slate-900 mb-1.5">
                    Academic council and class representative seats
                  </h3>
                  <p className="text-[11px] sm:text-xs text-slate-600 leading-relaxed">
                    Positions focused on academics, curriculum feedback, and ensuring students have a voice
                    in how learning happens on campus.
                  </p>
                </article>

                {/* Item 3 */}
                <article className="border border-slate-200 rounded-xl bg-white px-4 py-4 sm:px-5 sm:py-5">
                  <div className="flex items-center space-x-3 mb-2">
                    <span className="bg-[#f4ba1b] text-white text-[10px] sm:text-xs px-3 py-1 rounded font-semibold">
                      Campaign
                    </span>
                    <span className="text-xs sm:text-sm text-slate-600">
                      Rolling · Throughout the year
                    </span>
                  </div>
                  <h3 className="text-sm sm:text-base font-bold text-slate-900 mb-1.5">
                    Club, organization, and committee leadership
                  </h3>
                  <p className="text-[11px] sm:text-xs text-slate-600 leading-relaxed">
                    Officer elections for student‑run groups—perfect for testing how this system can support
                    many smaller campaigns alongside big flagship votes.
                  </p>
                </article>
              </div>
            </div>
          </section>

          {/* Why students and staff trust it */}
          <section className="border border-slate-200 bg-white rounded-2xl px-4 sm:px-6 lg:px-8 py-7 sm:py-9 shadow-sm">
            <div className="flex flex-col gap-6 lg:gap-8">
              <div className="max-w-2xl">
                <p className="text-[11px] font-semibold tracking-[0.25em] text-indigo-600 uppercase mb-2">
                  Built for real campus needs
                </p>
                <h2 className="text-lg sm:text-xl font-semibold text-slate-900 mb-2">
                  Why Fisk students, staff, and admins can trust every result
                </h2>
                <p className="text-xs sm:text-sm text-slate-500">
                  This system doesn&apos;t just collect votes. It tracks activity, protects access, and
                  makes it easy to explain how every outcome was reached—especially for ranked‑choice races.
                </p>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div className="rounded-xl border border-slate-200 bg-slate-50 p-4 flex flex-col gap-2">
                  <p className="text-xs font-semibold text-slate-500 uppercase tracking-wide">
                    For students
                  </p>
                  <p className="text-sm font-semibold text-slate-900">
                    One account, all your elections
                  </p>
                  <p className="text-xs text-slate-600">
                    See everything you&apos;re eligible to vote in—past, present, and upcoming—in a single,
                    clean dashboard.
                  </p>
                </div>

                <div className="rounded-xl border border-slate-200 bg-white p-4 flex flex-col gap-2">
                  <p className="text-xs font-semibold text-slate-500 uppercase tracking-wide">
                    For organizers
                  </p>
                  <p className="text-sm font-semibold text-slate-900">
                    Less chaos, more control
                  </p>
                  <p className="text-xs text-slate-600">
                    Configure eligibility, positions, and ranking rules once. The system handles ballots and
                    tallies consistently every time.
                  </p>
                </div>

                <div className="rounded-xl border border-slate-200 bg-white p-4 flex flex-col gap-2">
                  <p className="text-xs font-semibold text-slate-500 uppercase tracking-wide">
                    For auditors
                  </p>
                  <p className="text-sm font-semibold text-slate-900">
                    Clear, reviewable history
                  </p>
                  <p className="text-xs text-slate-600">
                    Audit logs, session tracking, and detailed result breakdowns make it easy to answer
                    &quot;how did we get this outcome?&quot;
                  </p>
                </div>
              </div>
            </div>
          </section>

          {/* Security & transparency highlight */}
          <section className="border border-slate-200 bg-white rounded-2xl px-4 sm:px-6 lg:px-8 py-9 sm:py-11 relative overflow-hidden">
            <div className="pointer-events-none absolute inset-0 opacity-40">
              <div className="absolute -top-24 right-0 h-64 w-64 rounded-full bg-[#f4ba1b]/20 blur-3xl" />
              <div className="absolute bottom-[-4rem] left-[-2rem] h-64 w-64 rounded-full bg-slate-100 blur-3xl" />
            </div>
            <div className="relative flex flex-col gap-8 lg:gap-10">
              {/* Top row: copy + timeline */}
              <div className="flex flex-col lg:flex-row lg:items-start lg:justify-between gap-8">
                <div className="max-w-xl">
                  <p className="text-[11px] font-semibold tracking-[0.25em] text-[#b48100] uppercase mb-2">
                    Security &amp; transparency
                  </p>
                  <h2 className="text-xl sm:text-2xl font-semibold text-slate-900 mb-3">
                    Designed so you can prove an election was fair, not just hope it was.
                  </h2>
                  <p className="text-sm text-slate-600 mb-4">
                    Every important action—signing in, changing settings, casting a ballot—leaves a trail.
                    That trail is what makes it possible to answer questions later with confidence.
                  </p>
                </div>

                {/* Simple vertical timeline */}
                <div className="flex-1 max-w-md">
                  <ol className="relative border-l border-slate-200 pl-4 space-y-4 text-xs sm:text-sm">
                    <li className="ml-1">
                      <div className="absolute -left-[7px] h-3 w-3 rounded-full bg-[#f4ba1b] border border-white" />
                      <p className="font-semibold text-slate-900">Login &amp; device checks</p>
                      <p className="text-slate-500 text-[11px] sm:text-xs">
                        Logins are recorded with device and IP details so strange activity stands out quickly.
                      </p>
                    </li>
                    <li className="ml-1">
                      <div className="absolute -left-[7px] mt-6 h-3 w-3 rounded-full bg-[#f4ba1b] border border-white" />
                      <p className="font-semibold text-slate-900 mt-4">Account &amp; security changes</p>
                      <p className="text-slate-500 text-[11px] sm:text-xs">
                        Profile updates and password changes are tracked in the same place as login events.
                      </p>
                    </li>
                    <li className="ml-1">
                      <div className="absolute -left-[7px] mt-6 h-3 w-3 rounded-full bg-[#f4ba1b] border border-white" />
                      <p className="font-semibold text-slate-900 mt-4">Ballots &amp; results</p>
                      <p className="text-slate-500 text-[11px] sm:text-xs">
                        Votes are counted with clear rules—single choice, multiple choice, or ranked‑choice—
                        and results are easy to review.
                      </p>
                    </li>
                  </ol>
                </div>
              </div>

              {/* Bottom row: stat cards */}
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
                <div className="rounded-xl bg-slate-50 border border-slate-200 p-4">
                  <p className="text-[11px] text-slate-500 uppercase tracking-wide mb-1">
                    Login events (demo)
                  </p>
                  <p className="text-2xl font-semibold text-slate-900">+248</p>
                  <p className="mt-1 text-[11px] text-slate-500">
                    Sign-ins and failures logged so unusual activity stands out.
                  </p>
                </div>
                <div className="rounded-xl bg-slate-50 border border-slate-200 p-4">
                  <p className="text-[11px] text-slate-500 uppercase tracking-wide mb-1">
                    Elections tracked
                  </p>
                  <p className="text-2xl font-semibold text-slate-900">160+</p>
                  <p className="mt-1 text-[11px] text-slate-500">
                    Realistic campus‑style elections seeded for testing.
                  </p>
                </div>
                <div className="rounded-xl bg-slate-50 border border-slate-200 p-4">
                  <p className="text-[11px] text-slate-500 uppercase tracking-wide mb-1">
                    Active sessions
                  </p>
                  <p className="text-2xl font-semibold text-slate-900">Multi‑device</p>
                  <p className="mt-1 text-[11px] text-slate-500">
                    See where you&apos;re signed in and revoke access.
                  </p>
                </div>
                <div className="rounded-xl bg-slate-50 border border-slate-200 p-4">
                  <p className="text-[11px] text-slate-500 uppercase tracking-wide mb-1">
                    Result visibility
                  </p>
                  <p className="text-2xl font-semibold text-slate-900">Live</p>
                  <p className="mt-1 text-[11px] text-slate-500">
                    Dashboards and detailed pages for every completed election.
                  </p>
                </div>
              </div>
            </div>
          </section>

          {/* About our campaign / movement */}
          <section className="w-full bg-white">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10 sm:py-16 grid md:grid-cols-2 gap-10 lg:gap-12 items-center">
              {/* Left image */}
              <div className="relative">
                <img
                  src="https://images.pexels.com/photos/15953878/pexels-photo-15953878.jpeg?auto=compress&cs=tinysrgb&w=1200"
                  className="w-full rounded-2xl shadow-xl object-cover h-[260px] sm:h-[320px] md:h-[360px]"
                  alt="Students attending a campus event"
                />
                <div className="absolute -bottom-6 -right-6 h-20 w-20 sm:h-24 sm:w-24 bg-[#f4ba1b]/20 rounded-xl opacity-30" />
              </div>

              {/* Right text */}
              <div>
                <span className="inline-block px-4 py-1 text-[11px] sm:text-xs font-semibold bg-indigo-100 text-indigo-700 rounded-full">
                  ABOUT OUR CAMPAIGN
                </span>
                <h2 className="text-2xl sm:text-3xl md:text-4xl font-bold text-slate-900 mt-4 leading-tight">
                  Building a better future through{" "}
                  <span className="text-[#f4ba1b]">leadership</span> &amp;{" "}
                  <span className="text-indigo-600">unity</span>.
                </h2>
                <p className="mt-4 sm:mt-6 text-slate-600 leading-relaxed text-sm sm:text-base">
                  This demo showcases how a real movement on campus might communicate its vision:
                  transparent processes, strong representation, and tools that make it easy for students
                  to participate.
                </p>
                <p className="mt-3 sm:mt-4 text-slate-600 leading-relaxed text-sm sm:text-base">
                  The platform is designed to support inclusive policies, responsible governance, and pathways
                  for new leaders to step forward and shape what comes next for the student body.
                </p>
                <Link href="/dashboard/elections">
                  <Button className="mt-6 sm:mt-8 px-6 py-2.5 text-sm bg-[#f4ba1b] hover:bg-[#e0a518]">
                    Learn more inside the dashboard
                  </Button>
                </Link>
              </div>
            </div>
          </section>

          {/* Final call-to-action */}
          <section className="border border-slate-200 bg-white rounded-2xl px-4 sm:px-6 lg:px-8 py-7 sm:py-9 shadow-sm">
            <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
              <div>
                <h2 className="text-lg sm:text-xl font-semibold text-slate-900">
                  Ready to see your elections in one place?
                </h2>
                <p className="mt-1 text-xs sm:text-sm text-slate-500 max-w-xl">
                  Sign in with your Fisk account to explore upcoming elections, review your voting history,
                  and manage your account settings.
                </p>
              </div>
              <div className="flex flex-wrap gap-3">
                <Link href="/login">
                  <Button className="px-6 py-2.5 text-sm">Go to login</Button>
                </Link>
              </div>
            </div>
          </section>
        </div>
      </main>
      <PublicFooter />
    </div>
  );
}
