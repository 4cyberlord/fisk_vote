import 'package:get/get.dart';

/// Dashboard controller for managing bottom navigation
class DashboardController extends GetxController {
  // Current selected tab index
  final currentIndex = 0.obs;

  // Tab titles for app bar
  final List<String> tabTitles = ['Home', 'Vote', 'Results', 'Blog', 'Profile'];

  /// Get current tab title
  String get currentTitle => tabTitles[currentIndex.value];

  /// Change tab
  void changeTab(int index) {
    currentIndex.value = index;
  }

  /// Navigate to specific tab by name
  void goToHome() => changeTab(0);
  void goToVote() => changeTab(1);
  void goToResults() => changeTab(2);
  void goToBlog() => changeTab(3);
  void goToProfile() => changeTab(4);
}
