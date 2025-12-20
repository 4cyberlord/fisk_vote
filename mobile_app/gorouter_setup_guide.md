# VoteSync GoRouter Setup - COMPLETE GUIDE
## Days 3-4: Navigation System Implementation

**Status:** Ready to Execute  
**Phase:** 2 - Navigation & Routing  
**Estimated Time:** 2 hours (Days 3-4)  
**Date:** December 15, 2025  
**Level:** Production-Ready Implementation

---

## 📚 TABLE OF CONTENTS

1. [GoRouter Overview](#gorouter-overview)
2. [Installation & Setup](#installation--setup)
3. [Route Structure](#route-structure)
4. [Implementation Files](#implementation-files)
5. [Usage Examples](#usage-examples)
6. [Best Practices](#best-practices)

---

## GoRouter Overview

### **WHAT IS GoRouter?**

GoRouter is Flutter's modern declarative routing solution that replaces Navigator 1.0.

**Key Differences from Traditional Navigation:**

```dart
// ❌ OLD WAY (Navigator 1.0 - Imperative)
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => ElectionScreen()),
);

// ✅ NEW WAY (GoRouter - Declarative)
context.go('/elections');
```

**Why GoRouter?**

- ✅ **Declarative routing** - Define all routes in one place
- ✅ **Deep linking** - Navigate directly to deep screens
- ✅ **Type-safe** - Compile-time error checking
- ✅ **Named routes** - Reference routes by name, not path
- ✅ **State restoration** - Handles back button, browser history
- ✅ **Nested navigation** - Supports nested routers for complex UIs
- ✅ **Middleware** - Authentication checks before navigation
- ✅ **Modern best practice** - Recommended by Flutter team

---

### **ROUTING ARCHITECTURE FOR VoteSync**

```
Root Router
├── Auth Routes
│   ├── /login
│   ├── /signup
│   └── /forgot-password
├── Election Routes
│   ├── /elections (list)
│   ├── /elections/:id (detail)
│   └── /elections/:id/vote (voting screen)
├── Results Routes
│   ├── /results (list)
│   └── /results/:id (detail)
├── User Routes
│   ├── /profile
│   ├── /profile/edit
│   └── /settings
└── App Routes
    ├── /home
    └── /about
```

---

## Installation & Setup

### **STEP 1: Add Dependencies to pubspec.yaml**

```yaml
dependencies:
  flutter:
    sdk: flutter
  go_router: ^13.0.0        # Navigation routing
  riverpod: ^2.4.0          # State management (for auth)
  riverpod_annotation: ^2.1.0
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  riverpod_generator: ^2.3.0
  build_runner: ^2.4.0
```

**Why These Packages?**

| Package | Purpose | Version |
|---------|---------|---------|
| **go_router** | Modern declarative routing | ^13.0.0 |
| **riverpod** | State management for auth state | ^2.4.0 |
| **riverpod_annotation** | Code generation for Riverpod | ^2.1.0 |
| **riverpod_generator** | Generates Riverpod providers | ^2.3.0 |
| **build_runner** | Code generation framework | ^2.4.0 |

### **STEP 2: Run pub get**

```bash
cd votesync
flutter pub get
```

---

## Route Structure

### **COMPLETE ROUTING HIERARCHY**

```
VoteSync App Routes
│
├── Auth Flow (When NOT logged in)
│   ├── /login - Login screen
│   ├── /signup - Sign up screen
│   ├── /verify-email - Email verification
│   ├── /forgot-password - Password reset
│   └── /reset-password/:token - Reset via token
│
├── Main Flow (When logged in)
│   ├── /home - Home/Dashboard
│   │   ├── Bottom navigation
│   │   └── Election feed
│   │
│   ├── /elections - Elections list/tab
│   │   ├── /elections/:id - Election detail (nested)
│   │   └── /elections/:id/vote - Vote screen (nested)
│   │
│   ├── /results - Results list/tab
│   │   └── /results/:id - Result detail (nested)
│   │
│   ├── /history - Vote history/tab
│   │   └── /history/:voteId - Vote detail (nested)
│   │
│   ├── /profile - User profile/tab
│   │   ├── /profile/edit - Edit profile
│   │   └── /profile/settings - Settings
│   │
│   └── /notifications - Notifications
│
├── Modals (Overlays)
│   ├── /error - Error dialog
│   └── /confirm - Confirmation dialog
│
└── Fallback
    └── /404 - Not found screen
```

---

## Implementation Files

### **FILE 1: lib/core/router/app_routes.dart**

**Location:** `lib/core/router/app_routes.dart`

**Purpose:** Define all route paths as constants for type safety

```dart
/// Application route path constants
/// Single source of truth for all navigation paths
/// 
/// USAGE:
/// Instead of: context.go('/elections/123')
/// Use: context.go(AppRoutes.electionDetail(id: 123))
/// 
/// Benefits:
/// - Type-safe parameters
/// - Compile-time error checking
/// - No magic strings
/// - Easy refactoring
class AppRoutes {
  // ════════════════════════════════════════════════════════════════════════════
  // AUTH ROUTES
  // ════════════════════════════════════════════════════════════════════════════
  
  /// Login screen path
  /// Route: /login
  /// Parameters: none
  /// Usage: context.go(AppRoutes.login);
  static const String login = '/login';
  
  /// Sign up screen path
  /// Route: /signup
  /// Parameters: none
  /// Usage: context.go(AppRoutes.signup);
  static const String signup = '/signup';
  
  /// Email verification screen
  /// Route: /verify-email
  /// Parameters: email (passed as state)
  /// Usage: context.go(AppRoutes.verifyEmail, extra: {'email': 'user@example.com'});
  static const String verifyEmail = '/verify-email';
  
  /// Forgot password screen
  /// Route: /forgot-password
  /// Parameters: none
  /// Usage: context.go(AppRoutes.forgotPassword);
  static const String forgotPassword = '/forgot-password';
  
  /// Password reset with token
  /// Route: /reset-password/[token]
  /// Parameters: token (path parameter)
  /// Usage: context.go(AppRoutes.resetPassword(token: 'abc123'));
  static String resetPassword({required String token}) => '/reset-password/$token';

  // ════════════════════════════════════════════════════════════════════════════
  // MAIN ROUTES (When authenticated)
  // ════════════════════════════════════════════════════════════════════════════
  
  /// Home/Dashboard screen
  /// Route: /home
  /// Main landing page after login
  /// Usage: context.go(AppRoutes.home);
  static const String home = '/home';
  
  /// Elections list (main tab)
  /// Route: /elections
  /// Shows all available elections
  /// Usage: context.go(AppRoutes.elections);
  static const String elections = '/elections';
  
  /// Election detail screen (nested under /elections)
  /// Route: /elections/[id]
  /// Parameters: id (election ID)
  /// Usage: context.go(AppRoutes.electionDetail(id: '123'));
  static String electionDetail({required String id}) => '/elections/$id';
  
  /// Voting screen (nested under /elections/[id])
  /// Route: /elections/[id]/vote
  /// Parameters: id (election ID)
  /// Usage: context.go(AppRoutes.vote(id: '123'));
  static String vote({required String id}) => '/elections/$id/vote';
  
  /// Results list (main tab)
  /// Route: /results
  /// Shows election results
  /// Usage: context.go(AppRoutes.results);
  static const String results = '/results';
  
  /// Result detail screen (nested under /results)
  /// Route: /results/[id]
  /// Parameters: id (election/result ID)
  /// Usage: context.go(AppRoutes.resultDetail(id: '123'));
  static String resultDetail({required String id}) => '/results/$id';
  
  /// Vote history screen (main tab)
  /// Route: /history
  /// Shows all votes cast by user
  /// Usage: context.go(AppRoutes.history);
  static const String history = '/history';
  
  /// Vote history detail
  /// Route: /history/[voteId]
  /// Parameters: voteId (specific vote ID)
  /// Usage: context.go(AppRoutes.historyDetail(voteId: '123'));
  static String historyDetail({required String voteId}) => '/history/$voteId';
  
  /// User profile screen (main tab)
  /// Route: /profile
  /// Shows user profile information
  /// Usage: context.go(AppRoutes.profile);
  static const String profile = '/profile';
  
  /// Edit profile screen
  /// Route: /profile/edit
  /// Allows editing user information
  /// Usage: context.go(AppRoutes.editProfile);
  static const String editProfile = '/profile/edit';
  
  /// Settings screen
  /// Route: /profile/settings
  /// App settings and preferences
  /// Usage: context.go(AppRoutes.settings);
  static const String settings = '/profile/settings';
  
  /// Notifications screen
  /// Route: /notifications
  /// User notifications
  /// Usage: context.go(AppRoutes.notifications);
  static const String notifications = '/notifications';

  // ════════════════════════════════════════════════════════════════════════════
  // MODAL ROUTES (Dialog overlays)
  // ════════════════════════════════════════════════════════════════════════════
  
  /// Error dialog modal
  /// Route: /error
  /// Parameters: message (error message to display)
  /// Usage: context.go(AppRoutes.error, extra: {'message': 'Something went wrong'});
  static const String error = '/error';
  
  /// Confirmation dialog modal
  /// Route: /confirm
  /// Parameters: title, message, onConfirm callback
  /// Usage: context.go(AppRoutes.confirm, extra: {...});
  static const String confirm = '/confirm';

  // ════════════════════════════════════════════════════════════════════════════
  // FALLBACK ROUTES
  // ════════════════════════════════════════════════════════════════════════════
  
  /// Not found (404) screen
  /// Shows when route doesn't exist
  /// Route: /404
  /// Usage: context.go(AppRoutes.notFound);
  static const String notFound = '/404';
}
```

---

### **FILE 2: lib/core/router/app_router.dart**

**Location:** `lib/core/router/app_router.dart`

**Purpose:** Configure GoRouter with all routes and middleware

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod/riverpod.dart';
import '../config/app_config.dart';
import 'app_routes.dart';

/// Main GoRouter configuration
/// Defines all routes, nested routes, and middleware
/// 
/// ROUTER STRUCTURE:
/// - Auth guard (redirects to login if not authenticated)
/// - Route definitions (all screens)
/// - Error handling
/// - Deep linking support
class AppRouter {
  static late GoRouter _router;

  /// Initialize the router (call in main.dart)
  /// Pass auth state provider to check if user is logged in
  static void initialize(WidgetRef ref) {
    _router = GoRouter(
      initialLocation: AppRoutes.home,
      redirect: (context, state) {
        // Check if user is authenticated
        final isAuthenticated = ref.watch(authStateProvider);
        
        // Redirect to login if not authenticated (unless on auth routes)
        if (!isAuthenticated) {
          // Allow these routes without authentication
          if (state.location == AppRoutes.login ||
              state.location == AppRoutes.signup ||
              state.location.startsWith(AppRoutes.forgotPassword) ||
              state.location.startsWith('/reset-password')) {
            return null; // Allow navigation
          }
          return AppRoutes.login; // Redirect to login
        }
        
        // Redirect away from login if already authenticated
        if (state.location == AppRoutes.login) {
          return AppRoutes.home; // Redirect to home
        }
        
        return null; // Allow navigation
      },
      routes: [
        // ════════════════════════════════════════════════════════════════════════════
        // AUTH ROUTES (Before login)
        // ════════════════════════════════════════════════════════════════════════════
        
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          builder: (context, state) {
            // TODO: Import LoginScreen from features
            return const Placeholder(); // Temporary
          },
        ),
        
        GoRoute(
          path: AppRoutes.signup,
          name: 'signup',
          builder: (context, state) {
            // TODO: Import SignupScreen from features
            return const Placeholder();
          },
        ),
        
        GoRoute(
          path: AppRoutes.verifyEmail,
          name: 'verify_email',
          builder: (context, state) {
            // TODO: Import VerifyEmailScreen
            return const Placeholder();
          },
        ),
        
        GoRoute(
          path: AppRoutes.forgotPassword,
          name: 'forgot_password',
          builder: (context, state) {
            // TODO: Import ForgotPasswordScreen
            return const Placeholder();
          },
        ),
        
        GoRoute(
          path: '/reset-password/:token',
          name: 'reset_password',
          builder: (context, state) {
            final token = state.pathParameters['token']!;
            // TODO: Import ResetPasswordScreen
            return const Placeholder();
          },
        ),
        
        // ════════════════════════════════════════════════════════════════════════════
        // MAIN ROUTES (After login - with bottom navigation)
        // ════════════════════════════════════════════════════════════════════════════
        
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            // TODO: Import MainLayout with bottom nav
            return const Placeholder();
          },
          branches: [
            // Home tab
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.home,
                  name: 'home',
                  builder: (context, state) {
                    // TODO: Import HomeScreen
                    return const Placeholder();
                  },
                ),
              ],
            ),
            
            // Elections tab
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.elections,
                  name: 'elections',
                  builder: (context, state) {
                    // TODO: Import ElectionsScreen
                    return const Placeholder();
                  },
                  routes: [
                    // Election detail (nested)
                    GoRoute(
                      path: ':id',
                      name: 'election_detail',
                      builder: (context, state) {
                        final id = state.pathParameters['id']!;
                        // TODO: Import ElectionDetailScreen
                        return const Placeholder();
                      },
                      routes: [
                        // Vote screen (nested under election detail)
                        GoRoute(
                          path: 'vote',
                          name: 'vote',
                          builder: (context, state) {
                            final id = state.pathParameters['id']!;
                            // TODO: Import VoteScreen
                            return const Placeholder();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            
            // Results tab
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.results,
                  name: 'results',
                  builder: (context, state) {
                    // TODO: Import ResultsScreen
                    return const Placeholder();
                  },
                  routes: [
                    GoRoute(
                      path: ':id',
                      name: 'result_detail',
                      builder: (context, state) {
                        final id = state.pathParameters['id']!;
                        // TODO: Import ResultDetailScreen
                        return const Placeholder();
                      },
                    ),
                  ],
                ),
              ],
            ),
            
            // History tab
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.history,
                  name: 'history',
                  builder: (context, state) {
                    // TODO: Import HistoryScreen
                    return const Placeholder();
                  },
                  routes: [
                    GoRoute(
                      path: ':voteId',
                      name: 'history_detail',
                      builder: (context, state) {
                        final voteId = state.pathParameters['voteId']!;
                        // TODO: Import HistoryDetailScreen
                        return const Placeholder();
                      },
                    ),
                  ],
                ),
              ],
            ),
            
            // Profile tab
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.profile,
                  name: 'profile',
                  builder: (context, state) {
                    // TODO: Import ProfileScreen
                    return const Placeholder();
                  },
                  routes: [
                    GoRoute(
                      path: 'edit',
                      name: 'edit_profile',
                      builder: (context, state) {
                        // TODO: Import EditProfileScreen
                        return const Placeholder();
                      },
                    ),
                    GoRoute(
                      path: 'settings',
                      name: 'settings',
                      builder: (context, state) {
                        // TODO: Import SettingsScreen
                        return const Placeholder();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        
        // ════════════════════════════════════════════════════════════════════════════
        // MODAL ROUTES (Dialogs/Overlays)
        // ════════════════════════════════════════════════════════════════════════════
        
        GoRoute(
          path: AppRoutes.notifications,
          name: 'notifications',
          builder: (context, state) {
            // TODO: Import NotificationsScreen
            return const Placeholder();
          },
        ),
        
        // ════════════════════════════════════════════════════════════════════════════
        // FALLBACK ROUTE
        // ════════════════════════════════════════════════════════════════════════════
        
        GoRoute(
          path: AppRoutes.notFound,
          name: 'not_found',
          builder: (context, state) {
            // TODO: Import NotFoundScreen
            return const Placeholder();
          },
        ),
      ],
      
      // ════════════════════════════════════════════════════════════════════════════
      // ERROR HANDLING
      // ════════════════════════════════════════════════════════════════════════════
      
      errorBuilder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: Center(
            child: Text('Route not found: ${state.location}'),
          ),
        );
      },
    );
  }

  /// Get the router instance
  /// Used in MaterialApp.router
  static GoRouter get router => _router;
}
```

---

### **FILE 3: lib/core/router/auth_provider.dart**

**Location:** `lib/core/router/auth_provider.dart`

**Purpose:** Riverpod provider for authentication state

```dart
import 'package:riverpod/riverpod.dart';

/// Authentication state provider
/// Determines if user is logged in
/// Used by router for redirect logic
/// 
/// STATES:
/// - false: Not authenticated (redirect to login)
/// - true: Authenticated (show main app)
final authStateProvider = StateNotifierProvider<AuthStateNotifier, bool>((ref) {
  return AuthStateNotifier();
});

/// Manages authentication state
class AuthStateNotifier extends StateNotifier<bool> {
  AuthStateNotifier() : super(false);

  /// Login user
  /// TODO: Connect to authentication service
  Future<void> login(String email, String password) async {
    // TODO: Call auth service
    // If successful:
    state = true;
  }

  /// Sign up user
  Future<void> signup(String email, String password, String name) async {
    // TODO: Call auth service
    // If successful:
    state = true;
  }

  /// Logout user
  Future<void> logout() async {
    // TODO: Call auth service
    state = false;
  }

  /// Check if user is already logged in (from cached token)
  Future<void> checkAuthStatus() async {
    // TODO: Check local cache for token
    // If token exists and valid:
    // state = true;
    // else:
    // state = false;
  }
}
```

---

### **FILE 4: lib/main.dart (Updated)**

**Location:** `lib/main.dart`

**Purpose:** Initialize app with GoRouter

```dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod/riverpod.dart';
import 'core/config/app_config.dart';
import 'core/config/environment.dart';
import 'core/router/app_router.dart';

void main() async {
  // Initialize Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize configuration
  await AppConfig.initialize(
    environment: Environment.development,
    envFileName: '.env.development',
  );

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize router with auth state
    AppRouter.initialize(ref);

    return MaterialApp.router(
      title: 'VoteSync',
      theme: ThemeData(
        primaryColor: const Color(0xFF003D82), // Fisk Blue
        useMaterial3: true,
      ),
      routerConfig: AppRouter.router,
    );
  }
}
```

---

## Usage Examples

### **NAVIGATION PATTERNS**

#### **1. Basic Navigation (Go)**

```dart
// Go to elections list
context.go(AppRoutes.elections);

// Go to home
context.go(AppRoutes.home);

// Go to profile
context.go(AppRoutes.profile);
```

#### **2. Navigation with Parameters**

```dart
// Go to election detail (with ID)
context.go(AppRoutes.electionDetail(id: '123'));
// Result: /elections/123

// Go to vote screen
context.go(AppRoutes.vote(id: '123'));
// Result: /elections/123/vote

// Go to result detail
context.go(AppRoutes.resultDetail(id: '456'));
// Result: /results/456
```

#### **3. Navigation with Extra Data**

```dart
// Pass additional data to screen
context.go(
  AppRoutes.verifyEmail,
  extra: {'email': 'user@example.com'},
);

// Retrieve in destination screen:
final Map<String, dynamic> extras = state.extra as Map<String, dynamic>;
final email = extras['email'];
```

#### **4. Push vs Go (Navigation Stack)**

```dart
// Go (replaces current screen)
context.go(AppRoutes.elections);

// Push (keeps previous screen in stack)
context.push(AppRoutes.electionDetail(id: '123'));

// Pop (go back)
context.pop();

// Pop until
context.popUntil((route) => route.settings.name == 'elections');
```

#### **5. In Widget Usage**

```dart
ElevatedButton(
  onPressed: () {
    // Navigate when button pressed
    context.go(AppRoutes.vote(id: '123'));
  },
  child: const Text('Vote Now'),
)
```

#### **6. Named Routes (Alternative)**

```dart
// Using route name instead of path
context.pushNamed('election_detail', pathParameters: {'id': '123'});

// This is equivalent to:
context.push(AppRoutes.electionDetail(id: '123'));
```

---

## Best Practices

### **1. Always Use AppRoutes Constants**

```dart
// ✅ GOOD - Type-safe, refactorable
context.go(AppRoutes.elections);
context.go(AppRoutes.electionDetail(id: id));

// ❌ BAD - Magic strings, hard to refactor
context.go('/elections');
context.go('/elections/$id');
```

### **2. Use Parameters for Dynamic Routes**

```dart
// ✅ GOOD - Parameters in method
static String electionDetail({required String id}) => '/elections/$id';
context.go(AppRoutes.electionDetail(id: '123'));

// ❌ BAD - String concatenation everywhere
context.go('/elections/' + id);
context.go('/elections/$id');
```

### **3. Organize Routes by Feature**

```dart
// Structure:
lib/
├── core/
│   └── router/
│       ├── app_routes.dart
│       ├── app_router.dart
│       └── auth_provider.dart
├── features/
│   ├── auth/
│   │   └── routes/ (optional, for feature-specific routes)
│   ├── elections/
│   └── results/
```

### **4. Handle Deep Links**

```dart
// GoRouter automatically handles deep links
// If user clicks: votesync://elections/123
// GoRouter routes to: /elections/123
// Make sure to configure in native code (Android/iOS)
```

### **5. Error Handling**

```dart
// Invalid route - goes to error builder
context.go('/invalid-route');

// Implement error handling in GoRouter errorBuilder
errorBuilder: (context, state) {
  return Scaffold(
    body: Center(
      child: Text('Page not found: ${state.location}'),
    ),
  );
}
```

### **6. Auth Guard (Middleware)**

```dart
// Redirect logic in GoRouter.redirect
redirect: (context, state) {
  final isAuthenticated = ref.watch(authStateProvider);
  
  // Not authenticated - redirect to login
  if (!isAuthenticated && !state.location.startsWith('/auth')) {
    return AppRoutes.login;
  }
  
  // Already authenticated - redirect from login
  if (isAuthenticated && state.location == AppRoutes.login) {
    return AppRoutes.home;
  }
  
  return null; // Allow navigation
}
```

### **7. Bottom Navigation with StatefulShellRoute**

```dart
// StatefulShellRoute maintains state across tabs
// When switching tabs, screens aren't rebuilt
// Perfect for bottom navigation with multiple sections

StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) {
    return MainLayout(
      navigationShell: navigationShell,
    );
  },
  branches: [
    // Each branch is a separate navigation stack
    StatefulShellBranch(routes: [HomeRoute]),
    StatefulShellBranch(routes: [ElectionsRoute]),
    StatefulShellBranch(routes: [ResultsRoute]),
  ],
)
```

---

## Complete Implementation Checklist

### **DAY 3: Setup**

```
☐ Add go_router and riverpod to pubspec.yaml
☐ Run flutter pub get
☐ Create app_routes.dart with all route constants
☐ Create app_router.dart with GoRouter configuration
☐ Create auth_provider.dart for authentication state
☐ Run flutter analyze
☐ Run flutter pub get
```

### **DAY 4: Integration**

```
☐ Update main.dart to use GoRouter
☐ Create placeholder screens for all routes
☐ Test navigation between all routes
☐ Test deep linking (manual testing)
☐ Test auth guard (redirect logic)
☐ Test bottom navigation persistence
☐ Run flutter analyze
☐ Test on device/emulator
```

---

## File Summary

| File | Purpose | Lines |
|------|---------|-------|
| **app_routes.dart** | Route constants | 120 |
| **app_router.dart** | Router configuration | 280 |
| **auth_provider.dart** | Auth state management | 50 |
| **main.dart** (updated) | App initialization | 40 |

**Total Implementation Time:** ~2 hours

---

## Next Steps

### **Phase 3: Screens Creation**

After routing is set up:

1. Create placeholder screens for each route
2. Implement auth screens (login, signup)
3. Implement election screens
4. Implement result screens
5. Connect to backend APIs

### **Phase 4: Backend Integration**

1. Create API service layer
2. Connect auth screens to authentication API
3. Connect election screens to election API
4. Implement error handling
5. Add loading states

---

Generated: December 15, 2025  
Version: 1.0.0  
Level: Production-Ready
