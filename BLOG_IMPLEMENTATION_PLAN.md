# Blog Management System - Implementation Plan

## Overview
Building a complete blog management system using Filament plugins and creating API endpoints to serve blog data to the client frontend.

---

## Step-by-Step Implementation Plan

### **Phase 1: Install Required Plugins**

#### Step 1.1: Install Title with Slug Plugin
- [ ] Navigate to backend directory
- [ ] Run: `composer require camya/filament-title-with-slug`
- [ ] Verify installation in `composer.json`

#### Step 1.2: Install Blog Builder Plugin
- [ ] Run: `composer require jude-stephen/filament-blog` (or check actual package name)
- [ ] Verify installation in `composer.json`
- [ ] Publish plugin assets if needed

---

### **Phase 2: Database Setup**

#### Step 2.1: Create Blog Categories Migration
- [ ] Create migration: `create_blog_categories_table.php`
- [ ] Fields needed:
  - `id` (primary key)
  - `name` (string, unique)
  - `slug` (string, unique)
  - `description` (text, nullable)
  - `icon` (string, nullable) - for icon name
  - `color` (string, nullable) - for category color
  - `is_active` (boolean, default true)
  - `sort_order` (integer, default 0)
  - `created_at`, `updated_at` (timestamps)

#### Step 2.2: Create Blog Posts Migration
- [ ] Create migration: `create_blog_posts_table.php`
- [ ] Fields needed:
  - `id` (primary key)
  - `title` (string)
  - `slug` (string, unique)
  - `excerpt` (text) - short description
  - `content` (longText) - full HTML content
  - `category_id` (foreign key to blog_categories)
  - `author_id` (foreign key to users) - who created the post
  - `featured_image` (string, nullable) - image URL
  - `featured` (boolean, default false) - is featured post
  - `status` (enum: 'draft', 'published', 'archived') - default 'draft'
  - `published_at` (datetime, nullable) - when to publish
  - `read_time` (integer, nullable) - minutes to read
  - `view_count` (integer, default 0) - for popular posts
  - `meta_title` (string, nullable) - for SEO
  - `meta_description` (text, nullable) - for SEO
  - `tags` (json, nullable) - array of tags
  - `created_at`, `updated_at` (timestamps)

#### Step 2.3: Run Migrations
- [ ] Run: `php artisan migrate`
- [ ] Verify tables created in database

---

### **Phase 3: Create Models**

#### Step 3.1: Create BlogCategory Model
- [ ] Create: `backend/app/Models/BlogCategory.php`
- [ ] Define fillable fields
- [ ] Define relationships:
  - `hasMany(BlogPost::class)`
- [ ] Add scopes:
  - `active()` - only active categories
  - `ordered()` - by sort_order

#### Step 3.2: Create BlogPost Model
- [ ] Create: `backend/app/Models/BlogPost.php`
- [ ] Define fillable fields
- [ ] Define relationships:
  - `belongsTo(BlogCategory::class)`
  - `belongsTo(User::class, 'author_id')`
- [ ] Add casts:
  - `published_at` => 'datetime'
  - `tags` => 'array'
  - `featured` => 'boolean'
  - `status` => 'string'
- [ ] Add scopes:
  - `published()` - only published posts
  - `featured()` - only featured posts
  - `byCategory($categoryId)` - filter by category
- [ ] Add accessors:
  - `readTime` - calculate from content if not set
  - `url` - generate post URL

---

### **Phase 4: Create Filament Resources**

#### Step 4.1: Create BlogCategory Resource
- [ ] Create directory: `backend/app/Filament/Resources/BlogCategories/`
- [ ] Create `BlogCategoryResource.php`
- [ ] Create form schema: `Schemas/BlogCategoryForm.php`
  - Use TitleWithSlugInput for name/slug
  - Add description field (textarea)
  - Add icon field (select or text input)
  - Add color field (color picker)
  - Add is_active toggle
  - Add sort_order number input
- [ ] Create table schema: `Tables/BlogCategoriesTable.php`
  - Columns: name, slug, post count, is_active, sort_order
  - Filters: active/inactive
  - Actions: edit, delete
- [ ] Create infolist schema: `Schemas/BlogCategoryInfolist.php`
- [ ] Create pages:
  - `Pages/ListBlogCategories.php`
  - `Pages/CreateBlogCategory.php`
  - `Pages/EditBlogCategory.php`
  - `Pages/ViewBlogCategory.php`
