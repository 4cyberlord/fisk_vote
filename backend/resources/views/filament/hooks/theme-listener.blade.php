<script>
    function applyTheme(themeValue) {
        const rawTheme = (themeValue ?? 'system').toString().toLowerCase();
        const allowedThemes = ['light', 'dark', 'system', 'auto'];
        const theme = allowedThemes.includes(rawTheme) ? rawTheme : 'system';
        const normalized = theme === 'auto' ? 'system' : theme;

        // Store the preference in localStorage
        localStorage.setItem('theme', normalized);
        window.theme = normalized;

        // Resolve system theme to actual dark/light based on OS preference
        let resolvedTheme = normalized;
        if (normalized === 'system') {
            resolvedTheme = window.matchMedia?.('(prefers-color-scheme: dark)')?.matches ? 'dark' : 'light';
        }

        // Update DOM class immediately
        if (resolvedTheme === 'dark') {
            document.documentElement.classList.add('dark');
        } else {
            document.documentElement.classList.remove('dark');
        }

        // Update Alpine store if available (Filament uses this)
        // Wait for Alpine to be ready if it's not yet initialized
        if (window.Alpine) {
            if (window.Alpine.store('theme') !== undefined) {
                window.Alpine.store('theme', resolvedTheme);
            }
        } else {
            // Wait for Alpine to initialize
            document.addEventListener('alpine:init', () => {
                if (window.Alpine.store('theme') !== undefined) {
                    window.Alpine.store('theme', resolvedTheme);
                }
            });
        }

        // Notify Filament's theme switcher & other listeners with the resolved theme
        window.dispatchEvent(new CustomEvent('theme-changed', {
            detail: resolvedTheme
        }));
    }

    // Listen for theme updates from the settings page
    document.addEventListener('filament-theme-updated', event => {
        applyTheme(event?.detail?.theme);
    });
</script>
