<?php

namespace App\Filament\Resources\BlogPosts\Schemas;

use App\Models\BlogCategory;
use App\Models\User;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\RichEditor;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TagsInput;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Components\Utilities\Get;
use Filament\Schemas\Schema;
use Illuminate\Support\Str;

class BlogPostForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                // ESSENTIAL FIELDS - Most Important First
                Section::make('Essential Information')
                    ->description('Required fields to create your blog post')
                    ->schema([
                        TextInput::make('title')
                            ->label('Post Title')
                            ->required()
                            ->maxLength(255)
                            ->placeholder('Enter your blog post title...')
                            ->live(onBlur: true)
                            ->afterStateUpdated(function ($state, callable $set, $get) {
                                if (empty($get('slug'))) {
                                    $set('slug', Str::slug($state));
                                }
                                if ($get('content')) {
                                    $wordCount = str_word_count(strip_tags($get('content')));
                                    $readTime = max(1, (int) ceil($wordCount / 200));
                                    $set('read_time', $readTime);
                                }
                            })
                            ->columnSpanFull(),

                        Select::make('category_id')
                            ->label('Category')
                            ->relationship('category', 'name')
                            ->required()
                            ->searchable()
                            ->preload()
                            ->createOptionForm([
                                TextInput::make('name')->required()->label('Category Name'),
                                TextInput::make('slug')->required()->label('Slug'),
                            ])
                            ->helperText('Select or create a category for this post')
                            ->columnSpan(1),

                        Select::make('status')
                            ->label('Status')
                            ->options([
                                'draft' => 'Draft',
                                'published' => 'Published',
                                'archived' => 'Archived',
                            ])
                            ->default('draft')
                            ->required()
                            ->live()
                            ->helperText('Draft posts are not visible to the public')
                            ->columnSpan(1),

                        Textarea::make('excerpt')
                            ->label('Excerpt / Summary')
                            ->required()
                            ->rows(3)
                            ->maxLength(500)
                            ->placeholder('Write a brief, engaging summary...')
                            ->helperText('This appears in blog listings and search results')
                            ->columnSpanFull(),

                        RichEditor::make('content')
                            ->label('Content')
                            ->required()
                            ->toolbarButtons([
                                'attachFiles',
                                'blockquote',
                                'bold',
                                'bulletList',
                                'codeBlock',
                                'italic',
                                'link',
                                'orderedList',
                                'redo',
                                'strike',
                                'underline',
                                'undo',
                            ])
                            ->fileAttachmentsDirectory('blog-attachments')
                            ->live(onBlur: true)
                            ->afterStateUpdated(function ($state, callable $set) {
                                $wordCount = str_word_count(strip_tags($state));
                                $readTime = max(1, (int) ceil($wordCount / 200));
                                $set('read_time', $readTime);
                            })
                            ->helperText('Write your full blog post content. Read time is calculated automatically.')
                            ->columnSpanFull(),

                        FileUpload::make('featured_image')
                            ->label('Featured Image')
                            ->image()
                            ->disk('public')
                            ->directory('blog-images')
                            ->imageEditor()
                            ->maxSize(5120)
                            ->acceptedFileTypes(['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/gif'])
                            ->helperText('Accepted formats: JPG, JPEG, PNG, WebP, GIF | Recommended size: 1200x630px | Maximum file size: 5MB')
                            ->columnSpanFull(),
                    ])
                    ->columns(2),

                // ADDITIONAL FIELDS - Below Essential
                Section::make('Additional Settings')
                    ->description('Optional fields and advanced options')
                    ->schema([
                        TextInput::make('slug')
                            ->label('URL Slug')
                            ->required()
                            ->maxLength(255)
                            ->unique(ignoreRecord: true)
                            ->placeholder('auto-generated-slug')
                            ->helperText('URL-friendly version (auto-generated from title, you can edit)')
                            ->afterStateUpdatedJs(<<<'JS'
                                $el.value = $el.value.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
                            JS)
                            ->columnSpanFull(),

                        Select::make('author_id')
                            ->label('Author')
                            ->relationship('author', 'name')
                            ->required()
                            ->default(fn () => auth()->id())
                            ->searchable()
                            ->preload()
                            ->helperText('Post author (defaults to you)')
                            ->columnSpan(1),

                        DateTimePicker::make('published_at')
                            ->label('Publish Date & Time')
                            ->visible(fn (Get $get) => $get('status') === 'published')
                            ->helperText('Schedule publication (leave empty for immediate publish)')
                            ->default(now())
                            ->displayFormat('M d, Y H:i')
                            ->timezone('UTC')
                            ->columnSpan(1),

                        Toggle::make('featured')
                            ->label('⭐ Feature this post')
                            ->default(false)
                            ->helperText('Featured posts appear prominently on the homepage')
                            ->columnSpanFull(),

                        TagsInput::make('tags')
                            ->label('Tags')
                            ->placeholder('Type and press Enter to add tags')
                            ->helperText('Add relevant tags for better discoverability')
                            ->columnSpanFull(),

                        TextInput::make('read_time')
                            ->label('Reading Time')
                            ->numeric()
                            ->minValue(1)
                            ->suffix('minutes')
                            ->helperText('Auto-calculated from content length. Override if needed.')
                            ->columnSpan(1),

                        TextInput::make('meta_title')
                            ->label('SEO Meta Title')
                            ->maxLength(60)
                            ->placeholder('Custom SEO title (optional)')
                            ->helperText('Leave empty to use post title. Optimal: 50-60 characters.')
                            ->columnSpanFull(),

                        Textarea::make('meta_description')
                            ->label('SEO Meta Description')
                            ->rows(3)
                            ->maxLength(160)
                            ->placeholder('Custom SEO description (optional)')
                            ->helperText('Leave empty to use excerpt. Optimal: 150-160 characters.')
                            ->columnSpanFull(),
                    ])
                    ->columns(2)
                    ->collapsible(),
            ]);
    }
}