- [ ] Set navigation group: 'Content' or 'Blog'

#### Step 4.2: Create BlogPost Resource
- [ ] Create directory: `backend/app/Filament/Resources/BlogPosts/`
- [ ] Create `BlogPostResource.php`
- [ ] Create form schema: `Schemas/BlogPostForm.php`
  - Use TitleWithSlugInput for title/slug
  - Use Blog Builder plugin for content (rich text editor)
  - Add excerpt field (textarea)
  - Add category select (relationship)
  - Add author select (relationship, default to current user)
  - Add featured image upload (file upload or URL input)
  - Add featured toggle
  - Add status select (draft/published/archived)
  - Add published_at datetime picker
  - Add read_time number input (auto-calculate option)
  - Add tags input (tags input field)
  - Add meta_title and meta_description (for SEO)
- [ ] Create table schema: `Tables/BlogPostsTable.php`
  - Columns: title, category, author, status, featured, published_at, view_count
  - Filters: status, category, featured, author
  - Search: title, excerpt, content
  - Actions: edit, delete, view
  - Bulk actions: publish, archive, delete
- [ ] Create infolist schema: `Schemas/BlogPostInfolist.php`
- [ ] Create pages:
  - `Pages/ListBlogPosts.php`
  - `Pages/CreateBlogPost.php`
  - `Pages/EditBlogPost.php`
  - `Pages/ViewBlogPost.php`
- [ ] Set navigation group: 'Content' or 'Blog'
- [ ] Add custom actions:
  - "Publish Now" action
  - "Preview" action (if needed)

---

### **Phase 5: Configure Plugins**

#### Step 5.1: Configure TitleWithSlugInput
- [ ] In BlogPostForm, configure:
  - `fieldTitle: 'title'`
  - `fieldSlug: 'slug'`
  - `urlPath: fn($record) => route('blog.show', $record)` (for preview link)
  - Custom slugifier if needed

#### Step 5.2: Configure Blog Builder Plugin
- [ ] Check plugin documentation for configuration
- [ ] Configure rich text editor settings
- [ ] Set up markdown support if needed
- [ ] Configure image upload handling

---

### **Phase 6: Create API Endpoints**

#### Step 6.1: Create Blog API Controller
- [ ] Create: `backend/app/Http/Controllers/Api/BlogController.php`
- [ ] Methods needed:
  - `index()` - List all published posts (with pagination, filters)
  - `show($id)` - Get single post by ID or slug
  - `categories()` - Get all active categories
  - `featured()` - Get featured post
  - `popular()` - Get popular posts (by view_count)
  - `recent()` - Get recent posts
  - `related($id)` - Get related posts (same category)
  - `search($query)` - Search posts

#### Step 6.2: Create API Routes
- [ ] Add routes in `backend/routes/api.php`:
  - `GET /api/blog/posts` - List posts
  - `GET /api/blog/posts/{id}` - Get single post
  - `GET /api/blog/categories` - List categories
  - `GET /api/blog/featured` - Get featured post
  - `GET /api/blog/popular` - Get popular posts
  - `GET /api/blog/recent` - Get recent posts
  - `GET /api/blog/posts/{id}/related` - Get related posts
  - `GET /api/blog/search` - Search posts

#### Step 6.3: Create API Resources (Transformers)
- [ ] Create: `backend/app/Http/Resources/BlogPostResource.php`
  - Transform BlogPost model to API response
  - Include: id, title, slug, excerpt, content, category, author, image, date, readTime, etc.
- [ ] Create: `backend/app/Http/Resources/BlogCategoryResource.php`
  - Transform BlogCategory model to API response
  - Include: id, name, slug, description, icon, post_count

#### Step 6.4: Add API Response Formatting
- [ ] Ensure consistent JSON response format
- [ ] Add pagination metadata
- [ ] Add error handling
- [ ] Add caching for performance (optional)

---

### **Phase 7: Update Frontend to Use API**

#### Step 7.1: Create Blog Service
- [ ] Create: `client/src/services/blogService.ts`
- [ ] Methods:
  - `getPosts(params)` - Fetch posts with filters
  - `getPost(id)` - Fetch single post
  - `getCategories()` - Fetch categories
  - `getFeaturedPost()` - Fetch featured post
  - `getPopularPosts(limit)` - Fetch popular posts
  - `getRecentPosts(limit)` - Fetch recent posts
  - `getRelatedPosts(postId, limit)` - Fetch related posts
  - `searchPosts(query)` - Search posts

