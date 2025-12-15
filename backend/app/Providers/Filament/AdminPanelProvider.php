<?php

namespace App\Providers\Filament;

use App\Helpers\SettingsHelper;
use Filament\Enums\ThemeMode;
use Filament\Http\Middleware\Authenticate;
use Filament\Http\Middleware\AuthenticateSession;
use Filament\Http\Middleware\DisableBladeIconComponents;
use Filament\Http\Middleware\DispatchServingFilamentEvent;
use App\Filament\Widgets\StatsOverviewWidget;
use App\Filament\Widgets\ElectionStatusChartWidget;
use App\Filament\Widgets\VotingActivityChartWidget;
use App\Filament\Widgets\ParticipationRateWidget;
use App\Filament\Widgets\RecentVotesWidget;
use App\Filament\Widgets\ActiveElectionsWidget;
use Filament\Pages\Dashboard;
use Filament\Panel;
use Filament\PanelProvider;
use Filament\Support\Colors\Color;
use Filament\Widgets\AccountWidget;
use Filament\Widgets\FilamentInfoWidget;
use Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse;
use Illuminate\Cookie\Middleware\EncryptCookies;
use Illuminate\Foundation\Http\Middleware\VerifyCsrfToken;
use Illuminate\Routing\Middleware\SubstituteBindings;
use Illuminate\Session\Middleware\StartSession;
use Illuminate\View\Middleware\ShareErrorsFromSession;

class AdminPanelProvider extends PanelProvider
{
    public function panel(Panel $panel): Panel
    {
        // Get settings with fallback to defaults
        try {
            $primaryColor = SettingsHelper::primaryColor();
            $secondaryColor = SettingsHelper::secondaryColor();
            $theme = SettingsHelper::dashboardTheme();
            $brandName = SettingsHelper::systemName();
            $brandLogo = SettingsHelper::universityLogoUrl();
            $loginBackground = SettingsHelper::loginBackgroundUrl();
        } catch (\Exception $e) {
            // Fallback to defaults if settings don't exist yet
            $primaryColor = '#3B82F6';
            $secondaryColor = '#8B5CF6';
            $theme = 'auto';
            $brandName = 'Fisk Voting System';
            $brandLogo = null;
            $loginBackground = null;
        }

        // Convert hex color to Filament Color format
        $primaryColorObj = Color::hex($primaryColor);
        $secondaryColorObj = Color::hex($secondaryColor);

        $panel = $panel
            ->default()
            ->id('admin')
            ->path('admin')
            ->login()
            ->brandName($brandName)
            ->colors([
                'primary' => $primaryColorObj,
                'secondary' => $secondaryColorObj,
            ])
            ->navigationGroups([
                'User Management',
                'Voting',
                'Content',
                'Access Control',
                'System',
            ])
            ->discoverResources(in: app_path('Filament/Resources'), for: 'App\Filament\Resources')
            ->discoverPages(in: app_path('Filament/Pages'), for: 'App\Filament\Pages')
            ->pages([
                Dashboard::class,
                \App\Filament\Pages\ElectionResults::class,
            ])
            ->discoverWidgets(in: app_path('Filament/Widgets'), for: 'App\Filament\Widgets')
            ->widgets([
                StatsOverviewWidget::class,
                ActiveElectionsWidget::class,
                ElectionStatusChartWidget::class,
                VotingActivityChartWidget::class,
                ParticipationRateWidget::class,
                RecentVotesWidget::class,
                AccountWidget::class,
            ])
            ->renderHook('panels::body.end', fn () => view('filament.hooks.theme-listener'))
            ->middleware([
                EncryptCookies::class,
                AddQueuedCookiesToResponse::class,
                StartSession::class,
                AuthenticateSession::class,
                ShareErrorsFromSession::class,
                VerifyCsrfToken::class,
                SubstituteBindings::class,
                DisableBladeIconComponents::class,
                DispatchServingFilamentEvent::class,
            ])
            ->authMiddleware([
                Authenticate::class,
            ]);

        // Configure theme mode dynamically based on admin settings.
        $themeMode = match (strtolower((string) $theme)) {
            'dark' => ThemeMode::Dark,
            'light' => ThemeMode::Light,
            default => ThemeMode::System,
        };

        match ($themeMode) {
            ThemeMode::Dark => $panel->darkMode(true, true),
            ThemeMode::Light => $panel->darkMode(false),
            ThemeMode::System => $panel->darkMode(true),
        };

        $panel->defaultThemeMode($themeMode);

        // Apply brand logo if available
        if ($brandLogo) {
            $panel->brandLogo($brandLogo);
        }

        // Apply login background if available
        if ($loginBackground) {
            $panel->loginBackground($loginBackground);
        }

        return $panel;
    }
}
