import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../dashboard_page.dart';
import '../../controllers/dashboard_controller.dart';
import '../../../../profile/data/repositories/profile_repository.dart';
import '../../../../profile/data/models/user_profile.dart';
import '../../../../elections/data/repositories/election_repository.dart';
import '../../../../elections/data/models/election.dart';
import '../../../../elections/data/models/election_turnout.dart';
import '../../../../voting/presentation/pages/voting_page.dart';
import '../../../../notifications/presentation/pages/activity_page.dart';
import '../../../../notifications/presentation/controllers/notification_controller.dart';
import '../../../../results/presentation/pages/results_page.dart';
import '../../../../../core/config/app_config.dart';
import '../../../data/repositories/dashboard_repository.dart';
import '../../../data/models/student_stats.dart';
import '../../../data/models/campus_participation.dart' as campus_participation;

/// Home Tab Controller
class HomeTabController extends GetxController {
  final ProfileRepository _profileRepository = ProfileRepository();
  final ElectionRepository _electionRepository = ElectionRepository();
  final DashboardRepository _dashboardRepository = DashboardRepository();

  // User data
  final Rx<UserProfile?> user = Rx<UserProfile?>(null);
  final RxBool isLoadingUser = false.obs;

  // Elections data
  final RxList<Election> activeElections = <Election>[].obs;
  final RxList<Election> upcomingElections = <Election>[].obs;
  final RxList<Election> allElections =
      <Election>[].obs; // All elections for turnout carousel
  final RxBool isLoadingElections = false.obs;

  // Turnout carousel state
  final RxInt currentTurnoutPage = 0.obs;
  final RxMap<int, ElectionTurnout?> electionTurnouts =
      <int, ElectionTurnout?>{}.obs;

  // Stats
  final RxInt electionsVoted = 0.obs;
  final RxInt totalElections = 0.obs;
  final RxInt impactScore = 0.obs;
  final Rx<StudentStats?> studentStats = Rx<StudentStats?>(null);
  final RxBool isLoadingStats = false.obs;

  // Campus Participation
  final Rx<campus_participation.CampusParticipation?> campusParticipation =
      Rx<campus_participation.CampusParticipation?>(null);
  final RxBool isLoadingCampusParticipation = false.obs;

  // Turnout cache (electionId -> ElectionTurnout)
  final Map<int, ElectionTurnout> _turnoutCache = {};
  final Map<int, DateTime> _turnoutCacheTime = {};
  static const Duration _turnoutCacheDuration = Duration(seconds: 30);

  @override
  void onInit() {
    super.onInit();
    // Ensure NotificationController is initialized
    if (!Get.isRegistered<NotificationController>()) {
      Get.put(NotificationController());
    }
    loadData();
  }

  Future<void> loadData() async {
    await Future.wait([
      loadUser(),
      loadElections(),
      loadStudentStats(),
      loadCampusParticipation(),
    ]);
    // Ensure allElections is populated
    debugPrint(
      '📊 After loadData: allElections.length = ${allElections.length}',
    );
  }

  Future<void> loadUser() async {
    try {
      isLoadingUser.value = true;
      user.value = await _profileRepository.getCurrentUser();
    } catch (e) {
      debugPrint('Error loading user: $e');
    } finally {
      isLoadingUser.value = false;
    }
  }

  Future<void> loadElections() async {
    try {
      isLoadingElections.value = true;
      final response = await _electionRepository.getElections();

      // Store all elections
      allElections.value = response.data;
      debugPrint(
        '🔄 Loaded ${response.data.length} elections into allElections',
      );

      // Filter active and upcoming elections
      activeElections.value = response.data
          .where((e) => e.isActive && !e.hasEnded)
          .toList();
      upcomingElections.value = response.data
          .where((e) => e.isUpcoming)
          .toList();

      // Preload turnout data for closed elections (for carousel)
      _preloadElectionTurnouts(response.data);

      // Calculate stats from elections (fallback if stats API fails)
      final votedCount = response.data.where((e) => e.hasVoted).length;
      final totalActive = response.data
          .where((e) => e.isActive || e.hasEnded)
          .length;
      // Only update if stats haven't been loaded yet
      if (studentStats.value == null) {
        electionsVoted.value = votedCount;
        totalElections.value = totalActive > 0 ? totalActive : 0;
      }
    } catch (e) {
      debugPrint('Error loading elections: $e');
    } finally {
      isLoadingElections.value = false;
    }
  }

