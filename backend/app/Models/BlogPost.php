<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Str;

class BlogPost extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'slug',
        'excerpt',
        'content',
        'category_id',
        'author_id',
        'featured_image',
        'featured',
        'status',
        'published_at',
        'read_time',
        'view_count',
        'meta_title',
        'meta_description',
        'tags',
    ];

    protected function casts(): array
    {
        return [
            'featured' => 'boolean',
            'published_at' => 'datetime',
            'read_time' => 'integer',
            'view_count' => 'integer',
            'tags' => 'array',
        ];
    }

    /**
     * Get the category that owns the blog post
     */
    public function category(): BelongsTo
    {
        return $this->belongsTo(BlogCategory::class);
    }

    /**
     * Get the author (user) who created the blog post
     */
    public function author(): BelongsTo
    {
        return $this->belongsTo(User::class, 'author_id');
    }

    /**
     * Scope to get only published posts
     */
    public function scopePublished($query)
    {
        return $query->where('status', 'published')
            ->where(function ($q) {
                $q->whereNull('published_at')
                    ->orWhere('published_at', '<=', now());
            })
            ->whereNotNull('category_id') // Ensure category exists
            ->whereNotNull('author_id'); // Ensure author exists
    }

    /**
     * Scope to get only featured posts
     */
    public function scopeFeatured($query)
    {
        return $query->where('featured', true);
    }

    /**
     * Scope to filter by category
     */
    public function scopeByCategory($query, $categoryId)
    {
        return $query->where('category_id', $categoryId);
    }

    /**
     * Scope to search posts
     */
    public function scopeSearch($query, $search)
    {
        return $query->where(function ($q) use ($search) {
            $q->where('title', 'like', "%{$search}%")
                ->orWhere('excerpt', 'like', "%{$search}%")
                ->orWhere('content', 'like', "%{$search}%");
        });
    }

    /**
     * Get the URL for this blog post
     */
    public function getUrlAttribute(): string
    {
        return url("/blog/{$this->id}");
    }

    /**
     * Calculate read time from content if not set
     */
    public function getCalculatedReadTimeAttribute(): int
    {
        if ($this->read_time) {
            return $this->read_time;
        }

        // Calculate based on content length (average reading speed: 200 words per minute)
        $wordCount = str_word_count(strip_tags($this->content ?? ''));
        return max(1, (int) ceil($wordCount / 200));
    }

    /**
     * Auto-generate slug from title if not provided
     */
    protected static function boot()
    {
        parent::boot();

        static::creating(function ($post) {
            if (empty($post->slug) && !empty($post->title)) {
                $post->slug = Str::slug($post->title);
            }
        });

        static::updating(function ($post) {
            if ($post->isDirty('title') && empty($post->slug)) {
                $post->slug = Str::slug($post->title);
            }
        });
    }

    /**
     * Increment view count
     */
    public function incrementViews(): void
    {
        $this->increment('view_count');
    }

    /**
     * Get the full URL for the featured image
     */
    public function getImageUrl(): ?string
    {
        if (!$this->featured_image) {
            return null;
        }

        // If it's already a full URL (external image), return as is
        if (str_starts_with($this->featured_image, 'http://') || str_starts_with($this->featured_image, 'https://')) {
            return $this->featured_image;
        }

        // Check if file exists in public disk (new uploads)
        $publicPath = storage_path('app/public/' . $this->featured_image);
        if (file_exists($publicPath)) {
            // File is in public storage, accessible via storage symlink
            $imagePath = 'storage/' . ltrim($this->featured_image, '/');
            return url($imagePath);
        }

        // Check if file exists in private disk (old files from before disk change)
        $privatePath = storage_path('app/private/' . $this->featured_image);
        if (file_exists($privatePath)) {
            // Serve private files via a route
            return route('blog.image', ['path' => base64_encode($this->featured_image)]);
        }

        // Fallback: assume file is in public storage (for cases where file exists but check failed)
        $imagePath = 'storage/' . ltrim($this->featured_image, '/');
        return url($imagePath);
    }
}
