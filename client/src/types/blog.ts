// Re-export types from blogService for convenience
export type {
  BlogPost,
  BlogCategory,
  BlogPostsResponse,
} from "@/services/blogService";

export interface BlogPostsParams {
  page?: number;
  per_page?: number;
  category?: string;
  search?: string;
  featured?: boolean;
}