  /// Preload turnout data for elections (especially closed ones and active ones)
  void _preloadElectionTurnouts(List<Election> elections) {
    // Load turnout for all elections (closed, ended, and active) in background
    // Active elections also have turnout data
    for (final election in elections) {
      // Preload for: closed/ended elections AND active elections
      final shouldPreload =
          election.hasEnded ||
          election.currentStatus.toLowerCase() == 'closed' ||
          (election.isActive && !election.hasEnded);

      if (shouldPreload) {
        getElectionTurnout(election.id)
            .then((turnout) {
              electionTurnouts[election.id] = turnout;
              debugPrint(
                '✅ Preloaded turnout for election ${election.id}: ${election.title}',
              );
            })
            .catchError((e) {
              debugPrint(
                '❌ Error preloading turnout for election ${election.id}: $e',
              );
            });
      }
    }
  }

  Future<void> loadStudentStats() async {
    try {
      isLoadingStats.value = true;
      final stats = await _dashboardRepository.getStudentStats();
      studentStats.value = stats;

      // Update reactive values
      impactScore.value = stats.impactScore.score;
      electionsVoted.value = stats.votingHistory.electionsVoted;
      totalElections.value = stats.votingHistory.totalEligibleElections;
    } catch (e) {
      debugPrint('Error loading student stats: $e');
      // Keep existing values on error
    } finally {
      isLoadingStats.value = false;
    }
  }

  Future<void> loadCampusParticipation() async {
    try {
      isLoadingCampusParticipation.value = true;
      final participation = await _dashboardRepository.getCampusParticipation();
      campusParticipation.value = participation;
    } catch (e) {
      debugPrint('Error loading campus participation: $e');
    } finally {
      isLoadingCampusParticipation.value = false;
    }
  }

  @override
  Future<void> refresh() async {
    await loadData();
    // Clear turnout cache on refresh
    clearTurnoutCache();
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  /// Get turnout for an election (with caching)
  Future<ElectionTurnout?> getElectionTurnout(int electionId) async {
    // Check cache first
    final cached = _turnoutCache[electionId];
    final cacheTime = _turnoutCacheTime[electionId];

    if (cached != null && cacheTime != null) {
      final age = DateTime.now().difference(cacheTime);
      if (age < _turnoutCacheDuration) {
        // Also update reactive map
        electionTurnouts[electionId] = cached;
        return cached;
      }
    }

    // Fetch from API
    try {
      final turnout = await _electionRepository.getElectionTurnout(
        electionId,
        includeBreakdown: false,
      );

      // Update reactive map
      electionTurnouts[electionId] = turnout;

      // Update cache
      _turnoutCache[electionId] = turnout;
      _turnoutCacheTime[electionId] = DateTime.now();

      // Update reactive map
      electionTurnouts[electionId] = turnout;

      return turnout;
    } catch (e) {
      debugPrint('Error loading turnout for election $electionId: $e');
      return null;
    }
  }

  /// Clear turnout cache (call when election status changes)
  void clearTurnoutCache() {
    _turnoutCache.clear();
    _turnoutCacheTime.clear();
    electionTurnouts.clear();
  }
}

/// Home Tab - Dashboard
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late final HomeTabController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(HomeTabController());
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: controller.refresh,
        color: DashboardColors.accent,
        backgroundColor: DashboardColors.surface,
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(child: _buildHeader()),

