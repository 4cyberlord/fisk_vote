"use client";

import { useState } from "react";
import Link from "next/link";
import {
  Search,
  Calendar,
  Clock,
  User,
  ArrowRight,
  TrendingUp,
  BookOpen,
  Newspaper,
  Users,
  FileText,
  Award,
  Bell,
} from "lucide-react";
import { PublicHeader } from "@/components/layout/PublicHeader";
import { PublicFooter } from "@/components/layout/PublicFooter";
import { Button } from "@/components";

// Mock data for blog posts
const mockPosts = [
  {
    id: 1,
    title: "Student Government Elections 2024: Everything You Need to Know",
    excerpt:
      "Get ready for the most important election of the year. Learn about the candidates, voting dates, and how to make your voice heard.",
    category: "Announcements",
    author: {
      name: "Election Committee",
      avatar: "https://i.pravatar.cc/150?img=12",
    },
    date: "March 15, 2024",
    readTime: "5 min read",
    image: "https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=800&h=600&fit=crop",
    featured: true,
  },
  {
    id: 2,
    title: "Meet the Candidates: Student Body President Race",
    excerpt:
      "An in-depth look at the three candidates running for Student Body President and their visions for campus.",
    category: "Candidate Spotlights",
    author: {
      name: "Sarah Johnson",
      avatar: "https://i.pravatar.cc/150?img=33",
    },
    date: "March 12, 2024",
    readTime: "8 min read",
    image: "https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=800&h=600&fit=crop",
    featured: false,
  },
  {
    id: 3,
    title: "How to Vote: A Complete Guide for First-Time Voters",
    excerpt:
      "New to campus elections? This comprehensive guide walks you through the entire voting process step by step.",
    category: "Voting Guides",
    author: {
      name: "Campus Elections Office",
      avatar: "https://i.pravatar.cc/150?img=45",
    },
    date: "March 10, 2024",
    readTime: "6 min read",
    image: "https://images.unsplash.com/photo-1557804506-669a67965ba0?w=800&h=600&fit=crop",
    featured: false,
  },
  {
    id: 4,
    title: "Election Results: Class Representatives Announced",
    excerpt:
      "The votes are in! See who won the class representative positions and what this means for student governance.",
    category: "Results",
    author: {
      name: "Election Committee",
      avatar: "https://i.pravatar.cc/150?img=12",
    },
    date: "March 8, 2024",
    readTime: "4 min read",
    image: "https://images.unsplash.com/photo-1552664730-d307ca884978?w=800&h=600&fit=crop",
    featured: false,
  },
  {
    id: 5,
    title: "Campus News: New Voting Policies for 2024",
    excerpt:
      "Important updates to election policies that all students should be aware of before casting their votes.",
    category: "Campus News",
    author: {
      name: "Administration",
      avatar: "https://i.pravatar.cc/150?img=67",
    },
    date: "March 5, 2024",
    readTime: "7 min read",
    image: "https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=800&h=600&fit=crop",
    featured: false,
  },
  {
    id: 6,
    title: "Student Spotlight: Meet the Rising Leaders",
    excerpt:
      "Get to know the students who are making a difference on campus and running for leadership positions.",
    category: "Student Features",
    author: {
      name: "Campus Media",
      avatar: "https://i.pravatar.cc/150?img=23",
    },
    date: "March 3, 2024",
    readTime: "9 min read",
    image: "https://images.unsplash.com/photo-1524178232363-1fb2b075b655?w=800&h=600&fit=crop",
    featured: false,
  },
  {
    id: 7,
    title: "Ranked Choice Voting Explained",
    excerpt:
      "Understanding how ranked choice voting works and why it's being used in this year's elections.",
    category: "Voting Guides",
    author: {
      name: "Election Committee",
      avatar: "https://i.pravatar.cc/150?img=12",
    },
    date: "March 1, 2024",
    readTime: "5 min read",
    image: "https://images.unsplash.com/photo-1556761175-5973dc0f32e7?w=800&h=600&fit=crop",
    featured: false,
  },
  {
    id: 8,
    title: "Election Day Reminders and Important Dates",
    excerpt:
      "Mark your calendars! Here are all the important dates and deadlines you need to know for the upcoming elections.",
    category: "Announcements",
    author: {
      name: "Election Committee",
      avatar: "https://i.pravatar.cc/150?img=12",
    },
    date: "February 28, 2024",
    readTime: "3 min read",
    image: "https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=800&h=600&fit=crop",
    featured: false,
  },
  {
    id: 9,
    title: "Behind the Scenes: How Votes Are Counted",
    excerpt:
      "A transparent look at the secure voting process and how we ensure every vote is counted accurately.",
    category: "Campus News",
    author: {
      name: "Election Committee",
      avatar: "https://i.pravatar.cc/150?img=12",
    },
    date: "February 25, 2024",
    readTime: "6 min read",
    image: "https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800&h=600&fit=crop",
    featured: false,
  },
];