#### Step 7.2: Create Blog Hook
- [ ] Create: `client/src/hooks/useBlogPosts.ts`
- [ ] Use React Query for data fetching
- [ ] Implement caching and refetching
- [ ] Add loading and error states

#### Step 7.3: Update Blog Listing Page
- [ ] Replace `mockPosts` import with API call
- [ ] Use `useBlogPosts()` hook
- [ ] Update search to use API
- [ ] Update category filtering to use API
- [ ] Update pagination to use API
- [ ] Add loading states
- [ ] Add error handling

#### Step 7.4: Update Blog Detail Page
- [ ] Replace `getPostById()` with API call
- [ ] Replace `getRelatedPosts()` with API call
- [ ] Replace `getRecentPosts()` with API call
- [ ] Add loading states
- [ ] Add error handling
- [ ] Add 404 handling for non-existent posts

#### Step 7.5: Update Types
- [ ] Create: `client/src/types/blog.ts`
- [ ] Define TypeScript interfaces matching API response
- [ ] Update imports in blog pages

---

### **Phase 8: Additional Features**

#### Step 8.1: Image Upload Handling
- [ ] Configure file storage for featured images
- [ ] Add image upload to Filament form
- [ ] Store images in public storage or cloud storage
- [ ] Return full image URLs in API

#### Step 8.2: View Tracking
- [ ] Add middleware/endpoint to track post views
- [ ] Update `view_count` when post is viewed
- [ ] Use for popular posts calculation

#### Step 8.3: Newsletter Subscription (Optional)
- [ ] Create `blog_subscriptions` table
- [ ] Add subscription endpoint
- [ ] Connect to email service

#### Step 8.4: SEO Optimization
- [ ] Add meta tags to blog pages
- [ ] Use meta_title and meta_description from API
- [ ] Add Open Graph tags
- [ ] Add structured data (JSON-LD)

---

### **Phase 9: Testing & Validation**

#### Step 9.1: Test Admin Panel
- [ ] Create test categories
- [ ] Create test blog posts
- [ ] Test title/slug generation
- [ ] Test rich text editor
- [ ] Test image upload
- [ ] Test publishing workflow
- [ ] Test featured post selection

#### Step 9.2: Test API Endpoints
- [ ] Test all API endpoints
- [ ] Verify response format
- [ ] Test pagination
- [ ] Test filtering
- [ ] Test search
- [ ] Test error handling

#### Step 9.3: Test Frontend Integration
- [ ] Verify blog listing page loads data
- [ ] Verify blog detail page loads data
- [ ] Test search functionality
- [ ] Test category filtering
- [ ] Test pagination
- [ ] Test related posts
- [ ] Test error states

---

### **Phase 10: Documentation & Cleanup**

#### Step 10.1: Update Documentation
- [ ] Document API endpoints
- [ ] Document admin panel usage
- [ ] Update README with blog features

#### Step 10.2: Cleanup
- [ ] Remove or archive `mockBlogPosts.ts` (keep for fallback during development)
- [ ] Remove hardcoded data references
- [ ] Clean up unused imports

---

## Files to Create/Modify

### Backend Files to Create:
1. `backend/database/migrations/XXXX_create_blog_categories_table.php`
2. `backend/database/migrations/XXXX_create_blog_posts_table.php`
3. `backend/app/Models/BlogCategory.php`
4. `backend/app/Models/BlogPost.php`
5. `backend/app/Filament/Resources/BlogCategories/BlogCategoryResource.php`
6. `backend/app/Filament/Resources/BlogCategories/Schemas/BlogCategoryForm.php`
7. `backend/app/Filament/Resources/BlogCategories/Schemas/BlogCategoryInfolist.php`
8. `backend/app/Filament/Resources/BlogCategories/Tables/BlogCategoriesTable.php`
9. `backend/app/Filament/Resources/BlogCategories/Pages/ListBlogCategories.php`
10. `backend/app/Filament/Resources/BlogCategories/Pages/CreateBlogCategory.php`
11. `backend/app/Filament/Resources/BlogCategories/Pages/EditBlogCategory.php`
12. `backend/app/Filament/Resources/BlogCategories/Pages/ViewBlogCategory.php`
13. `backend/app/Filament/Resources/BlogPosts/BlogPostResource.php`
14. `backend/app/Filament/Resources/BlogPosts/Schemas/BlogPostForm.php`
15. `backend/app/Filament/Resources/BlogPosts/Schemas/BlogPostInfolist.php`
16. `backend/app/Filament/Resources/BlogPosts/Tables/BlogPostsTable.php`
17. `backend/app/Filament/Resources/BlogPosts/Pages/ListBlogPosts.php`
18. `backend/app/Filament/Resources/BlogPosts/Pages/CreateBlogPost.php`
19. `backend/app/Filament/Resources/BlogPosts/Pages/EditBlogPost.php`
20. `backend/app/Filament/Resources/BlogPosts/Pages/ViewBlogPost.php`
21. `backend/app/Http/Controllers/Api/BlogController.php`
22. `backend/app/Http/Resources/BlogPostResource.php`
23. `backend/app/Http/Resources/BlogCategoryResource.php`

