import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/user_profile.dart';
import '../controllers/profile_controller.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../../core/config/app_config.dart';

/// Personal Information Page - Edit user's personal details
class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final ProfileController _controller = Get.find<ProfileController>();
  final ImagePicker _imagePicker = ImagePicker();
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  File? _selectedImage;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    final user = _controller.userProfile.value;
    if (user != null) {
      _fullNameController = TextEditingController(text: user.name);
      _emailController = TextEditingController(text: user.email);
      _phoneController = TextEditingController(text: user.phoneNumber ?? '');
    } else {
      _fullNameController = TextEditingController();
      _emailController = TextEditingController();
      _phoneController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardColors.background,
      appBar: AppBar(
        backgroundColor: DashboardColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: DashboardColors.textWhite,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Personal Info',
          style: TextStyle(
            color: DashboardColors.textWhite,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(() {
        final user = _controller.userProfile.value;
        if (user == null) {
          return const Center(
            child: CircularProgressIndicator(color: DashboardColors.accent),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Profile Picture
              Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: DashboardColors.accent,
                        width: 3,
                      ),
                    ),
                    child: ClipOval(
                      child: _isUploading
                          ? Container(
                              color: DashboardColors.surface,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: DashboardColors.accent,
                                  strokeWidth: 3,
                                ),
                              ),
                            )
                          : _selectedImage != null
                              ? Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                  width: 120,
                                  height: 120,
                                )
                              : user.profilePhoto != null
                                  ? Image.network(
                                      _getProfilePhotoUrl(user.profilePhoto!),
                                      fit: BoxFit.cover,
                                      width: 120,
                                      height: 120,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Container(
                                          color: DashboardColors.surface,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                      loadingProgress.expectedTotalBytes!
                                                  : null,
                                              color: DashboardColors.accent,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: DashboardColors.surface,
                                          ),
                                          child: const Icon(
                                            Icons.person,
                                            size: 60,
                                            color: DashboardColors.textGray,
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: DashboardColors.surface,
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: DashboardColors.textGray,
                                      ),
                                    ),
                    ),
                  ),
                  // Edit Icon
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _isUploading ? null : _handleImageEdit,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isUploading
                              ? DashboardColors.textGray
                              : DashboardColors.accent,
                        ),
                        child: _isUploading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Icon(
                                Icons.edit,
                                color: Colors.black,
                                size: 18,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // Full Name Field
              _buildField(
                label: 'FULL NAME',
                icon: Icons.person_outline,
                controller: _fullNameController,
                enabled: false,
              ),
              const SizedBox(height: 20),
              // Email Address Field
              _buildField(
                label: 'EMAIL ADDRESS',
                icon: Icons.mail_outline,
                controller: _emailController,
                enabled: false,
              ),
              const SizedBox(height: 20),
              // Phone Number Field
              _buildField(
                label: 'PHONE NUMBER',
                icon: Icons.phone_outlined,
                controller: _phoneController,
                enabled: false,
              ),
              const SizedBox(height: 20),
              // Campus ID Field
              _buildCampusIdField(user),
              const SizedBox(height: 20),
              // Department Field
              if (user.department != null && user.department!.isNotEmpty)
                _buildReadOnlyField(
                  label: 'DEPARTMENT',
                  icon: Icons.business_outlined,
                  value: user.department!,
                ),
              if (user.department != null && user.department!.isNotEmpty)
                const SizedBox(height: 20),
              // Major Field
              if (user.major != null && user.major!.isNotEmpty)
                _buildReadOnlyField(
                  label: 'MAJOR',
                  icon: Icons.menu_book_outlined,
                  value: user.major!,
                ),
              if (user.major != null && user.major!.isNotEmpty)
                const SizedBox(height: 20),
              // Class Level Field
              if (user.classLevel != null && user.classLevel!.isNotEmpty)
                _buildReadOnlyField(
                  label: 'CLASS LEVEL',
                  icon: Icons.class_outlined,
                  value: user.classLevel!,
                ),
              if (user.classLevel != null && user.classLevel!.isNotEmpty)
                const SizedBox(height: 20),
              // Student Type Field
              if (user.studentType != null && user.studentType!.isNotEmpty)
                _buildReadOnlyField(
                  label: 'STUDENT TYPE',
                  icon: Icons.school_outlined,
                  value: user.studentType!,
                ),
              if (user.studentType != null && user.studentType!.isNotEmpty)
                const SizedBox(height: 20),
              // Enrollment Status Field
              if (user.enrollmentStatus != null && user.enrollmentStatus!.isNotEmpty)
                _buildReadOnlyField(
                  label: 'ENROLLMENT STATUS',
                  icon: Icons.verified_user_outlined,
                  value: user.enrollmentStatus!,
                ),
              if (user.enrollmentStatus != null && user.enrollmentStatus!.isNotEmpty)
                const SizedBox(height: 20),
              // University Email Field
              if (user.universityEmail != null && user.universityEmail!.isNotEmpty)
                _buildReadOnlyField(
                  label: 'UNIVERSITY EMAIL',
                  icon: Icons.school_outlined,
                  value: user.universityEmail!,
                ),
              if (user.universityEmail != null && user.universityEmail!.isNotEmpty)
                const SizedBox(height: 20),
              // Personal Email Field
              if (user.personalEmail != null && user.personalEmail!.isNotEmpty)
                _buildReadOnlyField(
                  label: 'PERSONAL EMAIL',
                  icon: Icons.alternate_email_outlined,
                  value: user.personalEmail!,
                ),
              if (user.personalEmail != null && user.personalEmail!.isNotEmpty)
                const SizedBox(height: 20),
              // Address Field
              if (user.address != null && user.address!.isNotEmpty)
                _buildReadOnlyField(
                  label: 'ADDRESS',
                  icon: Icons.location_on_outlined,
                  value: user.address!,
                ),
              if (user.address != null && user.address!.isNotEmpty)
                const SizedBox(height: 20),
              // Citizenship Status Field
              if (user.citizenshipStatus != null && user.citizenshipStatus!.isNotEmpty)
                _buildReadOnlyField(
                  label: 'CITIZENSHIP STATUS',
                  icon: Icons.flag_outlined,
                  value: user.citizenshipStatus!,
                ),
              if (user.citizenshipStatus != null && user.citizenshipStatus!.isNotEmpty)
                const SizedBox(height: 20),
              const SizedBox(height: 24),
              // Info Message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DashboardColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: DashboardColors.textMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Personal information can only be updated by administration. Contact support for assistance.',
                        style: TextStyle(
                          color: DashboardColors.textMuted,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Save Changes Button (only show if image is selected)
              if (_selectedImage != null)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _handleSaveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DashboardColors.accent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: DashboardColors.textGray,
                    ),
                    child: _isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Text(
                            'Upload Photo',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required bool enabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: DashboardColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2F3B57), // Match login input background
            borderRadius: BorderRadius.circular(28),
          ),
          child: TextFormField(
            controller: controller,
            enabled: enabled,
            style: const TextStyle(
              color: DashboardColors.textWhite,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(
                0xFF2F3B57,
              ), // Match login input background
              prefixIcon: Icon(
                icon,
                color: DashboardColors.textWhite,
                size: 20,
              ),
              suffixIcon: enabled == false
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Icon(
                        Icons.lock_outline,
                        color: DashboardColors.textWhite,
                        size: 20,
                      ),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required IconData icon,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: DashboardColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2F3B57), // Match login input background
            borderRadius: BorderRadius.circular(28),
          ),
          child: TextFormField(
            controller: TextEditingController(text: value),
            enabled: false,
            style: const TextStyle(
              color: DashboardColors.textWhite,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF2F3B57), // Match login input background
              prefixIcon: Icon(
                icon,
                color: DashboardColors.textWhite,
                size: 20,
              ),
              suffixIcon: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(
                  Icons.lock_outline,
                  color: DashboardColors.textWhite,
                  size: 20,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCampusIdField(UserProfile user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CAMPUS ID',
              style: TextStyle(
                color: DashboardColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            // Verified Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 14),
                  const SizedBox(width: 4),
                  const Text(
                    'VERIFIED',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2F3B57), // Match login input background
            borderRadius: BorderRadius.circular(28),
          ),
          child: TextFormField(
            controller: TextEditingController(text: user.studentId ?? 'N/A'),
            enabled: false,
            style: const TextStyle(
              color: DashboardColors.textWhite,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(
                0xFF2F3B57,
              ), // Match login input background
              prefixIcon: const Icon(
                Icons.business_outlined,
                color: DashboardColors.textWhite,
                size: 20,
              ),
              suffixIcon: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(
                  Icons.lock_outline,
                  color: DashboardColors.textWhite,
                  size: 20,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Campus ID cannot be changed. Contact administration for assistance.',
            style: TextStyle(
              color: DashboardColors.textMuted,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  /// Handle image edit button tap
  Future<void> _handleImageEdit() async {
    // Show bottom sheet with options
    final source = await Get.bottomSheet<ImageSource>(
      Container(
        decoration: BoxDecoration(
          color: DashboardColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: DashboardColors.textGray.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: DashboardColors.accent,
                ),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(color: DashboardColors.textWhite),
                ),
                onTap: () => Get.back(result: ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: DashboardColors.accent,
                ),
                title: const Text(
                  'Take Photo',
                  style: TextStyle(color: DashboardColors.textWhite),
                ),
                onTap: () => Get.back(result: ImageSource.camera),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );

    if (source == null) return;

    try {
      // Pick image
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Handle save changes button tap
  Future<void> _handleSaveChanges() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final success = await _controller.uploadProfilePhoto(_selectedImage!);

      if (success) {
        setState(() {
          _selectedImage = null; // Clear selected image after successful upload
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to upload photo: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  /// Get full URL for profile photo
  String _getProfilePhotoUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    // Remove leading slash if present
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '${AppConfig.apiBaseUrl}/$cleanPath';
  }
}
