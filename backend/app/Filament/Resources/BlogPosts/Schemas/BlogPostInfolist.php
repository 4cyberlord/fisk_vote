<?php

namespace App\Filament\Resources\BlogPosts\Schemas;

use Filament\Infolists\Components\IconEntry;
use Filament\Infolists\Components\ImageEntry;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class BlogPostInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                // Header Section with Image and Key Info
                Section::make('Post Overview')
                    ->schema([
                        ImageEntry::make('featured_image')
                            ->label('Featured Image')
                            ->height(300)
                            ->width('full')
                            ->columnSpanFull()
                            ->placeholder('No image uploaded')
                            ->getStateUsing(fn ($record) => $record?->getImageUrl()),

                        TextEntry::make('title')
                            ->label('Title')
                            ->size('lg')
                            ->weight('bold')
                            ->columnSpanFull(),

                        TextEntry::make('slug')
                            ->label('URL Slug')
                            ->copyable()
                            ->color('gray')
                            ->columnSpanFull(),

                        TextEntry::make('excerpt')
                            ->label('Excerpt')
                            ->placeholder('No excerpt provided')
                            ->columnSpanFull(),
                    ])
                    ->columns(1),

                // Content Section
                Section::make('Full Content')
                    ->schema([
                        TextEntry::make('content')
                            ->label('')
                            ->placeholder('No content available')
                            ->columnSpanFull()
                            ->getStateUsing(function ($record) {
                                if (!$record || !$record->content) {
                                    return null;
                                }

                                // Strip all HTML tags
                                $text = strip_tags($record->content);

                                // Decode HTML entities
                                $text = html_entity_decode($text, ENT_QUOTES | ENT_HTML5, 'UTF-8');

                                // Replace common HTML line breaks with actual line breaks
                                $text = str_replace(['<br>', '<br/>', '<br />', '</p>', '</div>', '</li>', '</h1>', '</h2>', '</h3>', '</h4>', '</h5>', '</h6>'], "\n", $text);

                                // Replace paragraph and div openings with line breaks
                                $text = preg_replace('/<(p|div|li|h[1-6])([^>]*)>/i', "\n", $text);

                                // Strip any remaining HTML tags
                                $text = strip_tags($text);

                                // Clean up multiple spaces (but preserve intentional spacing)
                                $text = preg_replace('/[ \t]+/', ' ', $text);

                                // Clean up multiple line breaks (max 2 consecutive for paragraph spacing)
                                $text = preg_replace('/\n{3,}/', "\n\n", $text);

                                // Trim whitespace from each line
                                $lines = explode("\n", $text);
                                $lines = array_map('trim', $lines);
                                $lines = array_filter($lines, fn($line) => $line !== ''); // Remove empty lines
                                $text = implode("\n\n", $lines);

                                // Final trim
                                return trim($text);
                            })
                            ->wrap()
                            ->size('base'),
                    ])
                    ->collapsible()
                    ->collapsed(),

                // Publishing Information
                Section::make('Publishing Information')
                    ->schema([
                        TextEntry::make('status')
                            ->label('Status')
                            ->badge()
                            ->color(fn (string $state): string => match ($state) {
                                'published' => 'success',
                                'draft' => 'warning',
                                'archived' => 'gray',
                                default => 'gray',
                            }),

                        TextEntry::make('published_at')
                            ->label('Published Date')
                            ->dateTime()
                            ->placeholder('Not published yet')
                            ->icon('heroicon-o-calendar'),

                        IconEntry::make('featured')
                            ->label('Featured Post')
                            ->boolean()
                            ->trueIcon('heroicon-o-star')
                            ->falseIcon('heroicon-o-star')
                            ->trueColor('warning')
                            ->falseColor('gray'),

                        TextEntry::make('read_time')
                            ->label('Reading Time')
                            ->suffix(' minutes')
                            ->placeholder('Not calculated')
                            ->icon('heroicon-o-clock'),

                        TextEntry::make('view_count')
                            ->label('Views')
                            ->numeric()
                            ->icon('heroicon-o-eye')
                            ->default(0),
                    ])
                    ->columns(3),

                // Organization
                Section::make('Organization')
                    ->schema([
                        TextEntry::make('category.name')
                            ->label('Category')
                            ->badge()
                            ->color('primary'),

                        TextEntry::make('author.name')
                            ->label('Author')
                            ->icon('heroicon-o-user'),

                        TextEntry::make('tags')
                            ->label('Tags')
                            ->badge()
                            ->separator(',')
                            ->placeholder('No tags')
                            ->columnSpanFull(),
                    ])
                    ->columns(2),

                // SEO Information
                Section::make('SEO Settings')
                    ->schema([
                        TextEntry::make('meta_title')
                            ->label('Meta Title')
                            ->placeholder('Not set (will use post title)')
                            ->columnSpanFull(),

                        TextEntry::make('meta_description')
                            ->label('Meta Description')
                            ->placeholder('Not set (will use excerpt)')
                            ->columnSpanFull(),
                    ])
                    ->collapsible()
                    ->collapsed(),

                // Metadata
                Section::make('Metadata')
                    ->schema([
                        TextEntry::make('created_at')
                            ->label('Created')
                            ->dateTime()
                            ->icon('heroicon-o-calendar'),

                        TextEntry::make('updated_at')
                            ->label('Last Updated')
                            ->dateTime()
                            ->icon('heroicon-o-clock'),
                    ])
                    ->columns(2)
                    ->collapsible()
                    ->collapsed(),
            ]);
    }
}
