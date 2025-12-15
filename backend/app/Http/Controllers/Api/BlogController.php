<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\Api\BlogCategoryResource;
use App\Http\Resources\Api\BlogPostResource;
use App\Models\BlogCategory;
use App\Models\BlogPost;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class BlogController extends Controller
{
    /**
     * Get all published blog posts with pagination and filters
     */
    public function index(Request $request): AnonymousResourceCollection
    {
        $query = BlogPost::with(['category', 'author'])
            ->published()
            ->orderBy('published_at', 'desc')
            ->orderBy('created_at', 'desc');

        // Filter by category (only if category is provided and not "All")
        if ($request->has('category') && $request->get('category') && $request->get('category') !== 'All') {
            $categoryValue = $request->get('category');
            // Check if it's a slug or category name
            $category = BlogCategory::where('slug', $categoryValue)
                ->orWhere('name', $categoryValue)
                ->first();
            if ($category) {
                $query->where('category_id', $category->id);
            }
        }

        // Search
        if ($request->has('search')) {
            $search = $request->get('search');
            $query->search($search);
        }

        // Filter featured
        if ($request->has('featured') && $request->boolean('featured')) {
            $query->featured();
        }

        // Pagination
        $perPage = $request->get('per_page', 10);
        $posts = $query->paginate($perPage);

        return BlogPostResource::collection($posts);
    }

    /**
     * Get a single blog post by ID or slug
     */
    public function show(Request $request, $id): BlogPostResource|\Illuminate\Http\JsonResponse
    {
        $post = BlogPost::with(['category', 'author'])
            ->where(function ($query) use ($id) {
                $query->where('id', $id)
                    ->orWhere('slug', $id);
            })
            ->published()
            ->first();

        if (!$post) {
            return response()->json([
                'message' => 'Blog post not found',
            ], 404);
        }

        // Increment view count
        $post->incrementViews();

        return new BlogPostResource($post);
    }

    /**
     * Get all active categories
     */
    public function categories(): AnonymousResourceCollection
    {
        $categories = BlogCategory::active()
            ->ordered()
            ->withCount('publishedPosts')
            ->get();

        return BlogCategoryResource::collection($categories);
    }

    /**
     * Get featured post
     */
    public function featured(): BlogPostResource|\Illuminate\Http\JsonResponse
    {
        $post = BlogPost::with(['category', 'author'])
            ->published()
            ->featured()
            ->latest('published_at')
            ->first();

        if (!$post) {
            return response()->json([
                'message' => 'No featured post found',
            ], 404);
        }

        return new BlogPostResource($post);
    }

    /**
     * Get popular posts (by view count)
     */
    public function popular(Request $request): AnonymousResourceCollection
    {
        $limit = $request->get('limit', 5);
        $excludeId = $request->get('exclude');

        $query = BlogPost::with(['category', 'author'])
            ->published()
            ->orderBy('view_count', 'desc')
            ->orderBy('published_at', 'desc');

        if ($excludeId) {
            $query->where('id', '!=', $excludeId);
        }

        $posts = $query->limit($limit)->get();

        return BlogPostResource::collection($posts);
    }

    /**
     * Get recent posts
     */
    public function recent(Request $request): AnonymousResourceCollection
    {
        $limit = $request->get('limit', 5);
        $excludeId = $request->get('exclude');

        $query = BlogPost::with(['category', 'author'])
            ->published()
            ->orderBy('published_at', 'desc');

        if ($excludeId) {
            $query->where('id', '!=', $excludeId);
        }

        $posts = $query->limit($limit)->get();

        return BlogPostResource::collection($posts);
    }

    /**
     * Get related posts (same category)
     */
    public function related(Request $request, $id): AnonymousResourceCollection
    {
        $limit = $request->get('limit', 3);
        // Align with show(): allow lookup by ID or slug and require published
        $post = BlogPost::with(['category', 'author'])
            ->where(function ($query) use ($id) {
                $query->where('id', $id)
                    ->orWhere('slug', $id);
            })
            ->published()
            ->firstOrFail();

        $relatedPosts = BlogPost::with(['category', 'author'])
            ->published()
            ->where('category_id', $post->category_id)
            ->where('id', '!=', $post->id)
            ->orderBy('published_at', 'desc')
            ->limit($limit)
            ->get();

        return BlogPostResource::collection($relatedPosts);
    }

    /**
     * Search blog posts
     */
    public function search(Request $request): AnonymousResourceCollection
    {
        $query = BlogPost::with(['category', 'author'])
            ->published();

        if ($request->has('q')) {
            $search = $request->get('q');
            $query->search($search);
        }

        // Filter by category
        if ($request->has('category')) {
            $categorySlug = $request->get('category');
            $category = BlogCategory::where('slug', $categorySlug)->first();
            if ($category) {
                $query->where('category_id', $category->id);
            }
        }

        $perPage = $request->get('per_page', 10);
        $posts = $query->orderBy('published_at', 'desc')->paginate($perPage);

        return BlogPostResource::collection($posts);
    }
}
