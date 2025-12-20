import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/config/app_config.dart';
import 'core/config/flavor_config.dart';
import 'main.dart' show FiskPulseApp;

/// Production entry point
///
/// Run with: flutter run -t lib/main_production.dart --release
/// Build with: flutter build apk -t lib/main_production.dart --release
void main() async {
  // Initialize flavor
  FlavorConfig.initialize(AppFlavor.production);

  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: FlavorConfig.envFileName);

  // Validate configuration in production
  final errors = AppConfig.validateConfig();
  if (errors.isNotEmpty) {
    // In production, we should log errors but not crash
    // These will be reported to Sentry if configured
    for (final error in errors) {
      debugPrint('Production config error: $error');
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
  //       options.tracesSampleRate = 0.2; // Sample 20% of transactions
  //     },
  //   );
  // }

  // TODO: Initialize Crashlytics
  // if (AppConfig.enableCrashlytics) {
  //   FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // }

  // Run the app
  runApp(const FiskPulseApp());
}
