<?php

namespace App\Filament\Resources\BlogCategories\Schemas;

use Filament\Infolists\Components\IconEntry;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class BlogCategoryInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                // Main Category Information
                Section::make('Category Information')
                    ->schema([
                        TextEntry::make('name')
                            ->label('Category Name')
                            ->size('lg')
                            ->weight('bold'),

                        TextEntry::make('slug')
                            ->label('URL Slug')
                            ->copyable()
                            ->color('gray'),

                        TextEntry::make('description')
                            ->label('Description')
                            ->placeholder('No description provided')
                            ->columnSpanFull(),

                        IconEntry::make('is_active')
                            ->label('Status')
                            ->boolean()
                            ->trueIcon('heroicon-o-check-circle')
                            ->falseIcon('heroicon-o-x-circle')
                            ->trueColor('success')
                            ->falseColor('danger')
                            ->trueLabel('Active')
                            ->falseLabel('Inactive'),

                        TextEntry::make('sort_order')
                            ->label('Sort Order')
                            ->numeric()
                            ->icon('heroicon-o-arrows-up-down'),
                    ])
                    ->columns(2),

                // Display Settings
                Section::make('Display Settings')
                    ->schema([
                        TextEntry::make('icon')
                            ->label('Icon')
                            ->placeholder('No icon set')
                            ->icon('heroicon-o-photo'),

                        TextEntry::make('color')
                            ->label('Color')
                            ->placeholder('No color set')
                            ->color('gray'),
                    ])
                    ->columns(2)
                    ->collapsible(),

                // Statistics
                Section::make('Statistics')
                    ->schema([
                        TextEntry::make('published_posts_count')
                            ->label('Published Posts')
                            ->numeric()
                            ->badge()
                            ->color('primary')
                            ->icon('heroicon-o-document-text')
                            ->default(0),
                    ])
                    ->collapsible(),

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
