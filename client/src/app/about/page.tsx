"use client";

import Link from "next/link";
import {
  Shield,
  Users,
  Award,
  Target,
  Heart,
  Zap,
  CheckCircle,
  TrendingUp,
  Globe,
  Lock,
  BarChart3,
  Vote,
  Calendar,
  BookOpen,
  ArrowRight,
} from "lucide-react";
import { PublicHeader } from "@/components/layout/PublicHeader";
import { PublicFooter } from "@/components/layout/PublicFooter";
import { Button } from "@/components";

export default function AboutPage() {
  const stats = [
    { icon: Vote, label: "Elections Conducted", value: "160+", color: "text-[#f4ba1b]" },
    { icon: Users, label: "Active Students", value: "500+", color: "text-indigo-600" },
    { icon: Shield, label: "Security Score", value: "100%", color: "text-emerald-600" },
    { icon: Award, label: "Years of Excellence", value: "8+", color: "text-rose-600" },
  ];

  const values = [
    {
      icon: Shield,
      title: "Security First",
      description:
        "Every vote is encrypted and audited. We use industry-leading security practices to protect student data and ensure election integrity.",
      color: "bg-emerald-50 text-emerald-600 border-emerald-200",
    },
    {
      icon: Users,
      title: "Student-Centered",
      description:
        "Built by students, for students. Our platform prioritizes accessibility, ease of use, and transparency in every decision.",
      color: "bg-indigo-50 text-indigo-600 border-indigo-200",
    },
    {
      icon: Target,
      title: "Transparency",
      description:
        "Complete audit trails, real-time results, and open communication. We believe in making the election process as transparent as possible.",
      color: "bg-blue-50 text-blue-600 border-blue-200",
    },
    {
      icon: Heart,
      title: "Fairness",
      description:
        "Every student voice matters. Our system ensures equal access, fair representation, and unbiased election outcomes.",
      color: "bg-rose-50 text-rose-600 border-rose-200",
    },
    {
      icon: Zap,
      title: "Innovation",
      description:
        "Continuously improving our platform with the latest technology to make voting faster, easier, and more accessible for everyone.",
      color: "bg-amber-50 text-amber-600 border-amber-200",
    },
    {
      icon: Globe,
      title: "Accessibility",
      description:
        "Available on any device, anywhere. We ensure every student can participate regardless of their location or device.",
      color: "bg-purple-50 text-purple-600 border-purple-200",
    },
  ];

  const features = [
    {
      icon: Lock,
      title: "Secure Voting",
      description: "End-to-end encryption and secure authentication protect every ballot.",
    },
    {
      icon: BarChart3,
      title: "Real-Time Results",
      description: "See election results as they come in with transparent, live updates.",
    },
    {
      icon: Calendar,
      title: "Easy Scheduling",
      description: "Manage multiple elections simultaneously with our intuitive calendar system.",
    },
    {
      icon: BookOpen,
      title: "Comprehensive Guides",
      description: "Step-by-step voting guides help first-time voters participate confidently.",
    },
  ];

  return (
    <div className="min-h-screen bg-white text-slate-900 flex flex-col">
      <PublicHeader />
      <main className="flex-1">
        {/* Hero Section */}
        <section className="relative overflow-hidden bg-gradient-to-br from-[#0a1a44] via-indigo-900 to-[#8b0000] text-white py-20 sm:py-24 lg:py-28">
          {/* Background Pattern */}
          <div className="absolute inset-0 opacity-10">
            <div
              className="absolute inset-0"
              style={{
                backgroundImage: `url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='1'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E")`,
              }}
            />
          </div>

          {/* Decorative Elements */}
          <div className="absolute top-0 right-0 w-96 h-96 bg-[#f4ba1b]/10 rounded-full blur-3xl" />
          <div className="absolute bottom-0 left-0 w-96 h-96 bg-indigo-500/10 rounded-full blur-3xl" />

          <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="text-center max-w-4xl mx-auto">
              <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-[#f4ba1b]/20 backdrop-blur-sm border border-[#f4ba1b]/30 mb-6 mt-8 sm:mt-12">
                <Users className="w-4 h-4 text-[#f4ba1b]" />
                <span className="text-sm font-semibold text-[#f4ba1b]">About Fisk Voting System</span>
              </div>

              <h1 className="text-4xl sm:text-5xl lg:text-6xl font-extrabold mb-6 leading-tight">
                Empowering Student Democracy
              </h1>
              <p className="text-lg sm:text-xl text-slate-100 mb-8 max-w-2xl mx-auto leading-relaxed">
                A modern, secure, and transparent platform designed to make campus elections accessible,
                fair, and trustworthy for every student at Fisk University.
              </p>
            </div>
          </div>
        </section>

        {/* Stats Section */}
        <section className="py-12 sm:py-16 bg-slate-50 border-b border-slate-200">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="grid grid-cols-2 lg:grid-cols-4 gap-6 sm:gap-8">
              {stats.map((stat, index) => {
                const Icon = stat.icon;
                return (
                  <div
                    key={index}
                    className="text-center p-6 bg-white rounded-2xl border border-slate-200 shadow-sm hover:shadow-md transition-shadow"
                  >
                    <div className={`inline-flex items-center justify-center w-12 h-12 rounded-xl ${stat.color} bg-opacity-10 mb-4`}>
                      <Icon className={`w-6 h-6 ${stat.color}`} />
                    </div>
                    <div className="text-3xl sm:text-4xl font-bold text-slate-900 mb-2">{stat.value}</div>
                    <div className="text-sm text-slate-600 font-medium">{stat.label}</div>
                  </div>
                );
              })}
            </div>
          </div>
        </section>

        {/* Our Story Section */}
        <section className="py-16 sm:py-20 lg:py-24">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 lg:gap-16 items-center">
              <div>
                <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-indigo-100 text-indigo-700 text-xs font-semibold mb-4">
                  <BookOpen className="w-3 h-3" />
                  Our Story
                </div>
                <h2 className="text-3xl sm:text-4xl font-bold text-slate-900 mb-6">
                  Building a Better Way to Vote
                </h2>
                <div className="space-y-4 text-slate-600 leading-relaxed">
                  <p>
                    The Fisk Voting System was born from a simple observation: campus elections should be
                    as accessible, secure, and transparent as the democratic process itself. Founded in
                    2016, our platform has evolved from a basic voting tool to a comprehensive election
                    management system.
                  </p>
                  <p>
                    We recognized that traditional paper ballots and outdated voting systems created
                    barriers for student participation. Our mission became clear: create a platform that
                    empowers every student to have their voice heard, regardless of their location,
                    schedule, or technical expertise.
                  </p>
                  <p>
                    Today, we&apos;ve conducted over 160 elections, serving thousands of students across
                    various campus organizations, from student government to residence halls, clubs, and
                    academic departments.
                  </p>
                </div>
              </div>
              <div className="relative">
                <div className="absolute -top-4 -right-4 w-72 h-72 bg-[#f4ba1b]/20 rounded-full blur-3xl" />
                <div className="relative rounded-2xl overflow-hidden shadow-2xl">
                  <img
                    src="https://images.unsplash.com/photo-1524178232363-1fb2b075b655?w=800&h=600&fit=crop"
                    alt="Students collaborating"
                    className="w-full h-[400px] sm:h-[500px] object-cover"
                  />
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Mission & Vision */}
        <section className="py-16 sm:py-20 bg-slate-50">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-8 lg:gap-12">
              {/* Mission */}
              <div className="bg-white rounded-2xl p-8 sm:p-10 border border-slate-200 shadow-sm">
                <div className="inline-flex items-center justify-center w-14 h-14 rounded-xl bg-indigo-100 text-indigo-600 mb-6">
                  <Target className="w-7 h-7" />
                </div>
                <h3 className="text-2xl font-bold text-slate-900 mb-4">Our Mission</h3>
                <p className="text-slate-600 leading-relaxed">
                  To provide a secure, accessible, and transparent voting platform that empowers every
                  student to participate in campus democracy, ensuring that every voice is heard and
                  every vote counts.
                </p>
              </div>

              {/* Vision */}
              <div className="bg-white rounded-2xl p-8 sm:p-10 border border-slate-200 shadow-sm">
                <div className="inline-flex items-center justify-center w-14 h-14 rounded-xl bg-[#f4ba1b]/20 text-[#b48100] mb-6">
                  <TrendingUp className="w-7 h-7" />
                </div>
                <h3 className="text-2xl font-bold text-slate-900 mb-4">Our Vision</h3>
                <p className="text-slate-600 leading-relaxed">
                  To become the leading platform for student democracy, setting the standard for
                  transparency, security, and accessibility in campus elections across universities
                  nationwide.
                </p>
              </div>
            </div>
          </div>
        </section>

        {/* Core Values */}
        <section className="py-16 sm:py-20 lg:py-24">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="text-center max-w-3xl mx-auto mb-12">
              <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-indigo-100 text-indigo-700 text-xs font-semibold mb-4">
                <Heart className="w-3 h-3" />
                What We Stand For
              </div>
              <h2 className="text-3xl sm:text-4xl font-bold text-slate-900 mb-4">
                Our Core Values
              </h2>
              <p className="text-lg text-slate-600">
                These principles guide everything we do and every decision we make.
              </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {values.map((value, index) => {
                const Icon = value.icon;
                return (
                  <div
                    key={index}
                    className={`p-6 rounded-2xl border-2 ${value.color} hover:shadow-lg transition-all duration-300`}
                  >
                    <div className="mb-4">
                      <Icon className="w-8 h-8" />
                    </div>
                    <h3 className="text-xl font-bold text-slate-900 mb-3">{value.title}</h3>
                    <p className="text-slate-600 leading-relaxed">{value.description}</p>
                  </div>
                );
              })}
            </div>
          </div>
        </section>

        {/* Features Section */}
        <section className="py-16 sm:py-20 bg-slate-50">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="text-center max-w-3xl mx-auto mb-12">
              <h2 className="text-3xl sm:text-4xl font-bold text-slate-900 mb-4">
                Why Choose Our Platform?
              </h2>
              <p className="text-lg text-slate-600">
                Built with students in mind, our platform offers everything you need for successful
                elections.
              </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
              {features.map((feature, index) => {
                const Icon = feature.icon;
                return (
                  <div
                    key={index}
                    className="bg-white rounded-xl p-6 border border-slate-200 hover:shadow-lg transition-all"
                  >
                    <div className="inline-flex items-center justify-center w-12 h-12 rounded-lg bg-indigo-100 text-indigo-600 mb-4">
                      <Icon className="w-6 h-6" />
                    </div>
                    <h3 className="text-lg font-bold text-slate-900 mb-2">{feature.title}</h3>
                    <p className="text-sm text-slate-600 leading-relaxed">{feature.description}</p>
                  </div>
                );
              })}
            </div>
          </div>
        </section>

        {/* Commitment Section */}
        <section className="py-16 sm:py-20 lg:py-24 bg-slate-50">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 lg:gap-12 items-center">
              {/* Left Side - Content */}
              <div>
                <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-indigo-100 text-indigo-700 text-xs font-semibold mb-6">
                  <Heart className="w-3 h-3" />
                  Our Promise
                </div>
                <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-slate-900 mb-6 leading-tight">
                  Our Commitment to You
                </h2>
                <p className="text-lg text-slate-600 mb-8 leading-relaxed">
                  We&apos;re committed to maintaining the highest standards of security, transparency,
                  and accessibility. Every feature we build, every update we release, and every
                  election we support is done with your trust and participation in mind.
                </p>

                {/* Commitment Items */}
                <div className="space-y-4 mb-8">
                  {[
                    "100% secure and encrypted voting process",
                    "Complete audit trails for every election",
                    "24/7 support during election periods",
                    "Regular security audits and updates",
                    "Transparent results and reporting",
                  ].map((item, index) => (
                    <div
                      key={index}
                      className="flex items-start gap-4 p-4 rounded-xl bg-white border border-slate-200 hover:border-[#f4ba1b] hover:shadow-md transition-all group"
                    >
                      <div className="flex-shrink-0 w-10 h-10 rounded-lg bg-[#f4ba1b]/10 flex items-center justify-center group-hover:bg-[#f4ba1b] transition-colors">
                        <CheckCircle className="w-5 h-5 text-[#f4ba1b] group-hover:text-white transition-colors" />
                      </div>
                      <span className="text-slate-700 font-medium pt-2">{item}</span>
                    </div>
                  ))}
                </div>

                {/* CTA Buttons */}
                <div className="flex flex-wrap gap-4">
                  <Link href="/elections">
                    <button className="group relative inline-flex items-center gap-3 px-8 py-4 bg-gradient-to-r from-[#f4ba1b] to-amber-400 text-slate-900 font-bold text-sm sm:text-base rounded-xl shadow-lg hover:shadow-xl transition-all duration-300 hover:scale-105 overflow-hidden">
                      {/* Animated background gradient */}
                      <span className="absolute inset-0 bg-gradient-to-r from-amber-400 to-[#f4ba1b] opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
                      
                      {/* Content */}
                      <span className="relative z-10 flex items-center gap-3">
                        <span className="text-slate-900">Explore Elections</span>
                        <div className="relative w-6 h-6 flex items-center justify-center">
                          <ArrowRight className="w-5 h-5 text-slate-900 group-hover:translate-x-1 transition-transform duration-300" />
                          <ArrowRight className="absolute w-5 h-5 text-slate-900 opacity-0 group-hover:opacity-100 -translate-x-2 group-hover:translate-x-0 transition-all duration-300" />
                        </div>
                      </span>
                      
                      {/* Shine effect */}
                      <span className="absolute inset-0 -translate-x-full group-hover:translate-x-full transition-transform duration-700 bg-gradient-to-r from-transparent via-white/30 to-transparent" />
                    </button>
                  </Link>
                  <Link href="/faq">
                    <Button
                      variant="outline"
                      className="border-2 border-slate-300 text-slate-700 hover:bg-slate-100 hover:border-slate-400 px-6 py-3 font-semibold transition-all"
                    >
                      Learn More
                    </Button>
                  </Link>
                </div>
              </div>

              {/* Right Side - Visual Element */}
              <div className="relative">
                {/* Decorative Background */}
                <div className="absolute inset-0 bg-gradient-to-br from-[#f4ba1b]/20 via-indigo-100 to-purple-100 rounded-3xl blur-3xl" />
                
                {/* Main Card */}
                <div className="relative bg-gradient-to-br from-slate-900 via-slate-800 to-indigo-900 rounded-3xl p-8 sm:p-10 lg:p-12 text-white shadow-2xl">
                  {/* Pattern Overlay */}
                  <div className="absolute inset-0 opacity-10 rounded-3xl overflow-hidden">
                    <div
                      className="absolute inset-0"
                      style={{
                        backgroundImage: `url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='1'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E")`,
                      }}
                    />
                  </div>

                  <div className="relative z-10">
                    {/* Icon Badge */}
                    <div className="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-[#f4ba1b]/20 backdrop-blur-sm border border-[#f4ba1b]/30 mb-6">
                      <Shield className="w-8 h-8 text-[#f4ba1b]" />
                    </div>

                    <h3 className="text-2xl sm:text-3xl font-bold mb-4">
                      Trust & Security
                    </h3>
                    <p className="text-slate-200 mb-6 leading-relaxed">
                      Your trust is our foundation. We implement industry-leading security measures
                      and maintain complete transparency in everything we do.
                    </p>

                    {/* Stats */}
                    <div className="grid grid-cols-2 gap-4 pt-6 border-t border-white/10">
                      <div>
                        <div className="text-3xl font-bold text-[#f4ba1b] mb-1">100%</div>
                        <div className="text-sm text-slate-300">Secure</div>
                      </div>
                      <div>
                        <div className="text-3xl font-bold text-[#f4ba1b] mb-1">24/7</div>
                        <div className="text-sm text-slate-300">Support</div>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Floating Elements */}
                <div className="absolute -top-4 -right-4 w-24 h-24 bg-[#f4ba1b] rounded-full opacity-20 blur-2xl" />
                <div className="absolute -bottom-4 -left-4 w-32 h-32 bg-indigo-500 rounded-full opacity-20 blur-2xl" />
              </div>
            </div>
          </div>
        </section>
      </main>
      <PublicFooter />
    </div>
  );
}

