<?php

namespace App\Filament\Resources\BlogCategories\Schemas;

use Filament\Forms\Components\ColorPicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Components\Utilities\Get;
use Filament\Schemas\Schema;

class BlogCategoryForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Category Information')
                    ->schema([
                        TextInput::make('name')
                            ->label('Category Name')
                            ->required()
                            ->maxLength(255)
                            ->live(onBlur: true)
                            ->afterStateUpdated(function ($state, callable $set, $get) {
                                if (empty($get('slug'))) {
                                    $set('slug', \Illuminate\Support\Str::slug($state));
                                }
                            })
                            ->helperText('Enter the category name'),

                        TextInput::make('slug')
                            ->label('URL Slug')
                            ->required()
                            ->maxLength(255)
                            ->unique(ignoreRecord: true)
                            ->helperText('URL-friendly version of the name (auto-generated from name)')
                            ->afterStateUpdatedJs(<<<'JS'
                                $el.value = $el.value.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
                            JS),

                        Textarea::make('description')
                            ->label('Description')
                            ->rows(3)
                            ->maxLength(500)
                            ->helperText('Brief description of this category')
                            ->columnSpanFull(),
                    ])
                    ->columns(2),

                Section::make('Display Settings')
                    ->schema([
                        Select::make('icon')
                            ->label('Icon')
                            ->options([
                                'newspaper' => 'Newspaper',
                                'bell' => 'Bell',
                                'users' => 'Users',
                                'book-open' => 'Book Open',
                                'award' => 'Award',
                                'file-text' => 'File Text',
                                'trending-up' => 'Trending Up',
                            ])
                            ->searchable()
                            ->helperText('Icon to display for this category'),

                        ColorPicker::make('color')
                            ->label('Color')
                            ->helperText('Color for category badge'),

                        TextInput::make('sort_order')
                            ->label('Sort Order')
                            ->numeric()
                            ->default(0)
                            ->helperText('Lower numbers appear first'),

                        Toggle::make('is_active')
                            ->label('Active')
                            ->default(true)
                            ->helperText('Inactive categories won\'t appear in the blog'),
                    ])
                    ->columns(2)
                    ->collapsible(),
            ]);
    }
}
