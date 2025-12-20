// cSpell:ignore dotenv, cupertino, prefs
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/app_config.dart';
import 'core/config/flavor_config.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/onboarding_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/splash_screen.dart';
import 'features/voting/presentation/pages/voting_page.dart';

/// Development entry point
///
/// Run with: flutter run -t lib/main.dart
void main() async {
  // Initialize flavor
  FlavorConfig.initialize(AppFlavor.development);

  // Run the app
  await _initializeApp();
}

/// Common app initialization logic
Future<void> _initializeApp() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: FlavorConfig.envFileName);
  } catch (e) {
    debugPrint('⚠️ Could not load ${FlavorConfig.envFileName}, using defaults');
  }

  // DEVELOPMENT: Use local API during development
  // Override API_BASE_URL to connect to local backend
  dotenv.env['API_BASE_URL'] = 'http://localhost:8000';
  dotenv.env['ENABLE_LOGGING'] = 'true';

  // Print config in development
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

/// Root application widget using GetX
class FiskPulseApp extends StatelessWidget {
  const FiskPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: !AppConfig.isProduction,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      defaultTransition: Transition.cupertino,
      home: const AppLauncher(),
      getPages: [
        GetPage(name: '/register', page: () => const RegisterPage()),
        GetPage(
          name: '/voting/:id',
          page: () {
            final electionId = int.tryParse(Get.parameters['id'] ?? '0') ?? 0;
            return VotingPage(electionId: electionId);
          },
        ),
      ],
    );
  }
}

/// App launcher that handles initial routing
///
/// Shows splash screen, then determines whether to show:
/// - Onboarding (first launch)
/// - Login (not authenticated)
/// - Home (authenticated)
class AppLauncher extends StatefulWidget {
  const AppLauncher({super.key});

  @override
  State<AppLauncher> createState() => _AppLauncherState();
}

class _AppLauncherState extends State<AppLauncher> {
  bool _isLoading = true;
  bool _showOnboarding = false;
  bool _onboardingChecked = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    // Check if onboarding has been completed (in background during splash)
    final prefs = await SharedPreferences.getInstance();
    final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

    if (mounted) {
      setState(() {
        _showOnboarding = !onboardingComplete;
        _onboardingChecked = true;
      });
    }
  }

  void _onSplashComplete() {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onOnboardingComplete() {
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show animated splash screen while loading
    if (_isLoading) {
      return SplashScreen(
        loadingDuration: const Duration(seconds: 2),
        onLoadingComplete: _onboardingChecked ? _onSplashComplete : null,
      );
    }

    // Show onboarding if first launch
    if (_showOnboarding) {
      return OnboardingPage(
        onComplete: _onOnboardingComplete,
        onLogin: _onOnboardingComplete,
        onRegister: _onOnboardingComplete,
      );
    }

    // Show login page (after onboarding or when not authenticated)
    return const LoginPage();
  }
}