### Backend Files to Modify:
1. `backend/composer.json` - Add plugin dependencies
2. `backend/routes/api.php` - Add blog API routes

### Frontend Files to Create:
1. `client/src/services/blogService.ts`
2. `client/src/hooks/useBlogPosts.ts`
3. `client/src/types/blog.ts`

### Frontend Files to Modify:
1. `client/src/app/blog/page.tsx` - Replace mock data with API
2. `client/src/app/blog/[id]/page.tsx` - Replace mock data with API

---

## API Response Examples

### GET /api/blog/posts
```json
{
  "data": [
    {
      "id": 1,
      "title": "Student Government Elections 2024",
      "slug": "student-government-elections-2024",
      "excerpt": "Get ready for the most important election...",
      "content": "<p>Full HTML content...</p>",
      "category": {
        "id": 1,
        "name": "Announcements",
        "slug": "announcements"
      },
      "author": {
        "id": 1,
        "name": "Election Committee",
        "avatar": "https://..."
      },
      "image": "https://...",
      "featured": true,
      "published_at": "2024-03-15T00:00:00Z",
      "read_time": 5,
      "view_count": 1250,
      "tags": ["elections", "student-government"]
    }
  ],
  "meta": {
    "current_page": 1,
    "per_page": 10,
    "total": 25,
    "last_page": 3
  }
}
```

### GET /api/blog/posts/{id}
```json
{
  "data": {
    "id": 1,
    "title": "...",
    "slug": "...",
    "content": "...",
    // ... full post data
  }
}
```

---

## Navigation Group Setup

Add "Content" or "Blog" navigation group to AdminPanelProvider:
```php
->navigationGroups([
    'User Management',
    'Voting',
    'Content', // New group for blog
    'Access Control',
    'System',
])
```

---

## Estimated Time

- **Phase 1 (Plugins):** 15 minutes
- **Phase 2 (Database):** 30 minutes
- **Phase 3 (Models):** 30 minutes
- **Phase 4 (Filament Resources):** 2-3 hours
- **Phase 5 (Plugin Config):** 30 minutes
- **Phase 6 (API):** 1-2 hours
- **Phase 7 (Frontend):** 1-2 hours
- **Phase 8 (Additional):** 1 hour
- **Phase 9 (Testing):** 1 hour
- **Phase 10 (Documentation):** 30 minutes

**Total Estimated Time: 8-10 hours**

---

## Dependencies

- Filament 4.0 ✅ (Already installed)
- Laravel 12.0 ✅ (Already installed)
- Title with Slug Plugin (To install)
- Blog Builder Plugin (To install - may need to verify package name)

---

## Notes

1. **Blog Builder Plugin**: The package name might be different. Need to verify the actual Composer package name from the plugin's GitHub repository.

2. **Image Storage**: Decide on storage strategy:
   - Local storage (public/uploads/blog)
   - Cloud storage (S3, Cloudinary, etc.)
   - Media library (Spatie Media Library is already installed)

3. **Content Editor**: Blog Builder plugin should provide rich text editor. If not, can use:
   - Filament's built-in rich text editor
   - Tiptap editor
   - Quill editor

4. **Slug Generation**: TitleWithSlugInput will auto-generate slugs, but can be manually edited.

5. **Publishing Workflow**: Consider adding:
   - Draft preview
   - Scheduled publishing
   - Revision history

---

*Plan Created: [Current Date]*
*Ready for Implementation*
