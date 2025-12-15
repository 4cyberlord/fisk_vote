"use client";

import { useState, useMemo, useEffect, useRef } from "react";
import { createPortal } from "react-dom";
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
  RefreshCw,
} from "lucide-react";
import { PublicHeader } from "@/components/layout/PublicHeader";
import { PublicFooter } from "@/components/layout/PublicFooter";
import { Button } from "@/components";
import {
  useBlogPosts,
  useBlogCategories,
  useFeaturedPost,
  usePopularPosts,
  useRecentPosts,
  useSearchPosts,
} from "@/hooks/useBlogPosts";
import type { BlogCategory } from "@/types/blog";

// Icon mapping for categories
const categoryIconMap: Record<string, typeof Newspaper> = {
  "All": Newspaper,
  "Announcements": Bell,
  "Candidate Spotlights": Users,
  "Voting Guides": BookOpen,
  "Results": Award,
  "Campus News": FileText,
  "Student Features": TrendingUp,
};

export default function BlogPage() {
  const [activeCategory, setActiveCategory] = useState("All");
  const [searchQuery, setSearchQuery] = useState("");
  const [currentPage, setCurrentPage] = useState(1);
  const [showSearchSuggestions, setShowSearchSuggestions] = useState(false);
  const [dropdownPosition, setDropdownPosition] = useState({ top: 0, left: 0, width: 0 });
  const searchInputRef = useRef<HTMLInputElement>(null);
  const searchDropdownRef = useRef<HTMLDivElement>(null);
  const postsPerPage = 6;

  // Fetch data from API
  const { data: postsData, isLoading: postsLoading, error: postsError } = useBlogPosts({
    page: currentPage,
    per_page: postsPerPage,
    category: activeCategory !== "All" ? activeCategory : undefined,
    search: searchQuery || undefined,
  });

  const { data: categories = [], isLoading: categoriesLoading } = useBlogCategories();
  const { data: featuredPost, isLoading: featuredLoading } = useFeaturedPost();
  const { data: popularPosts = [] } = usePopularPosts(5);
  const { data: recentPosts = [] } = useRecentPosts(5);

  // Search suggestions for autocomplete
  const { data: searchSuggestionsData, isLoading: searchLoading } = useSearchPosts(
    searchQuery,
    { per_page: 5 }
  );
  const searchSuggestions = searchSuggestionsData?.data || [];

  // Show suggestions when user types and calculate position
  useEffect(() => {
    if (searchQuery.length > 0 && searchInputRef.current) {
      setShowSearchSuggestions(true);
      const rect = searchInputRef.current.getBoundingClientRect();
      setDropdownPosition({
        top: rect.bottom + window.scrollY + 8,
        left: rect.left + window.scrollX,
        width: rect.width,
      });
    } else {
      setShowSearchSuggestions(false);
    }
  }, [searchQuery]);

  // Update position on scroll/resize
  useEffect(() => {
    if (showSearchSuggestions && searchInputRef.current) {
      const updatePosition = () => {
        if (searchInputRef.current) {
          const rect = searchInputRef.current.getBoundingClientRect();
          setDropdownPosition({
            top: rect.bottom + window.scrollY + 8,
            left: rect.left + window.scrollX,
            width: rect.width,
          });
        }
      };

      window.addEventListener('scroll', updatePosition, true);
      window.addEventListener('resize', updatePosition);

      return () => {
        window.removeEventListener('scroll', updatePosition, true);
        window.removeEventListener('resize', updatePosition);
      };
    }
  }, [showSearchSuggestions]);

  // Close dropdown when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (
        searchDropdownRef.current &&
        !searchDropdownRef.current.contains(event.target as Node) &&
        searchInputRef.current &&
        !searchInputRef.current.contains(event.target as Node)
      ) {
        setShowSearchSuggestions(false);
      }
    };

    document.addEventListener("mousedown", handleClickOutside);
    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
    };
  }, []);

  // Combined loading state
  const isLoading = postsLoading || categoriesLoading || featuredLoading;

  // Check if we have no data (not an error, just empty)
  // If we successfully got data but it's empty, that's not an error
  const hasNoPosts = !isLoading && postsData && postsData.data.length === 0;
  // If we have an error but also have data (even if empty), don't treat it as an error
  // Only show error for actual API failures when we have no data at all
  const hasActualError = postsError && !isLoading && !postsData;
  
  // Determine if we should show content or empty state
  const showContent = !isLoading && !hasActualError && !hasNoPosts;

  // Build categories list with "All" option
  const categoriesWithAll = useMemo(() => {
    type CategoryWithIcon = Omit<BlogCategory, 'icon'> & { icon: typeof Newspaper };
    
    const allCategory: CategoryWithIcon = {
      id: 0,
      name: "All",
      slug: "all",
      is_active: true,
      post_count: postsData?.meta.total || 0,
      icon: Newspaper,
    };

    const categoryList: CategoryWithIcon[] = categories.map((cat) => ({
      ...cat,
      icon: categoryIconMap[cat.name] || Newspaper,
    }));

    return [allCategory, ...categoryList];
  }, [categories, postsData]);

  const paginatedPosts = postsData?.data || [];
  const totalPages = postsData?.meta.last_page || 1;

  const getCategoryIcon = (categoryName: string) => {
    const category = categoriesWithAll.find((cat) => cat.name === categoryName);
    return category?.icon || Newspaper;
  };

  return (
    <div className="min-h-screen bg-white text-slate-900 flex flex-col">
      <PublicHeader />
      <main className="flex-1">
        {/* Hero Section */}
        <section className="relative bg-gradient-to-br from-[#0a1a44] via-indigo-900 to-[#8b0000] text-white py-16 sm:py-20" style={{ zIndex: 1 }}>
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
              <div className="relative max-w-2xl mx-auto" style={{ zIndex: 9999 }}>
                <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400 z-10" />
                <input
                  ref={searchInputRef}
                  type="text"
                  placeholder="Search articles..."
                  value={searchQuery}
                  onChange={(e) => {
                    setSearchQuery(e.target.value);
                    setCurrentPage(1);
                  }}
                  onFocus={() => {
                    if (searchQuery.length > 0) {
                      setShowSearchSuggestions(true);
                    }
                  }}
                  onKeyDown={(e) => {
                    if (e.key === "Enter") {
                      setCurrentPage(1);
                      setShowSearchSuggestions(false);
                    } else if (e.key === "Escape") {
                      setShowSearchSuggestions(false);
                    }
                  }}
                  className="w-full pl-12 pr-4 py-3 rounded-xl bg-white/10 backdrop-blur-sm border border-white/20 text-white placeholder:text-slate-300 focus:outline-none focus:ring-2 focus:ring-[#f4ba1b] focus:border-transparent relative z-10"
                />
                
                {/* Search Suggestions Dropdown - Using Portal for proper z-index */}
                {showSearchSuggestions && searchQuery.length > 0 && typeof window !== 'undefined' && createPortal(
                  <div
                    ref={searchDropdownRef}
                    className="fixed bg-white rounded-xl shadow-2xl border border-slate-200 overflow-hidden max-h-96 overflow-y-auto"
                    style={{ 
                      zIndex: 99999, 
                      top: `${dropdownPosition.top}px`,
                      left: `${dropdownPosition.left}px`,
                      width: `${dropdownPosition.width}px`,
                    }}
                  >
                    {searchLoading ? (
                      <div className="p-4 text-center text-slate-600">
                        <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-[#f4ba1b] mx-auto"></div>
                        <p className="mt-2 text-sm">Searching...</p>
                      </div>
                    ) : searchSuggestions.length > 0 ? (
                      <>
                        <div className="px-4 py-2 bg-slate-50 border-b border-slate-200">
                          <p className="text-xs font-semibold text-slate-600 uppercase tracking-wide">
                            Search Results ({searchSuggestions.length})
                          </p>
                        </div>
                        <div className="divide-y divide-slate-100">
                          {searchSuggestions.map((post) => {
                            const CategoryIcon = getCategoryIcon(post.category.name);
                            return (
                              <Link
                                key={post.id}
                                href={`/blog/${post.id}`}
                                onClick={() => {
                                  setShowSearchSuggestions(false);
                                  setSearchQuery("");
                                }}
                                className="block p-4 hover:bg-slate-50 transition-colors group"
                              >
                                <div className="flex items-start gap-3">
                                  <div className="flex-shrink-0 w-12 h-12 rounded-lg overflow-hidden bg-slate-100">
                                    <img
                                      src={post.image || "https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=800&h=600&fit=crop"}
                                      alt={post.title}
                                      className="w-full h-full object-cover"
                                    />
                                  </div>
                                  <div className="flex-1 min-w-0">
                                    <div className="flex items-center gap-2 mb-1">
                                      <CategoryIcon className="w-3 h-3 text-[#f4ba1b] flex-shrink-0" />
                                      <span className="text-xs font-medium text-slate-500">
                                        {post.category.name}
                                      </span>
                                    </div>
                                    <h4 className="text-sm font-semibold text-slate-900 line-clamp-1 group-hover:text-[#f4ba1b] transition-colors">
                                      {post.title}
                                    </h4>
                                    <p className="text-xs text-slate-600 line-clamp-2 mt-1">
                                      {post.excerpt}
                                    </p>
                                    <div className="flex items-center gap-3 mt-2 text-xs text-slate-400">
                                      <span>{post.date}</span>
                                      <span>·</span>
                                      <span>{post.readTime}</span>
                                    </div>
                                  </div>
                                  <ArrowRight className="w-4 h-4 text-slate-400 group-hover:text-[#f4ba1b] group-hover:translate-x-1 transition-all flex-shrink-0" />
                                </div>
                              </Link>
                            );
                          })}
                        </div>
                        {searchSuggestionsData && searchSuggestionsData.meta.total > searchSuggestions.length && (
                          <div className="px-4 py-3 bg-slate-50 border-t border-slate-200">
                            <button
                              onClick={() => {
                                setCurrentPage(1);
                                setShowSearchSuggestions(false);
                              }}
                              className="text-sm font-medium text-[#f4ba1b] hover:text-[#e0a518] transition-colors"
                            >
                              View all {searchSuggestionsData.meta.total} results →
                            </button>
                          </div>
                        )}
                      </>
                    ) : (
                      <div className="p-6 text-center">
                        <Search className="w-8 h-8 text-slate-400 mx-auto mb-2" />
                        <p className="text-sm font-medium text-slate-900 mb-1">No results found</p>
                        <p className="text-xs text-slate-500">
                          Try a different search term
                        </p>
                      </div>
                    )}
                  </div>
                , document.body)}
              </div>
            </div>
          </div>
        </section>

        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12" style={{ zIndex: 1, position: 'relative' }}>
          {/* Loading State */}
          {isLoading && (
            <div className="text-center py-20">
              <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-[#f4ba1b] mx-auto mb-4"></div>
              <p className="text-slate-600">Loading blog posts...</p>
            </div>
          )}

          {/* Actual Error State (API failure) */}
          {hasActualError && (
            <div className="text-center py-20">
              <div className="max-w-md mx-auto">
                <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-red-100 flex items-center justify-center">
                  <svg className="w-8 h-8 text-red-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                  </svg>
                </div>
                <h3 className="text-xl font-bold text-slate-900 mb-2">Something went wrong</h3>
                <p className="text-slate-600 mb-6">We couldn't load the blog posts. Please try again later.</p>
                <button
                  onClick={() => window.location.reload()}
                  className="group inline-flex items-center gap-2 px-6 py-3 bg-[#f4ba1b] hover:bg-[#e0a518] text-slate-900 font-semibold rounded-xl shadow-md hover:shadow-lg transition-all duration-300 hover:scale-105 active:scale-95"
                >
                  <RefreshCw className="w-5 h-5 group-hover:rotate-180 transition-transform duration-500" />
                  <span>Retry</span>
                </button>
              </div>
            </div>
          )}

          {/* Featured Post */}
          {showContent && featuredPost && (
            <section className="mb-16" style={{ zIndex: 1, position: 'relative' }}>
              <Link href={`/blog/${featuredPost.id}`} className="block">
              <div className="relative rounded-3xl overflow-hidden shadow-2xl group cursor-pointer">
                <div className="absolute inset-0 bg-gradient-to-r from-slate-900/90 via-slate-800/80 to-slate-900/90 z-10" />
                  <img
                    src={featuredPost.image || "https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=800&h=600&fit=crop"}
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
                      <div className="flex items-center gap-4 text-sm text-slate-300 mb-6">
                        <div className="flex items-center gap-2">
                          <img
                            src={featuredPost.author.avatar}
                            alt={featuredPost.author.name}
                            className="w-7 h-7 rounded-full ring-2 ring-white/20"
                          />
                          <span>{featuredPost.author.name}</span>
                        </div>
                        <span className="text-white/40">·</span>
                        <span>{featuredPost.date}</span>
                        <span className="text-white/40">·</span>
                        <span>{featuredPost.readTime} read</span>
                      </div>
                      <div className="group/btn relative inline-flex items-center gap-3 px-8 py-4 bg-white text-slate-900 font-bold text-sm sm:text-base rounded-xl shadow-lg hover:shadow-xl transition-all duration-300 hover:scale-105 overflow-hidden">
                        {/* Animated background gradient */}
                        <span className="absolute inset-0 bg-gradient-to-r from-[#f4ba1b] to-amber-400 opacity-0 group-hover/btn:opacity-100 transition-opacity duration-300" />
                        
                        {/* Content */}
                        <span className="relative z-10 flex items-center gap-3">
                          <span className="text-slate-900 group-hover/btn:text-white transition-colors duration-300">
                            Read Article
                          </span>
                          <div className="relative w-6 h-6 flex items-center justify-center">
                            <ArrowRight className="w-5 h-5 text-slate-900 group-hover/btn:text-white group-hover/btn:translate-x-1 transition-all duration-300" />
                            <ArrowRight className="absolute w-5 h-5 text-slate-900 group-hover/btn:text-white opacity-0 group-hover/btn:opacity-100 -translate-x-2 group-hover/btn:translate-x-0 transition-all duration-300" />
                          </div>
                        </span>
                        
                        {/* Shine effect */}
                        <span className="absolute inset-0 -translate-x-full group-hover/btn:translate-x-full transition-transform duration-700 bg-gradient-to-r from-transparent via-white/20 to-transparent" />
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </Link>
          </section>
          )}

          {showContent && (
            <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
            {/* Main Content */}
            <div className="lg:col-span-3">
              {/* Category Filter Tabs */}
              <section className="mb-8">
                <div className="flex flex-wrap items-center gap-2 border-b border-slate-200 pb-4">
                  {categoriesWithAll.map((category) => {
                    const Icon = category.icon;
                    return (
                      <button
                        key={category.id}
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
                        <span className="text-xs opacity-75">({category.post_count})</span>
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
                      const CategoryIcon = getCategoryIcon(post.category.name);
                      return (
                        <Link key={post.id} href={`/blog/${post.id}`} className="block">
                          <article className="group bg-white border border-slate-200 rounded-2xl overflow-hidden hover:shadow-xl transition-all duration-300 cursor-pointer h-full">
                            <div className="relative h-48 overflow-hidden">
                              <img
                                src={post.image || "https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=800&h=600&fit=crop"}
                                alt={post.title}
                                className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500"
                              />
                              <div className="absolute top-4 left-4">
                                <div className="flex items-center gap-2 px-3 py-1 rounded-full bg-white/90 backdrop-blur-sm text-xs font-semibold text-slate-900">
                                  <CategoryIcon className="w-3 h-3" />
                                  {post.category.name}
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
                              <div className="flex items-center gap-4 text-xs text-slate-500 mb-4">
                                <div className="flex items-center gap-1.5">
                                  <img
                                    src={post.author.avatar}
                                    alt={post.author.name}
                                    className="w-5 h-5 rounded-full"
                                  />
                                  <span>{post.author.name}</span>
                                </div>
                                <span className="text-slate-300">·</span>
                                <span>{post.date}</span>
                                <span className="text-slate-300">·</span>
                                <span>{post.readTime} read</span>
                              </div>
                              <div className="group/link inline-flex items-center gap-2 text-sm font-bold text-[#f4ba1b] hover:text-[#e0a518] transition-all">
                                <span>Read more</span>
                                <div className="relative w-5 h-5 flex items-center justify-center">
                                  <ArrowRight className="w-4 h-4 transition-transform duration-300 group-hover/link:translate-x-1" />
                                  <ArrowRight className="absolute w-4 h-4 opacity-0 group-hover/link:opacity-100 -translate-x-2 group-hover/link:translate-x-0 transition-all duration-300" />
                                </div>
                              </div>
                            </div>
                          </article>
                        </Link>
                      );
                    })}
                  </div>
                ) : !isLoading && postsData && postsData.data.length === 0 ? (
                  <div className="text-center py-16">
                    <div className="max-w-md mx-auto">
                      <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-slate-100 flex items-center justify-center">
                        <Search className="w-8 h-8 text-slate-400" />
                      </div>
                      <h3 className="text-xl font-bold text-slate-900 mb-2">No Data found</h3>
                      <p className="text-slate-600 mb-4">
                        {searchQuery
                          ? `No blog posts found for "${searchQuery}". Try a different search term.`
                          : activeCategory !== "All"
                          ? `No blog posts found in the "${activeCategory}" category.`
                          : "No blog posts available at the moment."}
                      </p>
                      {(searchQuery || activeCategory !== "All") && (
                        <button
                          onClick={() => {
                            setSearchQuery("");
                            setActiveCategory("All");
                            setCurrentPage(1);
                          }}
                          className="inline-flex items-center gap-2 px-6 py-3 bg-[#f4ba1b] hover:bg-[#e0a518] text-slate-900 font-semibold rounded-xl shadow-md hover:shadow-lg transition-all duration-300"
                        >
                          <span>Clear filters</span>
                        </button>
                      )}
                    </div>
                  </div>
                ) : null}

                {/* Pagination */}
                {paginatedPosts.length > 0 && totalPages > 1 && (
                  <div className="flex items-center justify-center gap-2 mt-8">
                    <button
                      onClick={() => setCurrentPage((prev) => Math.max(1, prev - 1))}
                      disabled={currentPage === 1 || isLoading}
                      className="px-4 py-2 rounded-lg border border-slate-300 text-sm font-medium text-slate-700 hover:bg-slate-50 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                    >
                      Previous
                    </button>
                    {Array.from({ length: Math.min(totalPages, 10) }, (_, i) => {
                      let page;
                      if (totalPages <= 10) {
                        page = i + 1;
                      } else if (currentPage <= 5) {
                        page = i + 1;
                      } else if (currentPage >= totalPages - 4) {
                        page = totalPages - 9 + i;
                      } else {
                        page = currentPage - 4 + i;
                      }
                      return (
                        <button
                          key={page}
                          onClick={() => setCurrentPage(page)}
                          disabled={isLoading}
                          className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                            currentPage === page
                              ? "bg-[#f4ba1b] text-slate-900 shadow-md"
                              : "border border-slate-300 text-slate-700 hover:bg-slate-50"
                          }`}
                        >
                          {page}
                        </button>
                      );
                    })}
                    <button
                      onClick={() => setCurrentPage((prev) => Math.min(totalPages, prev + 1))}
                      disabled={currentPage === totalPages || isLoading}
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
                  {categoriesWithAll.slice(1).map((category) => {
                    const Icon = category.icon;
                    return (
                      <li key={category.id}>
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
                          <span className="text-xs opacity-75">({category.post_count})</span>
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
                          src={post.image || "https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=800&h=600&fit=crop"}
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
          )}
        </div>
      </main>
      <PublicFooter />
    </div>
  );
}

