import axios from "@/lib/axios";

export interface BlogPost {
  id: number;
  title: string;
  slug: string;
  excerpt: string;
  content: string;
  category: {
    id: number;
    name: string;
    slug: string;
    icon?: string;
    color?: string;
  };
  author: {
    id: number;
    name: string;
    avatar: string;
  };
  image: string | null;
  featured: boolean;
  status: string;
  date: string;
  published_at?: string;
  readTime: string;
  read_time: number;
  view_count: number;
  meta_title?: string;
  meta_description?: string;
  tags: string[];
  url: string;
}

export interface BlogCategory {
  id: number;
  name: string;
  slug: string;
  description?: string;
  icon?: string;
  color?: string;
  is_active: boolean;
  post_count: number;
}

export interface BlogPostsResponse {
  data: BlogPost[];
  meta: {
    current_page: number;
    per_page: number;
    total: number;
    last_page: number;
  };
  links: {
    first: string;
    last: string;
    prev: string | null;
    next: string | null;
  };
}

interface BlogPostsParams {
  page?: number;
  per_page?: number;
  category?: string;
  search?: string;
  featured?: boolean;
}

/**
 * Get all blog posts with optional filters and pagination
 */
export async function getPosts(params: BlogPostsParams = {}): Promise<BlogPostsResponse> {
  const response = await axios.get("/blog/posts", { params });
  return response.data;
}

/**
 * Get a single blog post by ID or slug
 */
export async function getPost(id: number | string): Promise<BlogPost> {
  const response = await axios.get(`/blog/posts/${id}`);
  return response.data.data;
}

/**
 * Get all active categories
 */
export async function getCategories(): Promise<BlogCategory[]> {
  const response = await axios.get("/blog/categories");
  return response.data.data;
}

/**
 * Get featured post
 */
export async function getFeaturedPost(): Promise<BlogPost | null> {
  try {
    const response = await axios.get("/blog/featured");
    return response.data.data;
  } catch (error: any) {
    if (error.response?.status === 404) {
      return null;
    }
    throw error;
  }
}

/**
 * Get popular posts
 */
export async function getPopularPosts(limit: number = 5, excludeId?: number): Promise<BlogPost[]> {
  const response = await axios.get("/blog/popular", {
    params: { limit, exclude: excludeId },
  });
  return response.data.data;
}

/**
 * Get recent posts
 */
export async function getRecentPosts(limit: number = 5, excludeId?: number): Promise<BlogPost[]> {
  const response = await axios.get("/blog/recent", {
    params: { limit, exclude: excludeId },
  });
  return response.data.data;
}

/**
 * Get related posts (same category)
 */
export async function getRelatedPosts(postId: number, limit: number = 3): Promise<BlogPost[]> {
  const response = await axios.get(`/blog/posts/${postId}/related`, {
    params: { limit },
  });
  return response.data.data;
}

/**
 * Search blog posts
 */
export async function searchPosts(query: string, params: BlogPostsParams = {}): Promise<BlogPostsResponse> {
  const response = await axios.get("/blog/search", {
    params: { q: query, ...params },
  });
  return response.data;
}
