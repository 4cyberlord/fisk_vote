import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/profile_completion_controller.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';

/// Profile Completion Page
/// Mandatory screen shown after login if profile is incomplete
/// User cannot proceed until all required fields are filled
class ProfileCompletionPage extends StatefulWidget {
  const ProfileCompletionPage({super.key});

  @override
  State<ProfileCompletionPage> createState() => _ProfileCompletionPageState();
}

class _ProfileCompletionPageState extends State<ProfileCompletionPage> {
  late final ProfileCompletionController controller;
  late final TextEditingController departmentController;
  late final TextEditingController majorController;
  late final TextEditingController citizenshipController;
  late final TextEditingController personalEmailController;
  late final TextEditingController phoneController;
  late final TextEditingController addressController;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ProfileCompletionController());
    
    // Initialize text controllers
    departmentController = TextEditingController(text: controller.department.value);
    majorController = TextEditingController(text: controller.major.value);
    citizenshipController = TextEditingController(text: controller.citizenshipStatus.value);
    personalEmailController = TextEditingController(text: controller.personalEmail.value);
    phoneController = TextEditingController(text: controller.phoneNumber.value);
    addressController = TextEditingController(text: controller.address.value);
    
    // Listen to controller changes and update text fields
    controller.department.listen((value) {
      if (departmentController.text != value) {
        departmentController.text = value;
      }
    });
    controller.major.listen((value) {
      if (majorController.text != value) {
        majorController.text = value;
      }
    });
    controller.citizenshipStatus.listen((value) {
      if (citizenshipController.text != value) {
        citizenshipController.text = value;
      }
    });
    controller.personalEmail.listen((value) {
      if (personalEmailController.text != value) {
        personalEmailController.text = value;
      }
    });
    controller.phoneNumber.listen((value) {
      if (phoneController.text != value) {
        phoneController.text = value;
      }
    });
    controller.address.listen((value) {
      if (addressController.text != value) {
        addressController.text = value;
      }
    });
  }

  @override
  void dispose() {
    departmentController.dispose();
    majorController.dispose();
    citizenshipController.dispose();
    personalEmailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        // Prevent back navigation - user must complete profile
        // didPop will be false since canPop is false
      },
      child: Scaffold(
        backgroundColor: DashboardColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Progress indicator
              _buildProgressIndicator(controller),
              
              // Form content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      const Text(
                        'Complete Your Profile',
                        style: TextStyle(
                          color: DashboardColors.textWhite,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please provide the following information to continue using the app',
                        style: TextStyle(
                          color: DashboardColors.textGray,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Academic Information Section
                      _buildSectionTitle('Academic Information'),
                      const SizedBox(height: 16),
                      
                      // Department or Major
                      Obx(() {
                        // Access observable directly to ensure GetX tracks it
                        final fieldErrors = controller.fieldErrors;
                        final error = fieldErrors['academic'];
                        final departments = controller.departments;
                        final isLoading = controller.isLoadingDepartments.value;
                        
                        // If departments are loaded, show dropdown, otherwise show text field
                        if (departments.isNotEmpty) {
                          return _buildDropdown(
                            label: 'Department',
                            value: controller.department.value.isEmpty
                                ? null
                                : controller.department.value,
                            items: controller.departmentNames,
                            onChanged: (value) {
                              if (value != null) {
                                controller.department.value = value;
                              }
                            },
                            error: error,
                            required: true,
                            isLoading: isLoading,
                          );
                        } else {
                          return _buildTextField(
                            controller: departmentController,
                            label: 'Department',
                            hint: isLoading ? 'Loading departments...' : 'Enter your department',
                            onChanged: (value) => controller.department.value = value,
                            error: error,
                            required: true,
                          );
                        }
                      }),
                      const SizedBox(height: 16),
                      
                      // Major
                      Obx(() {
                        final majors = controller.majors;
                        final isLoading = controller.isLoadingMajors.value;
                        
                        // If majors are loaded, show dropdown, otherwise show text field
                        if (majors.isNotEmpty) {
                          return _buildDropdown(
                            label: 'Major',
                            value: controller.major.value.isEmpty
                                ? null
                                : controller.major.value,
                            items: controller.majorNames,
                            onChanged: (value) {
                              if (value != null) {
                                controller.major.value = value;
                              }
                            },
                            error: null,
                            required: false,
                            isLoading: isLoading,
                          );
                        } else {
                          return _buildTextField(
                            controller: majorController,
                            label: 'Major',
                            hint: isLoading ? 'Loading majors...' : 'Enter your major',
                            onChanged: (value) => controller.major.value = value,
                            required: false,
                          );
                        }
                      }),
                      const SizedBox(height: 16),
                      
                      // Class Level
                      Obx(() => _buildDropdown(
                        label: 'Class Level',
                        value: controller.classLevel.value.isEmpty
                            ? null
                            : controller.classLevel.value,
                        items: controller.classLevelOptions,
                        onChanged: (value) {
                          if (value != null) {
                            controller.classLevel.value = value;
                          }
                        },
                        error: controller.getFieldError('classLevel'),
                        required: true,
                      )),
                      const SizedBox(height: 16),
                      
                      // Student Type
                      Obx(() {
                        // Access observables directly
                        final studentType = controller.studentType.value;
                        final fieldErrors = controller.fieldErrors;
                        final error = fieldErrors['studentType'];
                        return _buildDropdown(
                          label: 'Student Type',
                          value: studentType.isEmpty ? null : studentType,
                          items: controller.studentTypeOptions,
                          onChanged: (value) {
                            if (value != null) {
                              controller.studentType.value = value;
                            }
                          },
                          error: error,
                          required: true,
                        );
                      }),
                      const SizedBox(height: 16),
                      
                      // Citizenship Status (Optional)
                      _buildTextField(
                        controller: citizenshipController,
                        label: 'Citizenship Status',
                        hint: 'Enter your citizenship status (optional)',
                        onChanged: (value) => controller.citizenshipStatus.value = value,
                        required: false,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Contact Information Section (Optional)
                      _buildSectionTitle('Contact Information (Optional)'),
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: personalEmailController,
                        label: 'Personal Email',
                        hint: 'Your personal email address',
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) => controller.personalEmail.value = value,
                        required: false,
                      ),
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: phoneController,
                        label: 'Phone Number',
                        hint: 'Your phone number',
                        keyboardType: TextInputType.phone,
                        onChanged: (value) => controller.phoneNumber.value = value,
                        required: false,
                      ),
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: addressController,
                        label: 'Address',
                        hint: 'Your address',
                        maxLines: 3,
                        onChanged: (value) => controller.address.value = value,
                        required: false,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Error message
                      Obx(() => controller.error.value.isNotEmpty
                          ? Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      controller.error.value,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink()),
                      
                      // Submit button
                      Obx(() => SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value || !controller.isFormValid
                              ? null
                              : controller.submitProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DashboardColors.accent,
                            foregroundColor: Colors.black,
                            disabledBackgroundColor: DashboardColors.accent.withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.black,
                                  ),
                                )
                              : const Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      )),
                      
                      const SizedBox(height: 24),
                      
                      // Help text
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: DashboardColors.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: DashboardColors.accent,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'This information is required to match you with eligible elections and ensure accurate voting.',
                                style: TextStyle(
                                  color: DashboardColors.textGray,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DashboardColors.surface,
        border: Border(
          bottom: BorderSide(
            color: DashboardColors.backgroundDark,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DashboardColors.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.person_add_outlined,
              color: DashboardColors.accent,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile Setup',
                  style: TextStyle(
                    color: DashboardColors.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Complete your profile to continue',
                  style: TextStyle(
                    color: DashboardColors.textGray,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(ProfileCompletionController controller) {
    return Obx(() {
      final requiredFields = [
        controller.department.value.isNotEmpty || controller.major.value.isNotEmpty,
        controller.classLevel.value.isNotEmpty,
        controller.studentType.value.isNotEmpty,
      ];
      final completedCount = requiredFields.where((field) => field == true).length;
      final progress = completedCount / requiredFields.length;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: DashboardColors.surface,
          border: Border(
            bottom: BorderSide(
              color: DashboardColors.backgroundDark,
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: TextStyle(
                    color: DashboardColors.textGray,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '$completedCount of ${requiredFields.length} required fields',
                  style: TextStyle(
                    color: DashboardColors.textGray,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: DashboardColors.backgroundDark,
                valueColor: AlwaysStoppedAnimation<Color>(DashboardColors.accent),
                minHeight: 6,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: DashboardColors.textWhite,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required Function(String) onChanged,
    String? error,
    bool required = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: DashboardColors.textWhite,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (required) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(
            color: DashboardColors.textWhite,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: DashboardColors.textGray.withValues(alpha: 0.6),
              fontSize: 14,
            ),
            filled: true,
            fillColor: DashboardColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: error != null
                    ? Colors.red
                    : DashboardColors.backgroundDark,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: error != null
                    ? Colors.red
                    : DashboardColors.backgroundDark,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: error != null
                    ? Colors.red
                    : DashboardColors.accent,
                width: 2,
              ),
            ),
            errorText: error,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    String? error,
    bool required = false,
    bool isLoading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: DashboardColors.textWhite,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (required) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: DashboardColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: error != null && error.isNotEmpty
                  ? Colors.red
                  : DashboardColors.backgroundDark,
            ),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: value,
            items: isLoading
                ? [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text(
                        'Loading...',
                        style: TextStyle(
                          color: DashboardColors.textGray,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ]
                : items.map((item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(
                          color: DashboardColors.textWhite,
                          fontSize: 15,
                        ),
                      ),
                    );
                  }).toList(),
            onChanged: isLoading ? null : onChanged,
            decoration: InputDecoration(
              hintText: 'Select an option',
              hintStyle: TextStyle(
                color: DashboardColors.textGray.withValues(alpha: 0.6),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              errorText: error,
            ),
            dropdownColor: DashboardColors.surface,
            icon: Icon(
              Icons.arrow_drop_down,
              color: DashboardColors.textGray,
            ),
            style: const TextStyle(
              color: DashboardColors.textWhite,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}

