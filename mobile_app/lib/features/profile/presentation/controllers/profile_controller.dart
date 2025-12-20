import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../data/models/user_profile.dart';
import '../../data/models/voting_stats.dart';
import '../../data/repositories/profile_repository.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../features/auth/data/repositories/auth_repository.dart';
import '../../../../features/auth/presentation/pages/login_page.dart';

/// Profile controller for managing user profile state.
class ProfileController extends GetxController {
  final ProfileRepository _repository = ProfileRepository();

  // Profile data
  final Rx<UserProfile?> userProfile = Rx<UserProfile?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Voting stats - loaded from API
  final RxInt electionsVoted = 0.obs; // Unique elections voted in
  final RxInt campusRank = 0.obs; // User's rank among all students
  final RxDouble percentile = 0.0.obs; // User's percentile ranking
  final RxDouble campusImpactScore = 0.0.obs;
  final RxInt impactScore = 0.obs;
  final RxDouble participationRate = 0.0.obs;
  final RxInt totalStudents = 0.obs; // Total students in the system
  final RxString impactDescription = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  /// Load user profile from API
  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      error.value = '';

      // Load profile first
      final profile = await _repository.getCurrentUser();
      userProfile.value = profile;

      // Load stats separately (don't fail if stats fail)
      _loadVotingStats();
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load profile: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load voting statistics from API
  /// Uses REAL data from the backend API endpoints
  Future<void> _loadVotingStats() async {
    try {
      debugPrint('🔄 Loading voting stats from API...');
      
      // First, ensure we have stats data (required)
      final statsData = await _repository.getVotingStats();
      debugPrint('📦 Stats API Response: $statsData');
      
      // Then try to get voting history (optional, for additional data)
      List<Map<String, dynamic>> votingHistory = [];
      try {
        votingHistory = await _repository.getVotingHistory();
        debugPrint('📅 Voting History: ${votingHistory.length} actual votes from API');
      } catch (e) {
        debugPrint('⚠️ Could not load voting history (optional): $e');
        // Continue without voting history - stats are more important
      }
      
      // Parse stats using REAL API data
      final stats = VotingStats.fromJson(statsData, votingHistory);

      // Update observable values with REAL API data
      electionsVoted.value = stats.electionsVoted; // Unique elections from API
      campusRank.value = stats.campusRank; // Rank from API
      percentile.value = stats.percentile; // Percentile from API
      campusImpactScore.value = stats.campusImpactScore; // Real impact score
      impactScore.value = stats.impactScore ?? 0; // Real impact score value
      participationRate.value = stats.participationRate; // Real rate from API
      totalStudents.value = stats.totalStudents ?? 0; // Total students from API
      impactDescription.value = stats.description ?? ''; // Real description
      
      debugPrint('✅ REAL API Data loaded successfully:');
      debugPrint('   - Elections Voted (from API): ${stats.electionsVoted}');
      debugPrint('   - Campus Rank (from API): ${stats.campusRank}');
      debugPrint('   - Percentile (from API): ${stats.percentile}%');
      debugPrint('   - Impact Score (from API): ${stats.impactScore}');
      debugPrint('   - Campus Impact Score: ${stats.campusImpactScore}%');
      debugPrint('   - Participation Rate: ${stats.participationRate}%');
      debugPrint('   - Total Students: ${stats.totalStudents}');
    } catch (e, stackTrace) {
      // Log error for debugging
      debugPrint('❌ Failed to load voting stats from API: $e');
      debugPrint('Stack trace: $stackTrace');
      // If stats fail to load, keep default values (0)
      // Don't show error to user as stats are secondary to profile
    }
  }

  /// Refresh profile data
  @override
  Future<void> refresh() async {
    await loadProfile();
  }

  /// Refresh voting stats only
  Future<void> refreshStats() async {
    await _loadVotingStats();
  }

  /// Upload profile photo
  Future<bool> uploadProfilePhoto(File imageFile) async {
    try {
      isLoading.value = true;
      error.value = '';

      final photoUrl = await _repository.uploadProfilePhoto(imageFile);

      // Update local profile with new photo URL
      final currentProfile = userProfile.value;
      if (currentProfile != null) {
        userProfile.value = UserProfile(
          id: currentProfile.id,
          name: currentProfile.name,
          firstName: currentProfile.firstName,
          lastName: currentProfile.lastName,
          middleInitial: currentProfile.middleInitial,
          email: currentProfile.email,
          universityEmail: currentProfile.universityEmail,
          personalEmail: currentProfile.personalEmail,
          emailVerifiedAt: currentProfile.emailVerifiedAt,
          studentId: currentProfile.studentId,
          department: currentProfile.department,
          major: currentProfile.major,
          classLevel: currentProfile.classLevel,
          enrollmentStatus: currentProfile.enrollmentStatus,
          studentType: currentProfile.studentType,
          citizenshipStatus: currentProfile.citizenshipStatus,
          phoneNumber: currentProfile.phoneNumber,
          address: currentProfile.address,
          profilePhoto: photoUrl,
          roles: currentProfile.roles,
          organizations: currentProfile.organizations,
          createdAt: currentProfile.createdAt,
          updatedAt: currentProfile.updatedAt,
        );
      }

      Get.snackbar(
        'Success',
        'Profile photo updated successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
        duration: const Duration(seconds: 2),
      );

      return true;
    } on ValidationException catch (e) {
      error.value = e.message;
      Get.snackbar(
        'Validation Error',
        e.message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 3),
      );
      return false;
    } on ApiException catch (e) {
      error.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 3),
      );
      return false;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to upload profile photo: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 3),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      final authRepo = AuthRepository();
      await authRepo.logout();
      authRepo.clearAuthToken();
    } catch (e) {
      // Even if logout fails, clear local state
      final authRepo = AuthRepository();
      authRepo.clearAuthToken();
    } finally {
      // Delete all GetX controllers to clear cached data (including login form)
      Get.deleteAll();

      // Navigate to login page with fresh state
      Get.offAll(() => const LoginPage());
    }
  }
}
