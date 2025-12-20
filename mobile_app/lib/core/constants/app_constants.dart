/// FiskPulse Application Constants
///
/// Single source of truth for all constant values used throughout the app.
///
/// ## Why Use Constants?
///
/// ```dart
/// // ❌ BAD - Magic numbers
/// await Future.delayed(Duration(seconds: 30));
/// api.get('api/elections?limit=20');
///
/// // ✅ GOOD - Use constants
/// await Future.delayed(AppConstants.requestTimeout);
/// api.get('${AppConstants.electionsEndpoint}?limit=${AppConstants.pageSize}');
/// ```
///
/// ## Categories
///
/// | Category | Purpose |
/// |----------|---------|
/// | App Info | Metadata about the app |
/// | Timing | Timeouts, intervals, delays |
/// | Pagination | Data loading limits |
/// | Cache Keys | Local storage keys |
/// | Validation | Input validation rules |
/// | API Endpoints | API route paths |
/// | UI Constants | Spacing, sizing values |
/// | Feature Flags | Toggle features on/off |
class AppConstants {
  AppConstants._(); // Private constructor

  // ════════════════════════════════════════════════════════════════════════════
  // APP INFORMATION
  // ════════════════════════════════════════════════════════════════════════════

  /// Official app name displayed to users
  static const String appName = 'FiskPulse';

  /// App tagline/description
  static const String appTagline = 'Secure University Voting System';

  /// Current version number (user-facing)
  /// Format: MAJOR.MINOR.PATCH
  static const String appVersion = '0.1.0-beta';

  /// Internal build number for tracking
  static const String appBuild = '1';

  /// Full version string
  static String get fullVersion => '$appVersion+$appBuild';

  /// App store bundle ID (iOS)
  static const String bundleIdIos = 'edu.fisk.fiskpulse';

  /// App store package name (Android)
  static const String packageNameAndroid = 'edu.fisk.fiskpulse';

  // ════════════════════════════════════════════════════════════════════════════
  // TIMING & DURATIONS
  // ════════════════════════════════════════════════════════════════════════════

  /// API request timeout (30 seconds)
  /// Long enough for slow networks, short enough to not frustrate users
  static const Duration requestTimeout = Duration(seconds: 30);

  /// Connection timeout (10 seconds)
  static const Duration connectTimeout = Duration(seconds: 10);

  /// Polling interval for live results (5 seconds)
  /// Feels "live" without excessive battery/data usage
  static const Duration pollingInterval = Duration(seconds: 5);

  /// Delay before retrying failed requests (500ms)
  static const Duration retryDelay = Duration(milliseconds: 500);

  /// Session timeout for auto-logout (30 minutes)
  static const Duration sessionTimeout = Duration(minutes: 30);

