/// Enumeration of application build flavors.
enum AppFlavor { development, staging, production }

/// Configuration class for managing build flavors.
///
/// This class works alongside the environment files (.env.*) to provide
/// flavor-specific configuration. While .env files provide runtime values,
/// this class provides compile-time constants for flavor identification.
class FlavorConfig {
  FlavorConfig._();

  static AppFlavor _flavor = AppFlavor.development;

  /// Initialize the flavor configuration
  static void initialize(AppFlavor flavor) {
    _flavor = flavor;
  }

  /// Get the current flavor
  static AppFlavor get flavor => _flavor;

  /// Check if running development flavor
  static bool get isDevelopment => _flavor == AppFlavor.development;

  /// Check if running staging flavor
  static bool get isStaging => _flavor == AppFlavor.staging;

  /// Check if running production flavor
  static bool get isProduction => _flavor == AppFlavor.production;

  /// Get the environment file name for the current flavor
  static String get envFileName {
    switch (_flavor) {
      case AppFlavor.development:
        return '.env.development';
      case AppFlavor.staging:
        return '.env.staging';
      case AppFlavor.production:
        return '.env.production';
    }
  }

  /// Get the flavor name as a string
  static String get flavorName {
    switch (_flavor) {
      case AppFlavor.development:
        return 'Development';
      case AppFlavor.staging:
        return 'Staging';
      case AppFlavor.production:
        return 'Production';
    }
  }

  /// Get the app suffix for the current flavor (used for app bundle ID)
  static String get appIdSuffix {
    switch (_flavor) {
      case AppFlavor.development:
        return '.dev';
      case AppFlavor.staging:
        return '.staging';
      case AppFlavor.production:
        return '';
    }
  }
}
