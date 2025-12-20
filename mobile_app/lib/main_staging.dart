// cSpell:ignore dotenv
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/config/app_config.dart';
import 'core/config/flavor_config.dart';
import 'main.dart' show FiskPulseApp;

/// Staging entry point
///
/// Run with: flutter run -t lib/main_staging.dart
void main() async {
  // Initialize flavor
  FlavorConfig.initialize(AppFlavor.staging);

  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  // cSpell:ignore dotenv
  try {
    await dotenv.load(fileName: FlavorConfig.envFileName);
  } catch (e) {
    debugPrint('⚠️ Could not load ${FlavorConfig.envFileName}, using defaults');
  }

  // DEVELOPMENT OVERRIDE: Use local API during development
  // Remove or comment this out when you have a real staging server
  // cSpell:ignore dotenv
  dotenv.env['API_BASE_URL'] = 'http://127.0.0.1:8000';
  dotenv.env['ENABLE_LOGGING'] = 'true';

  // Print config in staging (logging is enabled)
  if (AppConfig.enableLogging) {
    AppConfig.printConfig();

    // Validate configuration
    final errors = AppConfig.validateConfig();
    if (errors.isNotEmpty) {
      debugPrint('⚠️ Configuration warnings:');
      for (final error in errors) {
        debugPrint('  - $error');
      }
    }
  }

  // TODO: Initialize Firebase
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // TODO: Initialize Sentry
  // if (AppConfig.isSentryEnabled) {
  //   await SentryFlutter.init(
  //     (options) {
  //       options.dsn = AppConfig.sentryDsn;
  //       options.environment = AppConfig.sentryEnvironment;
  //     },
  //   );
  // }

  // Run the app
  runApp(const FiskPulseApp());
}
