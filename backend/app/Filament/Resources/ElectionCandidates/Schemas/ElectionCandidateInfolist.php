<?php

namespace App\Filament\Resources\ElectionCandidates\Schemas;

use Filament\Infolists\Components\SpatieMediaLibraryImageEntry;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class ElectionCandidateInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                // Top Section: Profile Header with Photo and Key Info
                Section::make('Candidate Profile')
                    ->schema([
                        SpatieMediaLibraryImageEntry::make('photo')
                            ->label('')
                            ->collection('photo')
                            ->conversion('thumb')
                            ->circular()
                            ->defaultImageUrl(url('/images/default-avatar.png'))
                            ->columnSpan(1),

                        TextEntry::make('user.name')
                            ->label('Candidate Name')
                            ->weight('bold')
                            ->size('2xl')
                            ->columnSpan(2),

                        TextEntry::make('position.name')
                            ->label('Position')
                            ->size('lg')
                            ->icon('heroicon-o-briefcase')
                            ->formatStateUsing(fn ($state) => 'Running for: ' . $state)
                            ->columnSpan(2),

                        TextEntry::make('election.title')
                            ->label('Election')
                            ->size('base')
                            ->icon('heroicon-o-clipboard-document-check')
                            ->color('gray')
                            ->columnSpan(2),

                        TextEntry::make('approved')
                            ->label('Status')
                            ->formatStateUsing(fn ($state) => $state ? 'Approved' : 'Pending Approval')
                            ->badge()
                            ->color(fn ($state) => $state ? 'success' : 'warning')
                            ->icon(fn ($state) => $state ? 'heroicon-o-check-circle' : 'heroicon-o-clock')
                            ->columnSpan(2),
                    ])
                    ->columns(3)
                    ->icon('heroicon-o-user-circle'),

                // Campaign Tagline - Prominent Display
                Section::make('Campaign Message')
                    ->schema([
                        TextEntry::make('tagline')
                            ->label('')
                            ->size('xl')
                            ->weight('medium')
                            ->formatStateUsing(fn ($state) => $state ? '"' . $state . '"' : 'No campaign message provided.')
                            ->columnSpanFull(),
                    ])
                    ->visible(fn ($record) => true)
                    ->collapsible(false)
                    ->icon('heroicon-o-megaphone'),

                // Two Column Layout: Contact Info and Academic Info
                Section::make('Contact Information')
                    ->schema([
                        TextEntry::make('user.student_id')
                            ->label('Student ID')
                            ->icon('heroicon-o-identification')
                            ->copyable(),

                        TextEntry::make('user.university_email')
                            ->label('University Email')
                            ->icon('heroicon-o-envelope')
                            ->copyable(),
                    ])
                    ->columns(2)
                    ->icon('heroicon-o-phone'),

                Section::make('Academic Information')
                    ->schema([
                        TextEntry::make('user.department')
                            ->label('Department')
                            ->icon('heroicon-o-building-office')
                            ->placeholder('Not specified')
                            ->default('Not specified'),

                        TextEntry::make('user.major')
                            ->label('Major')
                            ->icon('heroicon-o-academic-cap')
                            ->placeholder('Not specified')
                            ->default('Not specified'),

                        TextEntry::make('user.class_level')
                            ->label('Class Level')
                            ->icon('heroicon-o-academic-cap')
                            ->badge()
                            ->color('info')
                            ->placeholder('Not specified')
                            ->default('Not specified'),
                    ])
                    ->columns(3)
                    ->icon('heroicon-o-information-circle'),

                // Biography Section - Full Width
                Section::make('Biography & Campaign Statement')
                    ->schema([
                        TextEntry::make('bio')
                            ->label('')
                            ->placeholder('No biography or campaign statement provided.')
                            ->formatStateUsing(fn ($state) => $state ?: 'No biography or campaign statement provided.')
                            ->columnSpanFull(),
                    ])
                    ->collapsible()
                    ->icon('heroicon-o-document-text'),

                // Metadata - Collapsed by Default
                Section::make('Record Information')
                    ->schema([
                        TextEntry::make('created_at')
                            ->label('Registered On')
                            ->dateTime('F j, Y \a\t g:i A')
                            ->icon('heroicon-o-calendar')
                            ->color('gray'),

                        TextEntry::make('updated_at')
                            ->label('Last Updated')
                            ->dateTime('F j, Y \a\t g:i A')
                            ->icon('heroicon-o-clock')
                            ->color('gray'),
                    ])
                    ->columns(2)
                    ->collapsible()
                    ->collapsed()
                    ->icon('heroicon-o-information-circle'),
            ]);
    }
}
