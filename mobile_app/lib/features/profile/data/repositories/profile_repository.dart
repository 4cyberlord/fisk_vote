import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exceptions.dart';
import '../models/user_profile.dart';

/// Repository for profile-related API calls.
class ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  /// Get current authenticated user profile.
  ///
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [ServerException] for server errors.
  /// Throws [NetworkException] if no internet connection.
  Future<UserProfile> getCurrentUser() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.me);

      final responseData = response.data as Map<String, dynamic>;

      // Handle API response structure: {success, message, data: {...}}
      Map<String, dynamic> data;
      if (responseData.containsKey('data') &&
          responseData['data'] is Map<String, dynamic>) {
        data = responseData['data'] as Map<String, dynamic>;
      } else {
        data = responseData;
      }

      return UserProfile.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  /// Change password for the authenticated user.
  ///
  /// Returns true if the password was changed successfully.
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final response = await _apiClient.post(
        '/students/me/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        },
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return true;
      }
      throw ApiException(
        message: data['message'] as String? ?? 'Failed to change password',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  /// Fetch audit logs for the authenticated user.
  ///
  /// Returns a map containing logs and statistics.
  Future<Map<String, dynamic>> getAuditLogs() async {
    try {
      final response = await _apiClient.get('/students/me/audit-logs');
      final data = response.data as Map<String, dynamic>;
      return data;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  /// Get voting statistics for the authenticated user.
  ///
  /// Returns voting stats including total votes, participation rate, impact score, etc.
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [ServerException] for server errors.
  Future<Map<String, dynamic>> getVotingStats() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.studentStats);

      final responseData = response.data as Map<String, dynamic>;

      // Handle API response structure: {success, message, data: {...}}
      Map<String, dynamic> data;
      if (responseData.containsKey('data') &&
          responseData['data'] is Map<String, dynamic>) {
        data = responseData['data'] as Map<String, dynamic>;
      } else {
        data = responseData;
      }

      debugPrint('📊 Stats API Response: $data');
      return data;
    } on ApiException catch (e) {
      debugPrint('❌ Stats API Error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Stats Unknown Error: $e');
      throw UnknownException(message: e.toString());
    }
  }

  /// Get voting history for the authenticated user.
  ///
  /// Returns list of elections the user has voted in with actual vote dates.
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [ServerException] for server errors.
  Future<List<Map<String, dynamic>>> getVotingHistory() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.votingHistory);

      final responseData = response.data as Map<String, dynamic>;

      // Handle API response structure: {success, message, data: [...]}
      List<dynamic> data;
      if (responseData.containsKey('data') &&
          responseData['data'] is List) {
        data = responseData['data'] as List<dynamic>;
      } else {
        data = [];
      }

      final votes = data.map((item) => item as Map<String, dynamic>).toList();
      debugPrint('📊 Voting history: ${votes.length} total votes retrieved from API');
      return votes;
    } on ApiException catch (e) {
      debugPrint('❌ Voting history API error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Voting history unknown error: $e');
      throw UnknownException(message: e.toString());
    }
  }

  /// Update user profile information.
  ///
  /// Updates profile fields like department, major, class_level, student_type, etc.
  /// Throws [ValidationException] if validation fails.
  /// Throws [ServerException] for server errors.
  Future<UserProfile> updateProfile({
    String? personalEmail,
    String? phoneNumber,
    String? address,
    String? department,
    String? major,
    String? classLevel,
    String? studentType,
    String? enrollmentStatus,
    String? citizenshipStatus,
    List<int>? organizations,
  }) async {
    try {
      final data = <String, dynamic>{};
      
      if (personalEmail != null) data['personal_email'] = personalEmail;
      if (phoneNumber != null) data['phone_number'] = phoneNumber;
      if (address != null) data['address'] = address;
      if (department != null) data['department'] = department;
      if (major != null) data['major'] = major;
      if (classLevel != null) data['class_level'] = classLevel;
      if (studentType != null) data['student_type'] = studentType;
      if (enrollmentStatus != null) data['enrollment_status'] = enrollmentStatus;
      if (citizenshipStatus != null) data['citizenship_status'] = citizenshipStatus;
      if (organizations != null) data['organizations'] = organizations;

      final response = await _apiClient.put(
        ApiEndpoints.updateProfile,
        data: data,
      );

      final responseData = response.data as Map<String, dynamic>;

      // Handle API response structure: {success, message, data: {user: {...}}}
      Map<String, dynamic> userData;
      if (responseData.containsKey('data') &&
          responseData['data'] is Map<String, dynamic>) {
        final nestedData = responseData['data'] as Map<String, dynamic>;
        if (nestedData.containsKey('user') &&
            nestedData['user'] is Map<String, dynamic>) {
          userData = nestedData['user'] as Map<String, dynamic>;
        } else {
          userData = nestedData;
        }
      } else {
        userData = responseData;
      }

      return UserProfile.fromJson(userData);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  /// Upload profile photo for the authenticated user.
  ///
  /// Returns the updated profile photo URL.
  /// Throws [ValidationException] if file is invalid.
  /// Throws [ServerException] for server errors.
  Future<String> uploadProfilePhoto(File imageFile) async {
    try {
      // Create multipart form data
      final fileName = imageFile.path.split('/').last;
      final formData = {
        'profile_photo': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      };

      final response = await _apiClient.postMultipart(
        ApiEndpoints.updateProfilePhoto,
        fields: formData,
      );

      final responseData = response.data as Map<String, dynamic>;
      
      // Handle API response structure: {success, message, data: {profile_photo: ...}}
      Map<String, dynamic> data;
      if (responseData.containsKey('data') &&
          responseData['data'] is Map<String, dynamic>) {
        data = responseData['data'] as Map<String, dynamic>;
      } else {
        data = responseData;
      }

      final photoUrl = data['profile_photo'] as String?;
      if (photoUrl == null) {
        throw ApiException(message: 'Profile photo URL not returned from server');
      }

      return photoUrl;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }
}
