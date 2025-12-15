<?php

namespace App\Http\Resources\Api;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class BlogPostResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'slug' => $this->slug,
            'excerpt' => $this->excerpt,
            'content' => $this->content,
            'category' => $this->category ? [
                'id' => $this->category->id,
                'name' => $this->category->name,
                'slug' => $this->category->slug,
                'icon' => $this->category->icon,
                'color' => $this->category->color,
            ] : null,
            'author' => $this->author ? [
                'id' => $this->author->id,
                'name' => $this->author->name ?? 'Unknown Author',
                'avatar' => 'https://i.pravatar.cc/150?img=' . $this->author->id,
            ] : [
                'id' => 0,
                'name' => 'Unknown Author',
                'avatar' => 'https://i.pravatar.cc/150?img=0',
            ],
            'image' => $this->resource->getImageUrl(),
            'featured' => $this->featured,
            'status' => $this->status,
            'date' => $this->published_at ? $this->published_at->format('F j, Y') : $this->created_at->format('F j, Y'),
            'published_at' => $this->published_at?->toISOString(),
            'readTime' => ($this->read_time ?: max(1, (int) ceil(str_word_count(strip_tags($this->content ?? '')) / 200))) . ' min read',
            'read_time' => $this->read_time ?: max(1, (int) ceil(str_word_count(strip_tags($this->content ?? '')) / 200)),
            'view_count' => $this->view_count,
            'meta_title' => $this->meta_title,
            'meta_description' => $this->meta_description,
            'tags' => $this->tags ?? [],
            'url' => url("/blog/{$this->id}"),
        ];
    }
}
