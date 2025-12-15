import { useQuery, UseQueryResult } from "@tanstack/react-query";
import {
  getPosts,
  getPost,
  getCategories,
  getFeaturedPost,
  getPopularPosts,
  getRecentPosts,
  getRelatedPosts,
  searchPosts,
  type BlogPost,
  type BlogCategory,
  type BlogPostsResponse,
  type BlogPostsParams,
} from "@/services/blogService";

/**
 * Hook to fetch all blog posts with filters and pagination
 */
export function useBlogPosts(params: BlogPostsParams = {}) {
  return useQuery<BlogPostsResponse>({
    queryKey: ["blogPosts", params],
    queryFn: () => getPosts(params),
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
}

/**
 * Hook to fetch a single blog post
 */
export function useBlogPost(id: number | string | null) {
  return useQuery<BlogPost>({
    queryKey: ["blogPost", id],
    queryFn: () => getPost(id!),
    enabled: !!id,
    staleTime: 5 * 60 * 1000,
  });
}

/**
 * Hook to fetch all categories
 */
export function useBlogCategories() {
  return useQuery<BlogCategory[]>({
    queryKey: ["blogCategories"],
    queryFn: getCategories,
    staleTime: 10 * 60 * 1000, // 10 minutes (categories change less frequently)
  });
}

/**
 * Hook to fetch featured post
 */
export function useFeaturedPost() {
  return useQuery<BlogPost | null>({
    queryKey: ["blogFeaturedPost"],
    queryFn: getFeaturedPost,
    staleTime: 5 * 60 * 1000,
  });
}

/**
 * Hook to fetch popular posts
 */
export function usePopularPosts(limit: number = 5, excludeId?: number) {
  return useQuery<BlogPost[]>({
    queryKey: ["blogPopularPosts", limit, excludeId],
    queryFn: () => getPopularPosts(limit, excludeId),
    staleTime: 5 * 60 * 1000,
  });
}

/**
 * Hook to fetch recent posts
 */
export function useRecentPosts(limit: number = 5, excludeId?: number) {
  return useQuery<BlogPost[]>({
    queryKey: ["blogRecentPosts", limit, excludeId],
    queryFn: () => getRecentPosts(limit, excludeId),
    staleTime: 5 * 60 * 1000,
  });
}

/**
 * Hook to fetch related posts
 */
export function useRelatedPosts(postId: number | null, limit: number = 3) {
  return useQuery<BlogPost[]>({
    queryKey: ["blogRelatedPosts", postId, limit],
    queryFn: () => getRelatedPosts(postId!, limit),
    enabled: !!postId,
    staleTime: 5 * 60 * 1000,
  });
}

/**
 * Hook to search blog posts
 */
export function useSearchPosts(query: string, params: BlogPostsParams = {}) {
  return useQuery<BlogPostsResponse>({
    queryKey: ["blogSearch", query, params],
    queryFn: () => searchPosts(query, params),
    enabled: !!query && query.length > 0,
    staleTime: 2 * 60 * 1000, // 2 minutes for search results
  });
}
