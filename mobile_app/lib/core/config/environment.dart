import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application environment types.
///
/// Each environment has different configurations for API endpoints,
/// feature flags, and security settings.
enum Environment {
  /// Local development environment
  /// - Uses localhost API
  /// - Full logging enabled
  /// - Analytics disabled
  development,

  /// QA/Testing environment
  /// - Uses staging API server
  /// - Logging enabled for debugging
  /// - Analytics enabled for testing
  staging,

  /// Live production environment
  /// - Uses production API server
  /// - Logging disabled
  /// - Full security enabled
  production,
}

/// Environment configuration and management.
///
/// This class handles environment detection, initialization, and provides
/// utilities for environment-specific behavior.
///
/// ## Usage
///
/// ```dart
/// // Initialize at app startup
/// await EnvironmentConfig.initialize(Environment.development);
///
/// // Check current environment
/// if (EnvironmentConfig.isDevelopment) {
///   // Development-only code
/// }
///
/// // Get environment file name
/// final envFile = EnvironmentConfig.envFileName;
/// ```
///
/// ## Environment Files
///
/// | Environment | File | Purpose |
/// |-------------|------|---------|
/// | development | .env.development | Local development |
/// | staging | .env.staging | QA testing |
/// | production | .env.production | Live app |
class EnvironmentConfig {
  EnvironmentConfig._(); // Private constructor

  static Environment _environment = Environment.development;
  static bool _isInitialized = false;

  // ════════════════════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ════════════════════════════════════════════════════════════════════════════

  /// Initialize the environment configuration.
  ///
  /// This should be called once at app startup before any other configuration.
  ///
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   await EnvironmentConfig.initialize(Environment.development);
  ///   runApp(MyApp());
  /// }
  /// ```
  static Future<void> initialize(Environment environment) async {
    _environment = environment;

    // Load the appropriate .env file
    try {
      await dotenv.load(fileName: envFileName);
      _isInitialized = true;

      if (kDebugMode) {
        debugPrint('✅ Environment initialized: ${environment.name}');
        debugPrint('📄 Loaded: $envFileName');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to load $envFileName: $e');
        debugPrint('📄 Attempting to load .env.example as fallback...');
      }

      // Fallback to example file for development
      try {
        await dotenv.load(fileName: '.env.example');
        _isInitialized = true;
      } catch (_) {
        if (kDebugMode) {
          debugPrint('❌ No environment file found. Using defaults.');
        }
      }
    }
  }

  /// Check if environment has been initialized
  static bool get isInitialized => _isInitialized;

  // ════════════════════════════════════════════════════════════════════════════
  // ENVIRONMENT GETTERS
  // ════════════════════════════════════════════════════════════════════════════

  /// Get the current environment
  static Environment get current => _environment;

  /// Get the environment name as string
  static String get name => _environment.name;

  /// Check if running in development
  static bool get isDevelopment => _environment == Environment.development;

  /// Check if running in staging
  static bool get isStaging => _environment == Environment.staging;

  /// Check if running in production
  static bool get isProduction => _environment == Environment.production;

  /// Check if running in debug mode (development or staging)
  static bool get isDebugMode =>
      _environment == Environment.development ||
      _environment == Environment.staging;

  // ════════════════════════════════════════════════════════════════════════════
  // ENVIRONMENT FILE NAMES
  // ════════════════════════════════════════════════════════════════════════════

  /// Get the environment file name for the current environment
  static String get envFileName {
    switch (_environment) {
      case Environment.development:
        return '.env.development';
      case Environment.staging:
        return '.env.staging';
      case Environment.production:
        return '.env.production';
    }
  }

  /// Get environment file name for a specific environment
  static String getEnvFileName(Environment env) {
    switch (env) {
      case Environment.development:
        return '.env.development';
      case Environment.staging:
        return '.env.staging';
      case Environment.production:
        return '.env.production';
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // DISPLAY HELPERS
  // ════════════════════════════════════════════════════════════════════════════

  /// Get a display-friendly name for the environment
  static String get displayName {
    switch (_environment) {
      case Environment.development:
        return 'Development';
      case Environment.staging:
        return 'Staging';
      case Environment.production:
        return 'Production';
    }
  }

  /// Get a short label for the environment (for badges, etc.)
  static String get shortLabel {
    switch (_environment) {
      case Environment.development:
        return 'DEV';
      case Environment.staging:
        return 'STG';
      case Environment.production:
        return 'PROD';
    }
  }

  /// Get the app bundle ID suffix for the environment
  static String get bundleIdSuffix {
    switch (_environment) {
      case Environment.development:
        return '.dev';
      case Environment.staging:
        return '.staging';
      case Environment.production:
        return '';
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // UTILITY METHODS
  // ════════════════════════════════════════════════════════════════════════════

  /// Run code only in development environment
  static void runInDevelopment(VoidCallback callback) {
    if (isDevelopment) callback();
  }

  /// Run code only in staging environment
  static void runInStaging(VoidCallback callback) {
    if (isStaging) callback();
  }

  /// Run code only in production environment
  static void runInProduction(VoidCallback callback) {
    if (isProduction) callback();
  }

  /// Run code only in debug mode (development or staging)
  static void runInDebugMode(VoidCallback callback) {
    if (isDebugMode) callback();
  }

  /// Get a value based on current environment
  static T select<T>({
    required T development,
    required T staging,
    required T production,
  }) {
    switch (_environment) {
      case Environment.development:
        return development;
      case Environment.staging:
        return staging;
      case Environment.production:
        return production;
    }
  }

  /// Print environment information (only in debug mode)
  static void printInfo() {
    if (!kDebugMode) return;

    debugPrint('''
╔══════════════════════════════════════════════════════════════════════════════╗
║                          Environment Information                             ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ Environment: $displayName ($name)
║ Initialized: $isInitialized
║ File: $envFileName
║ Debug Mode: $isDebugMode
║ Bundle Suffix: ${bundleIdSuffix.isEmpty ? '(none)' : bundleIdSuffix}
╚══════════════════════════════════════════════════════════════════════════════╝
''');
  }
}
