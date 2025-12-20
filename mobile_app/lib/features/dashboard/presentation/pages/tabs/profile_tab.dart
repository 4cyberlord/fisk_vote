import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../profile/presentation/controllers/profile_controller.dart';
import '../../../../profile/presentation/pages/profile_page.dart';

/// Profile Tab - Wrapper for Profile Page
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize profile controller
    Get.put(ProfileController());

    return const ProfilePage();
  }
}
