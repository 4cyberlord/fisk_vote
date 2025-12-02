<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Redirecting...</title>
    <meta http-equiv="refresh" content="0;url={{ $url }}">
    <script>
        // FORCE immediate redirect - execute BEFORE page loads
        // This runs synchronously and cannot be intercepted
        (function() {
            try {
                // Method 1: window.location.replace (immediate, prevents back button)
                window.location.replace("{{ $url }}");
            } catch(e) {
                try {
                    // Method 2: window.location.href
                    window.location.href = "{{ $url }}";
                } catch(e2) {
                    // Method 3: window.location
                    window.location = "{{ $url }}";
                }
            }
        })();
    </script>
</head>
<body>
    <script>
        // Execute immediately when body loads
        window.location.replace("{{ $url }}");
    </script>
    <p>Redirecting to verification page...</p>
    <p>If you are not redirected, <a href="{{ $url }}">click here</a>.</p>
    <script>
        // Final fallback - execute after DOM
        setTimeout(function() {
            window.location.replace("{{ $url }}");
        }, 0);
    </script>
</body>
</html>