  /// Token refresh threshold (5 minutes before expiry)
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);

  /// Standard animation duration (300ms)
  /// Fast enough to feel responsive, slow enough to be smooth
  static const Duration animationDuration = Duration(milliseconds: 300);

  /// Fast animation (150ms)
  static const Duration animationFast = Duration(milliseconds: 150);

  /// Slow animation (500ms)
  static const Duration animationSlow = Duration(milliseconds: 500);

  /// Snackbar display duration (4 seconds)
  static const Duration snackbarDuration = Duration(seconds: 4);

  /// Splash screen minimum display time (2 seconds)
  static const Duration splashDuration = Duration(seconds: 2);

  /// Debounce duration for search (300ms)
  static const Duration debounceDelay = Duration(milliseconds: 300);

  // ════════════════════════════════════════════════════════════════════════════
  // PAGINATION & DATA LIMITS
  // ════════════════════════════════════════════════════════════════════════════

  /// Items per page for list pagination
  static const int pageSize = 20;

  /// Initial page number (0-indexed or 1-indexed based on API)
  static const int initialPage = 1;

  /// Maximum retry attempts for failed requests
  static const int maxRetries = 3;

  /// Maximum login attempts before lockout
  static const int maxLoginAttempts = 5;

  /// Maximum file upload size (10 MB)
  static const int maxFileSize = 10 * 1024 * 1024;

  /// Maximum image dimension for uploads (2000px)
  static const int maxImageDimension = 2000;

  /// Maximum search results
  static const int maxSearchResults = 50;

  /// Minimum search query length
  static const int minSearchLength = 2;

  // ════════════════════════════════════════════════════════════════════════════
  // CACHE KEYS
  // ════════════════════════════════════════════════════════════════════════════

  /// Authentication token key
  static const String keyAuthToken = 'auth_token';

  /// Refresh token key
  static const String keyRefreshToken = 'refresh_token';

  /// Current user data key
  static const String keyCurrentUser = 'current_user';

  /// User preferences key
  static const String keyPreferences = 'user_preferences';

  /// Theme mode key
  static const String keyThemeMode = 'theme_mode';

  /// Language/locale key
  static const String keyLocale = 'app_locale';

  /// Last sync timestamp key
  static const String keyLastSync = 'last_sync_time';

  /// Onboarding completed key
  static const String keyOnboardingComplete = 'onboarding_complete';

  /// Push notification token key
  static const String keyPushToken = 'push_notification_token';

  /// Biometric enabled key
  static const String keyBiometricEnabled = 'biometric_enabled';

  /// Elections cache key
  static const String keyElectionsCache = 'elections_cache';

  /// Candidates cache key
  static const String keyCandidatesCache = 'candidates_cache';

  // ════════════════════════════════════════════════════════════════════════════
  // VALIDATION RULES
  // ════════════════════════════════════════════════════════════════════════════

  /// Minimum password length (NIST recommended)
  static const int minPasswordLength = 8;

  /// Maximum password length
  static const int maxPasswordLength = 128;

  /// Minimum username length
  static const int minUsernameLength = 3;

  /// Maximum username length
  static const int maxUsernameLength = 30;

  /// Maximum bio/description length
  static const int maxBioLength = 500;

  /// Email validation regex
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Fisk University email regex
  static final RegExp fiskEmailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@(my\.)?fisk\.edu$',
    caseSensitive: false,
  );

  /// Phone number regex (US format)
  static final RegExp phoneRegex = RegExp(
    r'^[+]?[(]?[0-9]{3}[)]?[-\s.]?[0-9]{3}[-\s.]?[0-9]{4,6}$',
  );

  /// Student ID regex (alphanumeric, 6-10 characters)
  static final RegExp studentIdRegex = RegExp(r'^[A-Za-z0-9]{6,10}$');

  // ════════════════════════════════════════════════════════════════════════════
  // API ENDPOINTS
  // ════════════════════════════════════════════════════════════════════════════
  // Paths are relative to API base URL
  // Full URL = baseUrl + endpoint

  // --- Authentication ---
  /// POST - Login user
  static const String endpointLogin = '/students/login';

  /// POST - Register new user
  static const String endpointRegister = '/students/register';

  /// POST - Verify email
  static const String endpointVerifyEmail = '/students/verify-email';

  /// POST - Resend verification
  static const String endpointResendVerification =
      '/students/resend-verification';

  /// POST - Logout user
  static const String endpointLogout = '/students/logout';

  /// POST - Refresh token
  static const String endpointRefreshToken = '/students/refresh';

  /// POST - Forgot password
  static const String endpointForgotPassword = '/students/forgot-password';

  /// POST - Reset password
  static const String endpointResetPassword = '/students/reset-password';

  // --- User Profile ---
  /// GET - Current user profile
  static const String endpointCurrentUser = '/students/me';

  /// PATCH - Update profile
  static const String endpointUpdateProfile = '/students/profile';

  /// POST - Upload profile photo
  static const String endpointUploadPhoto = '/students/profile/photo';

  // --- Elections ---
  /// GET - List all elections
  static const String endpointElections = '/elections';

  /// GET - Single election details (append /{id})
  static const String endpointElectionDetail = '/elections';

  /// GET - Active elections
  static const String endpointActiveElections = '/elections/active';

  /// GET - Upcoming elections
  static const String endpointUpcomingElections = '/elections/upcoming';

  /// GET - Past elections
  static const String endpointPastElections = '/elections/past';

  // --- Voting ---
  /// POST - Submit vote
  static const String endpointSubmitVote = '/votes';

  /// GET - User's voting history
  static const String endpointVoteHistory = '/votes/history';

  /// GET - Check if user voted in election (append /{electionId})
  static const String endpointCheckVoted = '/votes/check';

  // --- Results ---
  /// GET - Election results (append /{electionId})
  static const String endpointResults = '/results';

  /// GET - Live results (WebSocket)
  static const String endpointLiveResults = '/results/live';

  // --- Notifications ---
  /// GET - User notifications
  static const String endpointNotifications = '/notifications';

  /// PATCH - Mark notification as read (append /{id})
  static const String endpointMarkNotificationRead = '/notifications';

  /// POST - Register push token
  static const String endpointRegisterPushToken = '/notifications/token';

  // --- Calendar ---
  /// GET - Calendar events
  static const String endpointCalendarEvents = '/calendar';

  // ════════════════════════════════════════════════════════════════════════════
  // UI CONSTANTS
  // ════════════════════════════════════════════════════════════════════════════

  // --- Padding/Spacing ---
  /// Extra small padding (4px)
  static const double paddingXS = 4.0;

  /// Small padding (8px)
  static const double paddingSM = 8.0;

  /// Medium padding (16px) - Most common
  static const double paddingMD = 16.0;

  /// Large padding (24px)
  static const double paddingLG = 24.0;

  /// Extra large padding (32px)
  static const double paddingXL = 32.0;

  /// Extra extra large padding (48px)
  static const double paddingXXL = 48.0;

  // --- Border Radius ---
  /// Small radius (4px)
  static const double radiusSM = 4.0;

  /// Medium radius (8px)
  static const double radiusMD = 8.0;

  /// Large radius (12px)
  static const double radiusLG = 12.0;

  /// Extra large radius (16px)
  static const double radiusXL = 16.0;

  /// Full/pill radius (9999px)
  static const double radiusFull = 9999.0;

  // --- Icon Sizes ---
  /// Small icon (16px)
  static const double iconSizeSM = 16.0;

  /// Medium icon (24px) - Default
  static const double iconSizeMD = 24.0;

  /// Large icon (32px)
  static const double iconSizeLG = 32.0;

  /// Extra large icon (48px)
  static const double iconSizeXL = 48.0;

  // --- Button Heights ---
  /// Small button height (36px)
  static const double buttonHeightSM = 36.0;

  /// Medium button height (44px)
  static const double buttonHeightMD = 44.0;

  /// Large button height (52px)
  static const double buttonHeightLG = 52.0;

  // --- Input Heights ---
  /// Input field height (48px)
  static const double inputHeight = 48.0;

  /// Text area minimum height (100px)
  static const double textAreaMinHeight = 100.0;

  // --- Avatar Sizes ---
  /// Small avatar (32px)
  static const double avatarSizeSM = 32.0;

  /// Medium avatar (48px)
  static const double avatarSizeMD = 48.0;

  /// Large avatar (64px)
  static const double avatarSizeLG = 64.0;

  /// Extra large avatar (96px)
  static const double avatarSizeXL = 96.0;

  // --- Card Elevation ---
  /// Default card elevation
  static const double cardElevation = 2.0;

  /// Elevated card
  static const double cardElevationHigh = 8.0;

  // --- Border Width ---
  /// Default border width
  static const double borderWidth = 1.0;

  /// Thick border width
  static const double borderWidthThick = 2.0;

  // ════════════════════════════════════════════════════════════════════════════
  // FEATURE FLAGS (Compile-time constants)
  // ════════════════════════════════════════════════════════════════════════════
  // For runtime flags, use AppConfig (from .env files)

  /// Email verification required for voting
  static const bool requireEmailVerification = true;

  /// Allow social login (Google, Apple)
  static const bool enableSocialLogin = false;

  /// Show election results before voting ends
  static const bool showLiveResults = true;

  /// Allow changing vote before election ends
  static const bool allowVoteChange = false;

  /// Maximum candidates per election
  static const int maxCandidatesPerElection = 50;

  /// Maximum positions per election
  static const int maxPositionsPerElection = 20;

  // ════════════════════════════════════════════════════════════════════════════
  // SUPPORT & CONTACT
  // ════════════════════════════════════════════════════════════════════════════

  /// Support email address
  static const String supportEmail = 'support@fisk.edu';

  /// Support phone number
  static const String supportPhone = '+1-615-329-8500';

  /// Fisk University website
  static const String websiteUrl = 'https://www.fisk.edu';

  /// App website/landing page
  static const String appWebsiteUrl = 'https://fiskpulse.fisk.edu';

  /// Privacy policy URL
  static const String privacyPolicyUrl = 'https://fiskpulse.fisk.edu/privacy';

  /// Terms of service URL
  static const String termsOfServiceUrl = 'https://fiskpulse.fisk.edu/terms';

  /// FAQ URL
  static const String faqUrl = 'https://fiskpulse.fisk.edu/faq';

  // ════════════════════════════════════════════════════════════════════════════
  // ERROR MESSAGES
  // ════════════════════════════════════════════════════════════════════════════

  /// Generic error message
  static const String errorGeneric = 'Something went wrong. Please try again.';

  /// Network error message
  static const String errorNetwork = 'Please check your internet connection.';

  /// Session expired message
  static const String errorSessionExpired =
      'Your session has expired. Please log in again.';

  /// Server error message
  static const String errorServer = 'Server error. Please try again later.';

  /// Validation error message
  static const String errorValidation =
      'Please check your input and try again.';

  /// Unauthorized message
  static const String errorUnauthorized =
      'You are not authorized to perform this action.';
}
