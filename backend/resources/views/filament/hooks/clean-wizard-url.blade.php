<script>
    // Clean wizard URL query parameters to prevent encoded step parameters
    (function() {
        // Clean URL on page load
        if (window.history && window.history.replaceState) {
            const url = new URL(window.location.href);
            // Remove any step-related query parameters
            const paramsToRemove = ['step'];
            let cleaned = false;
            
            paramsToRemove.forEach(param => {
                if (url.searchParams.has(param)) {
                    url.searchParams.delete(param);
                    cleaned = true;
                }
            });
            
            if (cleaned) {
                window.history.replaceState({}, document.title, url.pathname + url.search);
            }
        }
        
        // Listen for Livewire navigation events and clean URL
        document.addEventListener('livewire:navigated', function() {
            setTimeout(() => {
                if (window.history && window.history.replaceState) {
                    const url = new URL(window.location.href);
                    const paramsToRemove = ['step'];
                    let cleaned = false;
                    
                    paramsToRemove.forEach(param => {
                        if (url.searchParams.has(param)) {
                            url.searchParams.delete(param);
                            cleaned = true;
                        }
                    });
                    
                    if (cleaned) {
                        window.history.replaceState({}, document.title, url.pathname + url.search);
                    }
                }
            }, 100);
        });
        
        // Also listen for popstate events (browser back/forward)
        window.addEventListener('popstate', function() {
            setTimeout(() => {
                if (window.history && window.history.replaceState) {
                    const url = new URL(window.location.href);
                    const paramsToRemove = ['step'];
                    let cleaned = false;
                    
                    paramsToRemove.forEach(param => {
                        if (url.searchParams.has(param)) {
                            url.searchParams.delete(param);
                            cleaned = true;
                        }
                    });
                    
                    if (cleaned) {
                        window.history.replaceState({}, document.title, url.pathname + url.search);
                    }
                }
            }, 100);
        });
    })();
</script>