const categories = [
  { name: "All", icon: Newspaper, count: 9 },
  { name: "Announcements", icon: Bell, count: 2 },
  { name: "Candidate Spotlights", icon: Users, count: 1 },
  { name: "Voting Guides", icon: BookOpen, count: 2 },
  { name: "Results", icon: Award, count: 1 },
  { name: "Campus News", icon: FileText, count: 2 },
  { name: "Student Features", icon: TrendingUp, count: 1 },
];

const recentPosts = mockPosts.slice(0, 5);
const popularPosts = [mockPosts[1], mockPosts[2], mockPosts[4], mockPosts[5], mockPosts[0]];

export default function BlogPage() {
  const [activeCategory, setActiveCategory] = useState("All");
  const [searchQuery, setSearchQuery] = useState("");
  const [currentPage, setCurrentPage] = useState(1);
  const postsPerPage = 6;

  const featuredPost = mockPosts.find((post) => post.featured) || mockPosts[0];
  const regularPosts = mockPosts.filter((post) => !post.featured);

  // Filter posts by category
  const filteredPosts =
    activeCategory === "All"
      ? regularPosts
      : regularPosts.filter((post) => post.category === activeCategory);

  // Filter by search query
  const searchFilteredPosts = searchQuery
    ? filteredPosts.filter(
        (post) =>
          post.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
          post.excerpt.toLowerCase().includes(searchQuery.toLowerCase())
      )
    : filteredPosts;

  // Pagination
  const totalPages = Math.ceil(searchFilteredPosts.length / postsPerPage);
  const paginatedPosts = searchFilteredPosts.slice(
    (currentPage - 1) * postsPerPage,
    currentPage * postsPerPage
  );

  const getCategoryIcon = (categoryName: string) => {
    const category = categories.find((cat) => cat.name === categoryName);
    return category?.icon || Newspaper;
  };

  return (
    <div className="min-h-screen bg-white text-slate-900 flex flex-col">
      <PublicHeader />
      <main className="flex-1">
        {/* Hero Section */}
        <section className="relative overflow-hidden bg-gradient-to-br from-[#0a1a44] via-indigo-900 to-[#8b0000] text-white py-16 sm:py-20">
          {/* Background Pattern Overlay */}
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
          
          {/* Background Image Overlay */}
          <div
            className="absolute inset-0 opacity-20 mix-blend-soft-light"
            style={{
              backgroundImage:
                "url('https://images.pexels.com/photos/15953878/pexels-photo-15953878.jpeg?auto=compress&cs=tinysrgb&w=1200')",
              backgroundSize: "cover",
              backgroundPosition: "center",
            }}
          />
          
          <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="text-center max-w-3xl mx-auto">
              {/* Badge */}
              <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-[#f4ba1b]/20 backdrop-blur-sm border border-[#f4ba1b]/30 mb-6">
                <Newspaper className="w-4 h-4 text-[#f4ba1b]" />
                <span className="text-sm font-semibold text-[#f4ba1b]">Latest Updates</span>
              </div>
              
              <h1 className="text-4xl sm:text-5xl lg:text-6xl font-extrabold mb-4 leading-tight">
                Blog &amp; News
              </h1>
              <p className="text-lg sm:text-xl text-slate-100 mb-8 max-w-2xl mx-auto">
                Stay informed about campus elections, candidates, and voting updates
              </p>

              {/* Search Bar */}
              <div className="relative max-w-2xl mx-auto">
                <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
                <input
                  type="text"
                  placeholder="Search articles..."
                  value={searchQuery}
                  onChange={(e) => {
                    setSearchQuery(e.target.value);
                    setCurrentPage(1);
                  }}
                  className="w-full pl-12 pr-4 py-3 rounded-xl bg-white/10 backdrop-blur-sm border border-white/20 text-white placeholder:text-slate-300 focus:outline-none focus:ring-2 focus:ring-[#f4ba1b] focus:border-transparent"
                />
              </div>
            </div>
          </div>
        </section>

        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
          {/* Featured Post */}
          <section className="mb-16">
            <div className="relative rounded-3xl overflow-hidden shadow-2xl group">
              <div className="absolute inset-0 bg-gradient-to-r from-slate-900/90 via-slate-800/80 to-slate-900/90 z-10" />
              <img
                src={featuredPost.image}
                alt={featuredPost.title}
                className="w-full h-[400px] sm:h-[500px] object-cover group-hover:scale-105 transition-transform duration-500"
              />
              <div className="absolute inset-0 z-20 flex items-end">
                <div className="w-full p-8 sm:p-12">
                  <div className="max-w-3xl">
                    <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#f4ba1b] text-xs font-semibold text-slate-900 mb-4">
                      <span>⭐</span>
                      Featured
                    </div>
                    <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-white mb-4 leading-tight">
                      {featuredPost.title}
                    </h2>
                    <p className="text-lg text-slate-200 mb-6 line-clamp-2">
                      {featuredPost.excerpt}
                    </p>
                    <div className="flex flex-wrap items-center gap-4 text-sm text-slate-300 mb-6">
                      <div className="flex items-center gap-2">
                        <img
                          src={featuredPost.author.avatar}
                          alt={featuredPost.author.name}
                          className="w-8 h-8 rounded-full"
                        />
                        <span>{featuredPost.author.name}</span>
                      </div>
                      <div className="flex items-center gap-1">
                        <Calendar className="w-4 h-4" />
                        <span>{featuredPost.date}</span>
                      </div>
                      <div className="flex items-center gap-1">
                        <Clock className="w-4 h-4" />
                        <span>{featuredPost.readTime}</span>
                      </div>
                    </div>
                    <Link href={`/blog/${featuredPost.id}`}>
                      <button className="group relative inline-flex items-center gap-3 px-8 py-4 bg-white text-slate-900 font-bold text-sm sm:text-base rounded-xl shadow-lg hover:shadow-xl transition-all duration-300 hover:scale-105 overflow-hidden">
                        {/* Animated background gradient */}
                        <span className="absolute inset-0 bg-gradient-to-r from-[#f4ba1b] to-amber-400 opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
                        
                        {/* Content */}
                        <span className="relative z-10 flex items-center gap-3">
                          <span className="text-slate-900 group-hover:text-white transition-colors duration-300">
                            Read Article
                          </span>
                          <div className="relative w-6 h-6 flex items-center justify-center">
                            <ArrowRight className="w-5 h-5 text-slate-900 group-hover:text-white group-hover:translate-x-1 transition-all duration-300" />
                            <ArrowRight className="absolute w-5 h-5 text-slate-900 group-hover:text-white opacity-0 group-hover:opacity-100 -translate-x-2 group-hover:translate-x-0 transition-all duration-300" />
                          </div>
                        </span>
                        
                        {/* Shine effect */}
                        <span className="absolute inset-0 -translate-x-full group-hover:translate-x-full transition-transform duration-700 bg-gradient-to-r from-transparent via-white/20 to-transparent" />
                      </button>
                    </Link>
                  </div>
                </div>
              </div>
            </div>
          </section>

          <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
            {/* Main Content */}
            <div className="lg:col-span-3">
              {/* Category Filter Tabs */}
              <section className="mb-8">
                <div className="flex flex-wrap items-center gap-2 border-b border-slate-200 pb-4">
                  {categories.map((category) => {
                    const Icon = category.icon;
                    return (
                      <button
                        key={category.name}
                        onClick={() => {
                          setActiveCategory(category.name);
                          setCurrentPage(1);
                        }}
                        className={`flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium transition-all ${
                          activeCategory === category.name
                            ? "bg-[#f4ba1b] text-slate-900 shadow-md"
                            : "bg-slate-100 text-slate-600 hover:bg-slate-200"
                        }`}
                      >
                        <Icon className="w-4 h-4" />
                        {category.name}
                        <span className="text-xs opacity-75">({category.count})</span>
                      </button>
                    );
                  })}
                </div>
              </section>

              {/* Posts Grid */}
              <section>
                {paginatedPosts.length > 0 ? (
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
                    {paginatedPosts.map((post) => {
                      const CategoryIcon = getCategoryIcon(post.category);
                      return (
                        <article
                          key={post.id}
                          className="group bg-white border border-slate-200 rounded-2xl overflow-hidden hover:shadow-xl transition-all duration-300"
                        >
                          <div className="relative h-48 overflow-hidden">
                            <img
                              src={post.image}
                              alt={post.title}
                              className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500"
                            />
                            <div className="absolute top-4 left-4">
                              <div className="flex items-center gap-2 px-3 py-1 rounded-full bg-white/90 backdrop-blur-sm text-xs font-semibold text-slate-900">
                                <CategoryIcon className="w-3 h-3" />
                                {post.category}
                              </div>
                            </div>
                          </div>
                          <div className="p-6">
                            <h3 className="text-xl font-bold text-slate-900 mb-2 line-clamp-2 group-hover:text-[#f4ba1b] transition-colors">
                              {post.title}
                            </h3>
                            <p className="text-sm text-slate-600 mb-4 line-clamp-3">
                              {post.excerpt}
                            </p>
                            <div className="flex items-center justify-between text-xs text-slate-500 mb-4">
                              <div className="flex items-center gap-3">
                                <div className="flex items-center gap-2">
                                  <img
                                    src={post.author.avatar}
                                    alt={post.author.name}
                                    className="w-6 h-6 rounded-full"
                                  />
                                  <span>{post.author.name}</span>
                                </div>
                                <span>•</span>
                                <div className="flex items-center gap-1">
                                  <Calendar className="w-3 h-3" />
                                  <span>{post.date}</span>
                                </div>
                              </div>
                              <div className="flex items-center gap-1">
                                <Clock className="w-3 h-3" />
                                <span>{post.readTime}</span>
                              </div>
                            </div>
                            <Link
                              href={`/blog/${post.id}`}
                              className="group/link inline-flex items-center gap-2 text-sm font-bold text-[#f4ba1b] hover:text-[#e0a518] transition-all"
                            >
                              <span>Read more</span>
                              <div className="relative w-5 h-5 flex items-center justify-center">
                                <ArrowRight className="w-4 h-4 transition-transform duration-300 group-hover/link:translate-x-1" />
                                <ArrowRight className="absolute w-4 h-4 opacity-0 group-hover/link:opacity-100 -translate-x-2 group-hover/link:translate-x-0 transition-all duration-300" />
                              </div>
                            </Link>
                          </div>
                        </article>
                      );
                    })}
                  </div>
                ) : (
                  <div className="text-center py-16">
                    <FileText className="w-16 h-16 mx-auto text-slate-300 mb-4" />
                    <p className="text-lg font-semibold text-slate-900 mb-2">
                      No posts found
                    </p>
                    <p className="text-sm text-slate-500">
                      Try adjusting your search or filter criteria
                    </p>
                  </div>
                )}

                {/* Pagination */}
                {totalPages > 1 && (
                  <div className="flex items-center justify-center gap-2 mt-8">
                    <button
                      onClick={() => setCurrentPage((prev) => Math.max(1, prev - 1))}
                      disabled={currentPage === 1}
                      className="px-4 py-2 rounded-lg border border-slate-300 text-sm font-medium text-slate-700 hover:bg-slate-50 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                    >
                      Previous
                    </button>
                    {Array.from({ length: totalPages }, (_, i) => i + 1).map((page) => (
                      <button
                        key={page}
                        onClick={() => setCurrentPage(page)}
                        className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                          currentPage === page
                            ? "bg-[#f4ba1b] text-slate-900 shadow-md"
                            : "border border-slate-300 text-slate-700 hover:bg-slate-50"
                        }`}
                      >
                        {page}
                      </button>
                    ))}
                    <button
                      onClick={() => setCurrentPage((prev) => Math.min(totalPages, prev + 1))}
                      disabled={currentPage === totalPages}
                      className="px-4 py-2 rounded-lg border border-slate-300 text-sm font-medium text-slate-700 hover:bg-slate-50 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                    >
                      Next
                    </button>
                  </div>
                )}
              </section>
            </div>

            {/* Sidebar */}
            <aside className="lg:col-span-1 space-y-6">
              {/* Categories */}
              <div className="bg-slate-50 border border-slate-200 rounded-2xl p-6">
                <h3 className="text-lg font-bold text-slate-900 mb-4 flex items-center gap-2">
                  <BookOpen className="w-5 h-5 text-[#f4ba1b]" />
                  Categories
                </h3>
                <ul className="space-y-2">
                  {categories.slice(1).map((category) => {
                    const Icon = category.icon;
                    return (
                      <li key={category.name}>
                        <button
                          onClick={() => {
                            setActiveCategory(category.name);
                            setCurrentPage(1);
                          }}
                          className={`w-full flex items-center justify-between px-3 py-2 rounded-lg text-sm transition-all ${
                            activeCategory === category.name
                              ? "bg-[#f4ba1b] text-slate-900 font-semibold"
                              : "text-slate-600 hover:bg-slate-100"
                          }`}
                        >
                          <div className="flex items-center gap-2">
                            <Icon className="w-4 h-4" />
                            <span>{category.name}</span>
                          </div>
                          <span className="text-xs opacity-75">({category.count})</span>
                        </button>
                      </li>
                    );
                  })}
                </ul>
              </div>

              {/* Recent Posts */}
              <div className="bg-slate-50 border border-slate-200 rounded-2xl p-6">
                <h3 className="text-lg font-bold text-slate-900 mb-4 flex items-center gap-2">
                  <Clock className="w-5 h-5 text-[#f4ba1b]" />
                  Recent Posts
                </h3>
                <ul className="space-y-4">
                  {recentPosts.map((post) => (
                    <li key={post.id}>
                      <Link
                        href={`/blog/${post.id}`}
                        className="group flex items-start gap-3 hover:opacity-80 transition-opacity"
                      >
                        <img
                          src={post.image}
                          alt={post.title}
                          className="w-16 h-16 rounded-lg object-cover flex-shrink-0"
                        />
                        <div className="flex-1 min-w-0">
                          <h4 className="text-sm font-semibold text-slate-900 line-clamp-2 group-hover:text-[#f4ba1b] transition-colors">
                            {post.title}
                          </h4>
                          <p className="text-xs text-slate-500 mt-1">{post.date}</p>
                        </div>
                      </Link>
                    </li>
                  ))}
                </ul>
              </div>

              {/* Popular Posts */}
              <div className="bg-slate-50 border border-slate-200 rounded-2xl p-6">
                <h3 className="text-lg font-bold text-slate-900 mb-4 flex items-center gap-2">
                  <TrendingUp className="w-5 h-5 text-[#f4ba1b]" />
                  Popular Posts
                </h3>
                <ul className="space-y-4">
                  {popularPosts.map((post, index) => (
                    <li key={post.id}>
                      <Link
                        href={`/blog/${post.id}`}
                        className="group flex items-start gap-3 hover:opacity-80 transition-opacity"
                      >
                        <div className="flex-shrink-0 w-8 h-8 rounded-full bg-[#f4ba1b]/20 flex items-center justify-center text-xs font-bold text-[#b48100]">
                          {index + 1}
                        </div>
                        <div className="flex-1 min-w-0">
                          <h4 className="text-sm font-semibold text-slate-900 line-clamp-2 group-hover:text-[#f4ba1b] transition-colors">
                            {post.title}
                          </h4>
                          <p className="text-xs text-slate-500 mt-1">{post.readTime}</p>
                        </div>
                      </Link>
                    </li>
                  ))}
                </ul>
              </div>

              {/* Newsletter Signup */}
              <div className="bg-gradient-to-br from-indigo-600 to-indigo-700 rounded-2xl p-6 text-white">
                <Bell className="w-8 h-8 mb-4 text-indigo-200" />
                <h3 className="text-lg font-bold mb-2">Stay Updated</h3>
                <p className="text-sm text-indigo-100 mb-4">
                  Get the latest election news and updates delivered to your inbox.
                </p>
                <div className="space-y-3">
                  <input
                    type="email"
                    placeholder="Enter your email"
                    className="w-full px-4 py-2 rounded-lg bg-white/10 backdrop-blur-sm border border-white/20 text-white placeholder:text-indigo-200 focus:outline-none focus:ring-2 focus:ring-white/50"
                  />
                  <Button className="w-full bg-white text-indigo-600 hover:bg-indigo-50 font-semibold">
                    Subscribe
                  </Button>
                </div>
              </div>
            </aside>
          </div>
        </div>
      </main>
      <PublicFooter />
    </div>
  );
}

