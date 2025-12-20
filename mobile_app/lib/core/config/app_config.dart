import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application configuration loaded from environment files.
///
/// This class provides type-safe access to all environment variables.
/// Values are loaded from `.env.{environment}` files via flutter_dotenv.
///
/// Usage:
/// ```dart
/// // In main.dart
/// await dotenv.load(fileName: '.env.development');
///
/// // Anywhere in the app
/// final apiUrl = AppConfig.apiBaseUrl;
/// if (AppConfig.enableLogging) { ... }
/// ```
class AppConfig {
  AppConfig._(); // Private constructor - use static methods only

  // ════════════════════════════════════════════════════════════════════════════
  // ENVIRONMENT IDENTIFICATION
  // ════════════════════════════════════════════════════════════════════════════

  /// Current environment (development, staging, production)
  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'development';

  /// Application name
  static String get appName => dotenv.env['APP_NAME'] ?? 'FiskPulse';

  /// Check if running in development
  static bool get isDevelopment => environment == 'development';

  /// Check if running in staging
  static bool get isStaging => environment == 'staging';

  /// Check if running in production
  static bool get isProduction => environment == 'production';

  // ════════════════════════════════════════════════════════════════════════════
  // API CONFIGURATION
  // ════════════════════════════════════════════════════════════════════════════

  /// Base URL for the backend API (no trailing slash)
  /// Default uses 127.0.0.1 for iOS simulator compatibility
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000';

  /// API version string
  static String get apiVersion => dotenv.env['API_VERSION'] ?? 'v1';

  /// Full API endpoint URL
  static String get apiEndpoint => '$apiBaseUrl/api/$apiVersion';

  /// API request timeout in milliseconds
  static int get apiTimeout =>
      int.tryParse(dotenv.env['API_TIMEOUT'] ?? '15000') ?? 15000;

  /// API timeout as Duration
  static Duration get apiTimeoutDuration => Duration(milliseconds: apiTimeout);

  // ════════════════════════════════════════════════════════════════════════════
  // FIREBASE CONFIGURATION
  // ════════════════════════════════════════════════════════════════════════════

  /// Firebase Project ID
  static String get firebaseProjectId =>
      dotenv.env['FIREBASE_PROJECT_ID'] ?? '';

  /// Firebase API Key
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';

  /// Firebase Android App ID
  static String get firebaseAppIdAndroid =>
      dotenv.env['FIREBASE_APP_ID_ANDROID'] ?? '';

  /// Firebase iOS App ID
  static String get firebaseAppIdIos => dotenv.env['FIREBASE_APP_ID_IOS'] ?? '';

  /// Firebase Messaging Sender ID
  static String get firebaseMessagingSenderId =>
      dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';

  /// Firebase Storage Bucket
  static String get firebaseStorageBucket =>
      dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';

  // ════════════════════════════════════════════════════════════════════════════
  // AUTHENTICATION CONFIGURATION
  // ════════════════════════════════════════════════════════════════════════════

  /// JWT token expiry time in seconds
  static int get jwtExpirySeconds =>
      int.tryParse(dotenv.env['JWT_EXPIRY_SECONDS'] ?? '86400') ?? 86400;

  /// Token refresh threshold in seconds (refresh when this many seconds remain)
  static int get tokenRefreshThreshold =>
      int.tryParse(dotenv.env['TOKEN_REFRESH_THRESHOLD'] ?? '3600') ?? 3600;

  // ════════════════════════════════════════════════════════════════════════════
  // APP SETTINGS
  // ════════════════════════════════════════════════════════════════════════════

  /// Application timezone (matches backend)
  static String get appTimezone =>
      dotenv.env['APP_TIMEZONE'] ?? 'America/Chicago';

  /// Polling interval for live results in seconds
  static int get pollingIntervalSeconds =>
      int.tryParse(dotenv.env['POLLING_INTERVAL_SECONDS'] ?? '30') ?? 30;

  /// Polling interval as Duration
  static Duration get pollingInterval =>
      Duration(seconds: pollingIntervalSeconds);

  // ════════════════════════════════════════════════════════════════════════════
  // FEATURE FLAGS
  // ════════════════════════════════════════════════════════════════════════════

