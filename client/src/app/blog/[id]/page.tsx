"use client";

import { useParams } from "next/navigation";
import Link from "next/link";
import {
  Calendar,
  Clock,
  ArrowLeft,
  Share2,
  Facebook,
  Twitter,
  Linkedin,
  Mail,
  BookOpen,
  User,
} from "lucide-react";
import { PublicHeader } from "@/components/layout/PublicHeader";
import { PublicFooter } from "@/components/layout/PublicFooter";
import { Button } from "@/components";
import { useBlogPost, useRelatedPosts, useRecentPosts } from "@/hooks/useBlogPosts";
import type { BlogPost } from "@/types/blog";

export default function BlogPostPage() {
  const params = useParams();
  const postId = params?.id ? (typeof params.id === 'string' ? params.id : String(params.id)) : null;

  const { data: post, isLoading, error } = useBlogPost(postId);
  const { data: relatedPosts = [] } = useRelatedPosts(post ? post.id : null, 3);
  const { data: recentPosts = [] } = useRecentPosts(3, post ? post.id : undefined);

  // Category icon mapping
  const categoryIconMap: Record<string, typeof BookOpen> = {
    "Announcements": BookOpen,
    "Candidate Spotlights": User,
    "Voting Guides": BookOpen,
    "Results": BookOpen,
    "Campus News": BookOpen,
    "Student Features": BookOpen,
  };

  const getCategoryIcon = (categoryName: string) => {
    return categoryIconMap[categoryName] || BookOpen;
  };

  const handleShare = (platform: string) => {
    if (!post) return;

    const url = window.location.href;
    const title = post.title;
    const text = post.excerpt;

    switch (platform) {
      case "facebook":
        window.open(
          `https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(url)}`,
          "_blank"
        );
        break;
      case "twitter":
        window.open(
          `https://twitter.com/intent/tweet?url=${encodeURIComponent(url)}&text=${encodeURIComponent(title)}`,
          "_blank"
        );
        break;
      case "linkedin":
        window.open(
          `https://www.linkedin.com/sharing/share-offsite/?url=${encodeURIComponent(url)}`,
          "_blank"
        );
        break;
      case "email":
        window.location.href = `mailto:?subject=${encodeURIComponent(title)}&body=${encodeURIComponent(text + "\n\n" + url)}`;
        break;
      case "copy":
        navigator.clipboard.writeText(url);
        // You could add a toast notification here
        break;
    }
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-white text-slate-900 flex flex-col">
        <PublicHeader />
        <main className="flex-1">
          <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
            <div className="animate-pulse space-y-6">
              <div className="h-8 bg-gray-200 rounded w-1/4"></div>
              <div className="h-64 bg-gray-200 rounded"></div>
              <div className="h-8 bg-gray-200 rounded w-1/2"></div>
              <div className="space-y-4">
                <div className="h-4 bg-gray-200 rounded"></div>
                <div className="h-4 bg-gray-200 rounded"></div>
                <div className="h-4 bg-gray-200 rounded w-5/6"></div>
              </div>
            </div>
          </div>
        </main>
        <PublicFooter />
      </div>
    );
  }

  if (!post) {
    return (
      <div className="min-h-screen bg-white text-slate-900 flex flex-col">
        <PublicHeader />
        <main className="flex-1">
          <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
            <div className="text-center">
              <h1 className="text-3xl font-bold text-slate-900 mb-4">Post Not Found</h1>
              <p className="text-slate-600 mb-8">
                The blog post you're looking for doesn't exist or has been removed.
              </p>
              <Link href="/blog">
                <Button>Back to Blog</Button>
              </Link>
            </div>
          </div>
        </main>
        <PublicFooter />
      </div>
    );
  }

  const CategoryIcon = getCategoryIcon(post.category.name);

  return (
    <div className="min-h-screen bg-white text-slate-900 flex flex-col">
      <PublicHeader />
      <main className="flex-1">
        {/* Hero Image Section */}
        <section className="relative h-[400px] sm:h-[500px] overflow-hidden">
          <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-black/20 to-transparent z-10" />
          <img
            src={post.image || "https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=800&h=600&fit=crop"}
            alt={post.title}
            className="w-full h-full object-cover"
          />
          
          {/* Back Button */}
          <div className="absolute top-6 left-4 sm:left-8 z-20">
            <Link
              href="/blog"
              className="inline-flex items-center gap-2 px-4 py-2 bg-white rounded-lg text-slate-900 font-medium hover:bg-slate-50 transition-colors shadow-md"
            >
              <ArrowLeft className="w-4 h-4" />
              Back to Blog
            </Link>
          </div>

          {/* Category Badge */}
          <div className="absolute top-6 right-4 sm:right-8 z-20">
            <div className="inline-flex items-center gap-2 px-4 py-2 bg-[#f4ba1b] rounded-lg text-slate-900 font-semibold shadow-lg">
              <CategoryIcon className="w-4 h-4" />
              {post.category.name}
            </div>
          </div>

          {/* Title Overlay */}
          <div className="absolute bottom-0 left-0 right-0 z-20 p-6 sm:p-8 lg:p-12">
            <div className="max-w-4xl mx-auto">
              <h1 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold text-white mb-4 leading-tight">
                {post.title}
              </h1>
              <div className="flex flex-wrap items-center gap-4 text-white/90 text-sm sm:text-base">
                <div className="flex items-center gap-2">
                  <img
                    src={post.author.avatar}
                    alt={post.author.name}
                    className="w-8 h-8 rounded-full border-2 border-white/50"
                  />
                  <span className="font-medium">{post.author.name}</span>
                </div>
                <div className="flex items-center gap-1">
                  <Calendar className="w-4 h-4" />
                  <span>{post.date}</span>
                </div>
                <div className="flex items-center gap-1">
                  <Clock className="w-4 h-4" />
                  <span>{post.readTime}</span>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Main Content */}
        <article className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8 sm:py-12">
          {/* Share Buttons */}
          <div className="mb-8 pb-8 border-b border-slate-200">
            <div className="flex flex-wrap items-center gap-4">
              <span className="text-sm font-semibold text-slate-600">Share this article:</span>
              <div className="flex items-center gap-2">
                <button
                  onClick={() => handleShare("facebook")}
                  className="p-2 rounded-lg bg-blue-100 text-blue-600 hover:bg-blue-200 transition-colors"
                  aria-label="Share on Facebook"
                >
                  <Facebook className="w-5 h-5" />
                </button>
                <button
                  onClick={() => handleShare("twitter")}
                  className="p-2 rounded-lg bg-sky-100 text-sky-600 hover:bg-sky-200 transition-colors"
                  aria-label="Share on Twitter"
                >
                  <Twitter className="w-5 h-5" />
                </button>
                <button
                  onClick={() => handleShare("linkedin")}
                  className="p-2 rounded-lg bg-indigo-100 text-indigo-600 hover:bg-indigo-200 transition-colors"
                  aria-label="Share on LinkedIn"
                >
                  <Linkedin className="w-5 h-5" />
                </button>
                <button
                  onClick={() => handleShare("email")}
                  className="p-2 rounded-lg bg-slate-100 text-slate-600 hover:bg-slate-200 transition-colors"
                  aria-label="Share via Email"
                >
                  <Mail className="w-5 h-5" />
                </button>
                <button
                  onClick={() => handleShare("copy")}
                  className="p-2 rounded-lg bg-slate-100 text-slate-600 hover:bg-slate-200 transition-colors"
                  aria-label="Copy link"
                >
                  <Share2 className="w-5 h-5" />
                </button>
              </div>
            </div>
          </div>

          {/* Article Content */}
          <div
            className="prose prose-lg prose-slate max-w-none
              prose-headings:font-bold prose-headings:text-slate-900
              prose-h1:text-4xl prose-h1:mt-8 prose-h1:mb-4
              prose-h2:text-3xl prose-h2:mt-8 prose-h2:mb-4 prose-h2:text-slate-900
              prose-h3:text-2xl prose-h3:mt-6 prose-h3:mb-3 prose-h3:text-slate-900
              prose-p:text-slate-700 prose-p:leading-relaxed prose-p:mb-4
              prose-ul:list-disc prose-ul:ml-6 prose-ul:mb-4
              prose-ol:list-decimal prose-ol:ml-6 prose-ol:mb-4
              prose-li:text-slate-700 prose-li:mb-2
              prose-a:text-[#f4ba1b] prose-a:no-underline prose-a:font-semibold hover:prose-a:underline
              prose-strong:text-slate-900 prose-strong:font-bold
              prose-lead:text-xl prose-lead:text-slate-600 prose-lead:font-medium prose-lead:mb-6"
            dangerouslySetInnerHTML={{ __html: post.content }}
          />

          {/* Author Card */}
          <div className="mt-16 pt-12 border-t border-slate-200">
            <div className="bg-gradient-to-br from-slate-50 via-white to-slate-50 rounded-3xl p-8 sm:p-10 shadow-lg border border-slate-100">
              <div className="flex flex-col sm:flex-row items-start sm:items-center gap-6">
                <div className="relative flex-shrink-0">
                  <div className="absolute -inset-1 bg-gradient-to-r from-[#f4ba1b] to-amber-400 rounded-full blur-sm opacity-30"></div>
                  <img
                    src={post.author.avatar}
                    alt={post.author.name}
                    className="relative w-20 h-20 sm:w-24 sm:h-24 rounded-full border-4 border-white shadow-xl object-cover"
                  />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 mb-3">
                    <div className="p-1.5 bg-[#f4ba1b]/10 rounded-lg">
                      <User className="w-4 h-4 text-[#f4ba1b]" />
                    </div>
                    <div>
                      <p className="text-xs font-semibold text-slate-500 uppercase tracking-wide mb-1">
                        Written by
                      </p>
                      <h3 className="text-xl sm:text-2xl font-bold text-slate-900 leading-tight">
                        {post.author.name}
                      </h3>
                    </div>
                  </div>
                  <p className="text-base text-slate-700 leading-relaxed max-w-2xl">
                    {post.category.name === "Announcements" || post.category.name === "Campus News"
                      ? "Official announcements and updates from Fisk University's Election Committee. Dedicated to keeping students informed about campus governance and electoral processes."
                      : "Contributing writer covering campus elections, student governance, and university life. Passionate about student engagement and democratic participation."}
                  </p>
                  <div className="mt-4 flex items-center gap-4 text-sm text-slate-500">
                    <div className="flex items-center gap-1.5">
                      <Calendar className="w-4 h-4" />
                      <span>{post.date}</span>
                    </div>
                    <div className="flex items-center gap-1.5">
                      <Clock className="w-4 h-4" />
                      <span>{post.readTime}</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </article>

        {/* Related Posts */}
        {relatedPosts.length > 0 && (
          <section className="bg-slate-50 py-12 sm:py-16">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
              <div className="flex items-center justify-between mb-8">
              <h2 className="text-2xl sm:text-3xl font-bold text-slate-900">
                Related Articles
              </h2>
              <Link
                href="/blog"
                className="text-sm font-semibold text-[#f4ba1b] hover:text-[#e0a518] transition-colors"
              >
                View All →
              </Link>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              {relatedPosts.map((relatedPost) => {
                const RelatedCategoryIcon = getCategoryIcon(relatedPost.category.name);
                return (
                  <Link
                    key={relatedPost.id}
                    href={`/blog/${relatedPost.id}`}
                    className="group bg-white rounded-2xl overflow-hidden shadow-md hover:shadow-xl transition-all duration-300"
                  >
                    <div className="relative h-48 overflow-hidden">
                      <img
                        src={relatedPost.image || "https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=800&h=600&fit=crop"}
                        alt={relatedPost.title}
                        className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500"
                      />
                      <div className="absolute top-4 left-4">
                        <div className="flex items-center gap-2 px-3 py-1 rounded-full bg-white/90 backdrop-blur-sm text-xs font-semibold text-slate-900">
                          <RelatedCategoryIcon className="w-3 h-3" />
                          {relatedPost.category.name}
                        </div>
                      </div>
                    </div>
                    <div className="p-6">
                      <h3 className="text-lg font-bold text-slate-900 mb-2 line-clamp-2 group-hover:text-[#f4ba1b] transition-colors">
                        {relatedPost.title}
                      </h3>
                      <p className="text-sm text-slate-600 mb-4 line-clamp-2">
                        {relatedPost.excerpt}
                      </p>
                      <div className="flex items-center gap-3 text-xs text-slate-500">
                        <div className="flex items-center gap-1">
                          <Calendar className="w-3 h-3" />
                          <span>{relatedPost.date}</span>
                        </div>
                        <div className="flex items-center gap-1">
                          <Clock className="w-3 h-3" />
                          <span>{relatedPost.readTime}</span>
                        </div>
                      </div>
                    </div>
                  </Link>
                );
              })}
            </div>
            </div>
          </section>
        )}

        {/* Recent Posts */}
        {recentPosts.length > 0 && (
          <section className="py-12 sm:py-16">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
              <div className="flex items-center justify-between mb-8">
                <h2 className="text-2xl sm:text-3xl font-bold text-slate-900">
                  Recent Articles
                </h2>
                <Link
                  href="/blog"
                  className="text-sm font-semibold text-[#f4ba1b] hover:text-[#e0a518] transition-colors"
                >
                  View All →
                </Link>
              </div>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              {recentPosts.map((recentPost) => {
                const RecentCategoryIcon = getCategoryIcon(recentPost.category.name);
                return (
                  <Link
                    key={recentPost.id}
                    href={`/blog/${recentPost.id}`}
                    className="group bg-white border border-slate-200 rounded-2xl overflow-hidden hover:shadow-xl transition-all duration-300"
                  >
                    <div className="relative h-48 overflow-hidden">
                      <img
                        src={recentPost.image || "https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=800&h=600&fit=crop"}
                        alt={recentPost.title}
                        className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500"
                      />
                      <div className="absolute top-4 left-4">
                        <div className="flex items-center gap-2 px-3 py-1 rounded-full bg-white/90 backdrop-blur-sm text-xs font-semibold text-slate-900">
                          <RecentCategoryIcon className="w-3 h-3" />
                          {recentPost.category.name}
                        </div>
                      </div>
                    </div>
                    <div className="p-6">
                      <h3 className="text-lg font-bold text-slate-900 mb-2 line-clamp-2 group-hover:text-[#f4ba1b] transition-colors">
                        {recentPost.title}
                      </h3>
                      <p className="text-sm text-slate-600 mb-4 line-clamp-2">
                        {recentPost.excerpt}
                      </p>
                      <div className="flex items-center gap-3 text-xs text-slate-500">
                        <div className="flex items-center gap-1">
                          <Calendar className="w-3 h-3" />
                          <span>{recentPost.date}</span>
                        </div>
                        <div className="flex items-center gap-1">
                          <Clock className="w-3 h-3" />
                          <span>{recentPost.readTime}</span>
                        </div>
                      </div>
                    </div>
                  </Link>
                );
              })}
            </div>
            </div>
          </section>
        )}

        {/* Back to Blog CTA */}
        <section className="bg-gradient-to-r from-[#0a1a44] to-[#8b0000] text-white py-12 sm:py-16">
          <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <h2 className="text-2xl sm:text-3xl font-bold mb-4">
              Want to Read More?
            </h2>
            <p className="text-slate-200 mb-8">
              Explore more articles about campus elections, candidates, and student governance.
            </p>
            <Link href="/blog">
              <Button className="bg-[#f4ba1b] hover:bg-[#e0a518] text-slate-900 font-semibold px-8 py-3">
                Browse All Articles
              </Button>
            </Link>
          </div>
        </section>
      </main>
      <PublicFooter />
    </div>
  );
}
