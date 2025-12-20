import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profile_controller.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import 'personal_info_page.dart';
import 'password_security_page.dart';
import 'help_support_page.dart';
import 'voting_history_page.dart';

/// Profile Page - Main profile screen
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: DashboardColors.background,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: DashboardColors.accent),
            );
          }

          final user = controller.userProfile.value;
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: DashboardColors.textGray,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load profile',
                    style: TextStyle(
                      color: DashboardColors.textGray,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => controller.refresh(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DashboardColors.accent,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // Header
              _buildHeader(context),
              // Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Profile Picture & Info
                    _buildProfileSection(context, user, controller),
                    const SizedBox(height: 24),
                    // Voting Activity Card - ARCHIVED
                    // _buildVotingActivityCard(context, controller),
                    
                    // Voting History Section
                    _buildVotingHistorySection(context, controller),
                    const SizedBox(height: 24),
                    // Account Section
                    _buildAccountSection(context),
                    const SizedBox(height: 16),
                    // Security & Privacy Section
                    _buildSecuritySection(context),
                    const SizedBox(height: 16),
                    // Support Section
                    _buildSupportSection(context),
                    const SizedBox(height: 24),
                    // Logout Button
                    _buildLogoutButton(context, controller),
                    const SizedBox(height: 24),
                    // Footer
                    _buildFooter(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverAppBar(
      backgroundColor: DashboardColors.background,
      elevation: 0,
      pinned: true,
      centerTitle: true,
      title: const Text(
        'My Profile',
        style: TextStyle(
          color: DashboardColors.textWhite,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.settings,
            color: DashboardColors.textWhite,
            size: 24,
          ),
          onPressed: () {
            // TODO: Navigate to settings
          },
        ),
      ],
    );
  }

  Widget _buildProfileSection(
    BuildContext context,
    dynamic user,
    ProfileController controller,
  ) {
    return Column(
      children: [
        // Profile Picture
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: DashboardColors.accent, width: 3),
            image: user.profilePhoto != null
                ? DecorationImage(
                    image: NetworkImage(
                      _getProfilePhotoUrl(user.profilePhoto!),
                    ),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      // Handle image load error
                    },
                  )
                : null,
          ),
          child: user.profilePhoto == null
              ? Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: DashboardColors.surface,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: DashboardColors.textGray,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 16),
        // Name
        Text(
          user.name,
          style: const TextStyle(
            color: DashboardColors.textWhite,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Class & ID
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user.graduationYear != null) ...[
              Text(
                'Class of ${user.graduationYear}',
                style: const TextStyle(
                  color: DashboardColors.textWhite,
                  fontSize: 14,
                ),
              ),
              const Text(
                ' • ',
                style: TextStyle(
                  color: DashboardColors.textWhite,
                  fontSize: 14,
                ),
              ),
            ],
            Text(
              'ID: ',
              style: const TextStyle(
                color: DashboardColors.textWhite,
                fontSize: 14,
              ),
            ),
            Text(
              user.studentId ?? 'N/A',
              style: const TextStyle(
                color: DashboardColors.accent,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Verified Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: DashboardColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 16),
              const SizedBox(width: 6),
              const Text(
                'Verified Voter',
                style: TextStyle(
                  color: DashboardColors.textWhite,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Voting Activity Card - ARCHIVED
  // Widget _buildVotingActivityCard(
  //   BuildContext context,
  //   ProfileController controller,
  // ) {
  //   return GestureDetector(
  //     onTap: () {
  //       // Refresh stats when card is tapped
  //       controller.refreshStats();
  //     },
  //     child: Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 16),
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: DashboardColors.surface,
  //       borderRadius: BorderRadius.circular(16),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             const Text(
  //               'Voting Activity',
  //               style: TextStyle(
  //                 color: DashboardColors.textWhite,
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //             GestureDetector(
  //               onTap: () {
  //                   Get.to(() => const VotingHistoryPage());
  //               },
  //               child: const Text(
  //                 'View History',
  //                 style: TextStyle(
  //                   color: DashboardColors.accent,
  //                   fontSize: 14,
  //                   fontWeight: FontWeight.w500,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 20),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceAround,
  //           children: [
  //             Obx(
  //               () => _buildStatItem(
  //                 '${controller.electionsVoted.value}',
  //                 'ELECTIONS VOTED',
  //               DashboardColors.textWhite,
  //                 icon: Icons.how_to_vote,
  //               ),
  //             ),
  //             Obx(
  //               () => _buildStatItem(
  //                 '#${controller.campusRank.value}',
  //                 'CAMPUS RANK',
  //               DashboardColors.accent,
  //                 icon: Icons.emoji_events,
  //               ),
  //             ),
  //             Obx(
  //               () => _buildStatItem(
  //                 '${controller.percentile.value.toStringAsFixed(1)}%',
  //                 'PERCENTILE',
  //                 DashboardColors.textWhite,
  //                 icon: Icons.trending_up,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 24),
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 const Text(
  //                   'Campus Impact Score',
  //                   style: TextStyle(
  //                     color: DashboardColors.textWhite,
  //                     fontSize: 14,
  //                     fontWeight: FontWeight.w600,
  //                   ),
  //                 ),
  //                 Obx(
  //                   () => Text(
  //                     controller.impactScore.value > 0
  //                         ? '${controller.impactScore.value}/200'
  //                         : '${controller.campusImpactScore.value.toInt()}%',
  //                     style: TextStyle(
  //                       color: DashboardColors.accent,
  //                       fontSize: 14,
  //                       fontWeight: FontWeight.w700,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(height: 10),
  //             Obx(
  //               () {
  //                 final progress = (controller.campusImpactScore.value / 100).clamp(0.0, 1.0);
  //                 return Container(
  //                   height: 8,
  //                   decoration: BoxDecoration(
  //                     color: DashboardColors.backgroundDark,
  //                     borderRadius: BorderRadius.circular(4),
  //                   ),
  //                   child: ClipRRect(
  //                     borderRadius: BorderRadius.circular(4),
  //                     child: Stack(
  //                       children: [
  //                         Container(
  //                           width: double.infinity,
  //                           color: DashboardColors.backgroundDark,
  //                         ),
  //                         FractionallySizedBox(
  //                           widthFactor: progress,
  //                           child: AnimatedContainer(
  //                             duration: const Duration(milliseconds: 600),
  //                             curve: Curves.easeOut,
  //                             decoration: BoxDecoration(
  //                               color: DashboardColors.accent,
  //                               borderRadius: BorderRadius.circular(4),
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 );
  //               },
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 8),
  //         Obx(
  //           () => Text(
  //             controller.impactDescription.value.isNotEmpty
  //                 ? controller.impactDescription.value
  //                 : 'Your impact on campus democracy',
  //             style: TextStyle(
  //               color: DashboardColors.textGray,
  //               fontSize: 12,
  //               fontStyle: FontStyle.italic,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //     ),
  //   );
  // }

  Widget _buildVotingHistorySection(
    BuildContext context,
    ProfileController controller,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DashboardColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: DashboardColors.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.history,
                  color: DashboardColors.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                      'Voting History',
                style: TextStyle(
                  color: DashboardColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
                    const SizedBox(height: 4),
                    Text(
                      'Track record of all elections you\'ve participated in',
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
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              Get.to(() => const VotingHistoryPage());
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DashboardColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: DashboardColors.accent.withValues(alpha: 0.3),
                  width: 1,
              ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: DashboardColors.backgroundDark,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          color: DashboardColors.accent,
                          size: 20,
              ),
          ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'View All Elections Voted',
            style: TextStyle(
              color: DashboardColors.textWhite,
              fontSize: 14,
                              fontWeight: FontWeight.w600,
            ),
          ),
                          SizedBox(height: 2),
                          Text(
                            'See your complete voting track record',
                            style: TextStyle(
                              color: DashboardColors.textGray,
                              fontSize: 12,
                            ),
                  ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                      color: DashboardColors.accent,
                        size: 20,
                    ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                      color: DashboardColors.accent,
                        size: 16,
                      ),
                    ],
                ),
              ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // _buildStatItem method - ARCHIVED (no longer used after commenting out Voting Activity section)
  // Widget _buildStatItem(
  //   String value,
  //   String label,
  //   Color valueColor, {
  //   IconData? icon,
  //   Color? iconColor,
  // }) {
  //   return Column(
  //     children: [
  //       Row(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           if (icon != null) ...[
  //             Icon(icon, size: 16, color: iconColor),
  //             const SizedBox(width: 4),
  //           ],
  //           Text(
  //             value,
  //             style: TextStyle(
  //               color: valueColor,
  //               fontSize: 24,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //         ],
  //       ),
  //       const SizedBox(height: 4),
  //       Text(
  //         label,
  //         style: const TextStyle(
  //           color: DashboardColors.textGray,
  //           fontSize: 11,
  //           fontWeight: FontWeight.w400,
  //         ),
  //       ),
  //     ],
  //   );
  // }


  Widget _buildAccountSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'ACCOUNT',
            style: TextStyle(
              color: DashboardColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          context,
          icon: Icons.person_outline,
          iconColor: Colors.blue,
          title: 'Personal Information',
          onTap: () {
            Get.to(() => const PersonalInfoPage());
          },
        ),
        const SizedBox(height: 8),
        _buildMenuItem(
          context,
          icon: Icons.school_outlined,
          iconColor: Colors.blue,
          title: 'Student Status',
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: DashboardColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Coming Soon',
              style: TextStyle(
                color: DashboardColors.textGray,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          onTap: null,
        ),
      ],
    );
  }

  Widget _buildSecuritySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'SECURITY & PRIVACY',
            style: TextStyle(
              color: DashboardColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          context,
          icon: Icons.lock_outline,
          iconColor: Colors.green,
          title: 'Password & Security',
          onTap: () {
            Get.to(() => const PasswordSecurityPage());
          },
        ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'SUPPORT',
            style: TextStyle(
              color: DashboardColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          context,
          icon: Icons.help_outline,
          iconColor: Colors.purple,
          title: 'Help & FAQ',
          onTap: () {
            Get.to(() => const HelpSupportPage());
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    final isDisabled = onTap == null;
    return Opacity(
      opacity: isDisabled ? 0.6 : 1.0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: DashboardColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: DashboardColors.textWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (trailing != null)
                    trailing
                  else
                    const Icon(
                      Icons.chevron_right,
                      color: DashboardColors.textGray,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(
    BuildContext context,
    ProfileController controller,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () {
          // Show confirmation dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: DashboardColors.surface,
              title: const Text(
                'Log Out',
                style: TextStyle(color: DashboardColors.textWhite),
              ),
              content: const Text(
                'Are you sure you want to log out?',
                style: TextStyle(color: DashboardColors.textGray),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: DashboardColors.textGray),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    controller.logout();
                  },
                  child: const Text(
                    'Log Out',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: DashboardColors.surface,
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Log Out',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        'Fisk Pulse v${AppConstants.appVersion}',
        style: TextStyle(color: DashboardColors.textMuted, fontSize: 12),
      ),
    );
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