  /// Enable debug logging
  static bool get enableLogging =>
      dotenv.env['ENABLE_LOGGING']?.toLowerCase() == 'true';

  /// Enable analytics tracking
  static bool get enableAnalytics =>
      dotenv.env['ENABLE_ANALYTICS']?.toLowerCase() == 'true';

  /// Enable crash reporting
  static bool get enableCrashlytics =>
      dotenv.env['ENABLE_CRASHLYTICS']?.toLowerCase() == 'true';

  /// Enable push notifications
  static bool get enablePushNotifications =>
      dotenv.env['ENABLE_PUSH_NOTIFICATIONS']?.toLowerCase() == 'true';

  /// Enable biometric authentication
  static bool get enableBiometrics =>
      dotenv.env['ENABLE_BIOMETRICS']?.toLowerCase() == 'true';

  // ════════════════════════════════════════════════════════════════════════════
  // SENTRY ERROR TRACKING
  // ════════════════════════════════════════════════════════════════════════════

  /// Sentry DSN for error tracking
  static String get sentryDsn => dotenv.env['SENTRY_DSN'] ?? '';

  /// Sentry environment
  static String get sentryEnvironment =>
      dotenv.env['SENTRY_ENVIRONMENT'] ?? environment;

  /// Check if Sentry is configured
  static bool get isSentryEnabled => sentryDsn.isNotEmpty;

  // ════════════════════════════════════════════════════════════════════════════
  // SUPPORT & CONTACT
  // ════════════════════════════════════════════════════════════════════════════

  /// Support email address
  static String get supportEmail =>
      dotenv.env['SUPPORT_EMAIL'] ?? 'support@fisk.edu';

  /// Support phone number
  static String get supportPhone =>
      dotenv.env['SUPPORT_PHONE'] ?? '+1-615-329-8500';

  /// Privacy policy URL
  static String get privacyPolicyUrl =>
      dotenv.env['PRIVACY_POLICY_URL'] ?? 'https://www.fisk.edu/privacy';

  /// Terms of service URL
  static String get termsOfServiceUrl =>
      dotenv.env['TERMS_OF_SERVICE_URL'] ?? 'https://www.fisk.edu/terms';

  // ════════════════════════════════════════════════════════════════════════════
  // DEBUG & UTILITY METHODS
  // ════════════════════════════════════════════════════════════════════════════

  /// Print all configuration values (only in development)
  static void printConfig() {
    if (!enableLogging) return;

    debugPrint('''
╔══════════════════════════════════════════════════════════════════════════════╗
║                         FiskPulse Configuration                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ Environment: $environment
║ App Name: $appName
╠──────────────────────────────────────────────────────────────────────────────╣
║ API Base URL: $apiBaseUrl
║ API Version: $apiVersion
║ API Endpoint: $apiEndpoint
║ API Timeout: ${apiTimeout}ms
╠──────────────────────────────────────────────────────────────────────────────╣
║ Firebase Project: $firebaseProjectId
║ Firebase Messaging ID: $firebaseMessagingSenderId
╠──────────────────────────────────────────────────────────────────────────────╣
║ Logging: $enableLogging
║ Analytics: $enableAnalytics
║ Crashlytics: $enableCrashlytics
║ Push Notifications: $enablePushNotifications
║ Biometrics: $enableBiometrics
╠──────────────────────────────────────────────────────────────────────────────╣
║ Sentry Enabled: $isSentryEnabled
║ Sentry Environment: $sentryEnvironment
╚══════════════════════════════════════════════════════════════════════════════╝
''');
  }

  /// Validate that required configuration values are set
  static List<String> validateConfig() {
    final errors = <String>[];

    if (apiBaseUrl.isEmpty) {
      errors.add('API_BASE_URL is not set');
    }

    if (isProduction) {
      if (!apiBaseUrl.startsWith('https://')) {
        errors.add('Production API_BASE_URL must use HTTPS');
      }
      if (enableLogging) {
        errors.add('Logging should be disabled in production');
      }
      if (firebaseProjectId.isEmpty) {
        errors.add('Firebase Project ID is required in production');
      }
    }

    return errors;
  }
}
