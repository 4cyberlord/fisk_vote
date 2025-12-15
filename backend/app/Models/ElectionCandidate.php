<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Spatie\MediaLibrary\HasMedia;
use Spatie\MediaLibrary\InteractsWithMedia;
use Spatie\MediaLibrary\MediaCollections\Models\Media;

class ElectionCandidate extends Model implements HasMedia
{
    use HasFactory;
    use InteractsWithMedia;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'election_id',
        'position_id',
        'user_id',
        'photo_url',
        'tagline',
        'bio',
        'manifesto',
        'approved',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected function casts(): array
    {
        return [
            'approved' => 'boolean',
        ];
    }

    /**
     * Register the media collections for this model.
     */
    public function registerMediaCollections(): void
    {
        // Single-file collection for candidate photo
        // Use 'public' disk so images are publicly accessible via storage link
        $this->addMediaCollection('photo')
            ->useDisk('public')
            ->singleFile();
    }

    /**
     * Register media conversions (e.g. thumbnails).
     */
    public function registerMediaConversions(?Media $media = null): void
    {
        $this
            ->addMediaConversion('thumb')
            ->width(400)
            ->height(400)
            ->sharpen(10)
            ->nonQueued();
    }

    /**
     * Accessor to keep using `photo_url` seamlessly with media library.
     *
     * - If the column has a value, return it (backwards compatible).
     * - Otherwise, return the URL from the `photo` media collection.
     * - For private disk (legacy), uses signed temporary URLs.
     * - For public disk, uses direct URLs accessible via storage link.
     */
    public function getPhotoUrlAttribute($value): ?string
    {
        if (! empty($value)) {
            // If it's already a full URL, return as is
            if (str_starts_with($value, 'http://') || str_starts_with($value, 'https://')) {
                return $value;
            }
            // If it's a relative path, convert to full URL
            if (str_starts_with($value, '/')) {
                return url($value);
            }
            // Otherwise, assume it's a storage path
            return url($value);
        }

        $media = $this->getFirstMedia('photo');

        if (! $media) {
            return null;
        }

        try {
            $conversionName = $media->hasGeneratedConversion('thumb') ? 'thumb' : '';

            // For private/local disk (legacy uploads), use signed temporary URLs
            if ($media->disk === 'local') {
                return $media->getTemporaryUrl(
                    now()->addHours(24),
                    $conversionName ?: ''
                );
            }

            // For public disk, use regular URL (accessible via storage:link)
            $url = $conversionName
                ? $media->getUrl($conversionName)
                : $media->getUrl();

            // Ensure we return a full URL
            if ($url && !str_starts_with($url, 'http://') && !str_starts_with($url, 'https://')) {
                return url($url);
            }

            return $url;
        } catch (\Exception $e) {
            // Fallback to regular URL if temporary URL generation fails
            $url = $media->hasGeneratedConversion('thumb')
                ? $media->getUrl('thumb')
                : $media->getUrl();

            if ($url && !str_starts_with($url, 'http://') && !str_starts_with($url, 'https://')) {
                return url($url);
            }

            return $url;
        }
    }

    /**
     * Get the election that this candidate belongs to.
     */
    public function election(): BelongsTo
    {
        return $this->belongsTo(Election::class);
    }

    /**
     * Get the position that this candidate is running for.
     */
    public function position(): BelongsTo
    {
        return $this->belongsTo(ElectionPosition::class, 'position_id');
    }

    /**
     * Get the user (candidate) information.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