            // Voter Turnout Card
            SliverToBoxAdapter(child: _buildVoterTurnoutCard()),

            // Stats Row
            SliverToBoxAdapter(child: _buildStatsRow()),

            // Active Elections Section
            SliverToBoxAdapter(child: _buildActiveElectionsHeader()),
            SliverToBoxAdapter(child: _buildActiveElectionsList()),

            // Upcoming Section
            SliverToBoxAdapter(child: _buildUpcomingHeader()),
            SliverToBoxAdapter(child: _buildUpcomingList()),

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    color: DashboardColors.textGray,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(() {
                  final firstName =
                      controller.user.value?.firstName ?? 'Student';
                  return Text(
                    '${controller.getGreeting()}, $firstName!',
                    style: const TextStyle(
                      color: DashboardColors.textWhite,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }),
              ],
            ),
          ),
          Row(
            children: [
              // Notification bell with counter
              Obx(() {
                final unreadCount = Get.isRegistered<NotificationController>()
                    ? Get.find<NotificationController>().unreadCount.value
                    : 0;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Get.to(() => const ActivityPage());
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: DashboardColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: DashboardColors.textWhite,
                          size: 20,
                        ),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: DashboardColors.accent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: DashboardColors.background,
                                width: 2,
                              ),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Center(
                              child: Text(
                                unreadCount > 99 ? '99+' : '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
              const SizedBox(width: 12),
              // Profile avatar
              Obx(() {
                final photo = controller.user.value?.profilePhoto;
                return GestureDetector(
                  onTap: () {
                    // Navigate to profile
                    final dashboardController = Get.find<DashboardController>();
                    dashboardController.changeTab(4); // Profile tab
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: DashboardColors.accent,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: photo != null
                          ? Image.network(
                              _getProfilePhotoUrl(photo),
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _buildDefaultAvatar(),
                            )
                          : _buildDefaultAvatar(),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: DashboardColors.surfaceLight,
      child: const Icon(
        Icons.person,
        color: DashboardColors.textGray,
        size: 24,
      ),
    );
  }

  Widget _buildVoterTurnoutCard() {
    return Obx(() {
      final elections = controller.allElections;
      final isLoading = controller.isLoadingElections.value;

      // Debug: Log election data
      if (elections.isNotEmpty) {
        debugPrint('📊 Total elections loaded: ${elections.length}');
        for (final e in elections.take(3)) {
          debugPrint(
            '  - ${e.title}: hasEnded=${e.hasEnded}, currentStatus="${e.currentStatus}", status="${e.status}"',
          );
        }
      }

      // Filter elections for turnout display
      // Include: closed/ended elections, and active elections (they have turnout too)
      // This ensures users can see turnout for all elections, not just closed ones
      final electionsWithTurnout =
          elections.where((e) {
            // Include if:
            // 1. Election has ended (by timestamp)
            // 2. Election status is closed (case-insensitive)
            // 3. Election is active (has turnout data even when active)
            final hasEndedByTime = e.hasEnded;
            final isClosedByStatus =
                e.currentStatus.toLowerCase() == 'closed' ||
                e.status.toLowerCase() == 'closed';
            final isActive = e.isActive && !e.hasEnded;

            // Include closed/ended elections OR active elections
            final shouldInclude =
                hasEndedByTime || isClosedByStatus || isActive;

            if (shouldInclude) {
              debugPrint(
                '✅ Including election: ${e.title} (hasEnded=$hasEndedByTime, isActive=$isActive, status="${e.currentStatus}")',
              );
            }
            return shouldInclude;
          }).toList()..sort((a, b) {
            // Sort by end timestamp, newest first
            // For active elections, they'll be at the top if their end time is in the future
            return b.endTimestamp.compareTo(a.endTimestamp);
          });

      debugPrint(
        '📈 Elections with turnout: ${electionsWithTurnout.length} (out of ${elections.length} total)',
      );

      if (isLoading && electionsWithTurnout.isEmpty) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: DashboardColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: DashboardColors.accent),
          ),
        );
      }

      if (electionsWithTurnout.isEmpty) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: DashboardColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                color: DashboardColors.textGray,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                'No election turnout data available',
                style: TextStyle(
                  color: DashboardColors.textGray,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              if (elections.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '${elections.length} election(s) found, but none are closed yet.',
                  style: TextStyle(
                    color: DashboardColors.textGray.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        );
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: 280,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Election Turnout',
                    style: TextStyle(
                      color: DashboardColors.textWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Page indicator
                  Obx(() {
                    final currentPage = controller.currentTurnoutPage.value;
                    return Row(
                      children: List.generate(
                        electionsWithTurnout.length,
                        (index) => Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: currentPage == index
                                ? DashboardColors.accent
                                : DashboardColors.textGray.withValues(
                                    alpha: 0.3,
                                  ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Swipeable carousel with smooth animations
            Expanded(
              child: PageView.builder(
                controller: PageController(
                  viewportFraction: 1.0,
                  initialPage: 0,
                ),
                onPageChanged: (index) {
                  HapticFeedback.lightImpact();
                  controller.currentTurnoutPage.value = index;
                  // Preload turnout for adjacent pages
                  if (index > 0) {
                    final prevElection = electionsWithTurnout[index - 1];
                    controller.getElectionTurnout(prevElection.id);
                  }
                  if (index < electionsWithTurnout.length - 1) {
                    final nextElection = electionsWithTurnout[index + 1];
                    controller.getElectionTurnout(nextElection.id);
                  }
                },
                itemCount: electionsWithTurnout.length,
                itemBuilder: (context, index) {
                  final election = electionsWithTurnout[index];
                  // Preload turnout for current page
                  controller.getElectionTurnout(election.id);
                  return Obx(() {
                    final currentPage = controller.currentTurnoutPage.value;
                    final pageOffset = (index - currentPage).abs();
                    final scale = pageOffset == 0 ? 1.0 : 0.92;
                    final opacity = pageOffset == 0 ? 1.0 : 0.6;

                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: scale, end: scale),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Opacity(
                            opacity: opacity,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 0,
                              ),
                              child: _buildElectionTurnoutCard(election),
                            ),
                          ),
                        );
                      },
                    );
                  });
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildElectionTurnoutCard(Election election) {
    return Obx(() {
      final turnout = controller.electionTurnouts[election.id];

      return GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          // Navigate to election results detail page (Analytics View)
          Get.to(() => ElectionResultsDetailPage(electionId: election.id));
        },
        child: Container(
          decoration: BoxDecoration(
            color: DashboardColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Background gradient
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          DashboardColors.accent.withValues(alpha: 0.1),
                          DashboardColors.primary.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Election title and date
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  election.title,
                                  style: const TextStyle(
                                    color: DashboardColors.textWhite,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  election.formattedEndDate,
                                  style: TextStyle(
                                    color: DashboardColors.textGray,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: DashboardColors.accent.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Closed',
                              style: TextStyle(
                                color: DashboardColors.accent,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Turnout data
                      if (turnout == null)
                        const Expanded(
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: DashboardColors.accent,
                              ),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Participation rate
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Participation Rate',
                                          style: TextStyle(
                                            color: DashboardColors.textGray,
                                            fontSize: 11,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${turnout.turnout.participationRate.toStringAsFixed(1)}%',
                                          style: const TextStyle(
                                            color: DashboardColors.textWhite,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Votes',
                                          style: TextStyle(
                                            color: DashboardColors.textGray,
                                            fontSize: 11,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${turnout.turnout.totalVoted}',
                                          style: const TextStyle(
                                            color: DashboardColors.textWhite,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '/ ${turnout.turnout.totalEligibleVoters}',
                                          style: TextStyle(
                                            color: DashboardColors.textGray,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Progress bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: turnout.turnout.participationGoal > 0
                                      ? (turnout.turnout.participationRate /
                                                turnout
                                                    .turnout
                                                    .participationGoal)
                                            .clamp(0.0, 1.0)
                                      : 0.0,
                                  backgroundColor: DashboardColors.surfaceLight,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    DashboardColors.accent,
                                  ),
                                  minHeight: 5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Goal: ${turnout.turnout.participationGoal.toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      color: DashboardColors.textGray,
                                      fontSize: 9,
                                    ),
                                  ),
                                  Text(
                                    '${turnout.turnout.percentageToGoal.toStringAsFixed(1)}% to goal',
                                    style: TextStyle(
                                      color: DashboardColors.accent,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }


  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Elections Voted
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DashboardColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Elections Voted',
                          style: TextStyle(
                            color: DashboardColors.textGray,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.how_to_vote_outlined,
                          color: DashboardColors.textGray,
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${controller.electionsVoted.value}',
                            style: const TextStyle(
                              color: DashboardColors.textWhite,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6, left: 4),
                            child: Text(
                              '/${controller.totalElections.value}',
                              style: TextStyle(
                                color: DashboardColors.textGray,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Progress bar
                    Obx(() {
                      final progress = controller.totalElections.value > 0
                          ? controller.electionsVoted.value /
                                controller.totalElections.value
                          : 0.0;
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: DashboardColors.surfaceLight,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            DashboardColors.accent,
                          ),
                          minHeight: 6,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Impact Score
            Expanded(
              child: Obx(() {
                final stats = controller.studentStats.value;
                final isLoading = controller.isLoadingStats.value;
                final score =
                    stats?.impactScore.score ?? controller.impactScore.value;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: DashboardColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Impact Score',
                            style: TextStyle(
                              color: DashboardColors.textGray,
                              fontSize: 13,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.bolt,
                            color: DashboardColors.accent,
                            size: 18,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          isLoading
                              ? SizedBox(
                                  width: 40,
                                  height: 32,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: DashboardColors.accent,
                                  ),
                                )
                              : Text(
                                  '$score',
                                  style: const TextStyle(
                                    color: DashboardColors.textWhite,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6, left: 4),
                            child: Text(
                              'pts',
                              style: TextStyle(
                                color: DashboardColors.textGray,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (stats != null &&
                          stats.impactScore.description.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: DashboardColors.accent.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            stats.impactScore.description,
                            style: TextStyle(
                              color: DashboardColors.accent,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveElectionsHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Active Elections',
            style: TextStyle(
              color: DashboardColors.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: () {
              // Navigate to elections tab
              final dashboardController = Get.find<DashboardController>();
              dashboardController.changeTab(1);
            },
            child: Text(
              'See All',
              style: TextStyle(
                color: DashboardColors.accent,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveElectionsList() {
    return Obx(() {
      if (controller.isLoadingElections.value) {
        return const Padding(
          padding: EdgeInsets.all(40),
          child: Center(
            child: CircularProgressIndicator(color: DashboardColors.accent),
          ),
        );
      }

      if (controller.activeElections.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: DashboardColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.how_to_vote_outlined,
                  color: DashboardColors.textGray,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'No Active Elections',
                  style: TextStyle(
                    color: DashboardColors.textGray,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: controller.activeElections.length > 2
            ? 2
            : controller.activeElections.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final election = controller.activeElections[index];
          return _buildActiveElectionCard(election);
        },
      );
    });
  }

  Widget _buildActiveElectionCard(Election election) {
    final isEndingSoon = election.isEndingSoon;
    final hoursLeft = election.hoursUntilEnd;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DashboardColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Election icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: DashboardColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.how_to_vote,
                  color: DashboardColors.textWhite,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // Election info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      election.title,
                      style: const TextStyle(
                        color: DashboardColors.textWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      election.type,
                      style: TextStyle(
                        color: DashboardColors.textGray,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isEndingSoon
                      ? Colors.orange.withValues(alpha: 0.2)
                      : DashboardColors.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isEndingSoon ? 'Ends in ${hoursLeft}h' : 'Active',
                  style: TextStyle(
                    color: isEndingSoon
                        ? Colors.orange
                        : DashboardColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Participation goal with real data
          FutureBuilder<ElectionTurnout?>(
            future: controller.getElectionTurnout(election.id),
            builder: (context, snapshot) {
              // Loading state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 40,
                  child: Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: DashboardColors.accent,
                      ),
                    ),
                  ),
                );
              }

              // Error state - show fallback with default values
              if (snapshot.hasError || snapshot.data == null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Participation Goal',
                          style: TextStyle(
                            color: DashboardColors.textGray,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '80%',
                          style: const TextStyle(
                            color: DashboardColors.textWhite,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 0.0,
                        backgroundColor: DashboardColors.surfaceLight,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          DashboardColors.accent,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                );
              }

              final turnout = snapshot.data!;
              final participationRate = turnout.turnout.participationRate;
              final participationGoal = turnout.turnout.participationGoal;
              final progress = participationGoal > 0
                  ? (participationRate / participationGoal).clamp(0.0, 1.0)
                  : 0.0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Participation Goal',
                        style: TextStyle(
                          color: DashboardColors.textGray,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${participationGoal.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: DashboardColors.textWhite,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: DashboardColors.surfaceLight,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        DashboardColors.accent,
                      ),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${participationRate.toStringAsFixed(1)}% participation',
                    style: TextStyle(
                      color: DashboardColors.textGray,
                      fontSize: 11,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          // Vote button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: election.hasVoted
                  ? null
                  : () {
                      Get.to(() => VotingPage(electionId: election.id));
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: DashboardColors.accent,
                foregroundColor: Colors.black,
                disabledBackgroundColor: DashboardColors.surfaceLight,
                disabledForegroundColor: DashboardColors.textGray,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    election.hasVoted ? 'Voted' : 'Vote Now',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!election.hasVoted) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 18),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        'Upcoming',
        style: TextStyle(
          color: DashboardColors.textWhite,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildUpcomingList() {
    return Obx(() {
      if (controller.upcomingElections.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: DashboardColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: DashboardColors.textGray,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'No upcoming elections',
                  style: TextStyle(
                    color: DashboardColors.textGray,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: controller.upcomingElections.length > 3
            ? 3
            : controller.upcomingElections.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final election = controller.upcomingElections[index];
          return _buildUpcomingCard(election);
        },
      );
    });
  }

  Widget _buildUpcomingCard(Election election) {
    final startDate = DateTime.tryParse(election.startTime);
    final month = startDate != null
        ? [
            'JAN',
            'FEB',
            'MAR',
            'APR',
            'MAY',
            'JUN',
            'JUL',
            'AUG',
            'SEP',
            'OCT',
            'NOV',
            'DEC',
          ][startDate.month - 1]
        : 'TBD';
    final day = startDate?.day.toString().padLeft(2, '0') ?? '--';

    // Calculate days until start
    final now = DateTime.now();
    final daysUntil = startDate != null ? startDate.difference(now).inDays : 0;
    final subtitle = daysUntil == 0
        ? 'Starts today'
        : daysUntil == 1
        ? 'Starts tomorrow'
        : 'Registration closes in $daysUntil days';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DashboardColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Date box
          Container(
            width: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: DashboardColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  month,
                  style: TextStyle(
                    color: DashboardColors.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  day,
                  style: const TextStyle(
                    color: DashboardColors.textWhite,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // Election info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  election.title,
                  style: const TextStyle(
                    color: DashboardColors.textWhite,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: DashboardColors.textGray,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Arrow
          Icon(Icons.chevron_right, color: DashboardColors.textGray, size: 24),
        ],
      ),
    );
  }
}
