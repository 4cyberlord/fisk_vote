import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/election_controller.dart';
import '../../data/models/election.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../voting/presentation/pages/voting_page.dart';

/// Elections Page
class ElectionsPage extends StatefulWidget {
  const ElectionsPage({super.key});

  @override
  State<ElectionsPage> createState() => _ElectionsPageState();
}

class _ElectionsPageState extends State<ElectionsPage> {
  late final ElectionController _controller;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(ElectionController());
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text != _controller.searchQuery.value) {
        _controller.setSearchQuery(_searchController.text);
      }
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(),
            // Fixed Search Bar and Category Filters
            Column(
              children: [
                const SizedBox(height: 16),
                // Search Bar
                _buildSearchBar(),
                const SizedBox(height: 16),
                // Category Filters
                _buildCategoryFilters(),
                const SizedBox(height: 16),
              ],
            ),
            // Scrollable Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _controller.refresh(),
                color: DashboardColors.accent,
                child: CustomScrollView(
                  slivers: [
                    // Add top padding
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
                    // Show all elections when "All Elections" is selected
                    Obx(() {
                      if (_controller.selectedCategory.value ==
                          'All Elections') {
                        final filtered = _controller.filteredElections;
                        if (filtered.isEmpty) {
                          return const SliverToBoxAdapter(
                            child: SizedBox.shrink(),
                          );
                        }
                        return SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            if (index == 0) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Text(
                                  'All Elections (${filtered.length})',
                                  style: const TextStyle(
                                    color: DashboardColors.textWhite,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }
                            final electionIndex = index - 1;
                            if (electionIndex < filtered.length) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildElectionCard(
                                  filtered[electionIndex],
                                  filtered[electionIndex].isUpcoming,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }, childCount: filtered.length + 1),
                        );
                      }
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    }),
                    // Active Now Section (only when not showing all)
                    Obx(() {
                      if (_controller.selectedCategory.value ==
                          'All Elections') {
                        return const SliverToBoxAdapter(
                          child: SizedBox.shrink(),
                        );
                      }
                      // Access observables directly
                      _controller.selectedCategory.value;
                      _controller.searchQuery.value;
                      _controller.allElections.length;

                      final activeElections = _controller.activeElections;
                      if (activeElections.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: SizedBox.shrink(),
                        );
                      }
                      return SliverToBoxAdapter(
                        child: _buildSection(
                          title: 'Active Now',
                          elections: activeElections,
                          showPriority: true,
                        ),
                      );
                    }),
                    // Upcoming Section (only when not showing all)
                    Obx(() {
                      if (_controller.selectedCategory.value ==
                          'All Elections') {
                        return const SliverToBoxAdapter(
                          child: SizedBox.shrink(),
                        );
                      }
                      // Access observables directly
                      _controller.selectedCategory.value;
                      _controller.searchQuery.value;
                      _controller.allElections.length;

                      final upcomingElections = _controller.upcomingElections;
                      if (upcomingElections.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: SizedBox.shrink(),
                        );
                      }
                      return SliverToBoxAdapter(
                        child: _buildSection(
                          title: 'Upcoming',
                          elections: upcomingElections,
                          showPriority: false,
                        ),
                      );
                    }),
                    // Empty State
                    Obx(() {
                      if (_controller.isLoading.value) {
                        return const SliverFillRemaining(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: DashboardColors.accent,
                            ),
                          ),
                        );
                      }

                      if (_controller.error.value.isNotEmpty &&
                          _controller.allElections.isEmpty) {
                        final isUnauthorized =
                            _controller.error.value.toLowerCase().contains(
                              'unauthorized',
                            ) ||
                            _controller.error.value.toLowerCase().contains(
                              'unauthenticated',
                            );

                        return SliverFillRemaining(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isUnauthorized
                                        ? Icons.lock_outline
                                        : Icons.error_outline,
                                    size: 48,
                                    color: DashboardColors.textGray,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    isUnauthorized
                                        ? 'Session Expired'
                                        : 'Failed to Load Elections',
                                    style: const TextStyle(
                                      color: DashboardColors.textWhite,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    isUnauthorized
                                        ? 'Please log in again to continue'
                                        : _controller.error.value,
                                    style: TextStyle(
                                      color: DashboardColors.textGray,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  if (isUnauthorized)
                                    ElevatedButton(
                                      onPressed: () async {
                                        // Clear token and navigate to login
                                        try {
                                          if (Get.isRegistered<
                                            ProfileController
                                          >()) {
                                            await Get.find<ProfileController>()
                                                .logout();
                                          } else {
                                            // Fallback: clear token and navigate directly
                                            final authRepo = AuthRepository();
                                            authRepo.clearAuthToken();
                                            Get.offAll(() => const LoginPage());
                                          }
                                        } catch (e) {
                                          // Fallback: clear token and navigate directly
                                          final authRepo = AuthRepository();
                                          authRepo.clearAuthToken();
                                          Get.offAll(() => const LoginPage());
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: DashboardColors.accent,
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                      ),
                                      child: const Text('Go to Login'),
                                    )
                                  else
                                    ElevatedButton(
                                      onPressed: () => _controller.refresh(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: DashboardColors.accent,
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                      ),
                                      child: const Text('Retry'),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      if (_controller.filteredElections.isEmpty) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.how_to_vote_outlined,
                                  size: 48,
                                  color: DashboardColors.textGray,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No elections found',
                                  style: TextStyle(
                                    color: DashboardColors.textWhite,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return const SliverToBoxAdapter(
                        child: SizedBox(height: 24),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: DashboardColors.background,
        border: Border(
          bottom: BorderSide(
            color: DashboardColors.surface.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Elections title on the left
          const Text(
            'Elections',
            style: TextStyle(
              color: DashboardColors.textWhite,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // Filter button
          TextButton.icon(
            onPressed: _showFilterDialog,
            icon: const Icon(
              Icons.tune,
              color: DashboardColors.accent,
              size: 20,
            ),
            label: const Text(
              'Filter',
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

  void _showFilterDialog() {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _FilterBottomSheet(controller: _controller),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: DashboardColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(
            color: DashboardColors.textWhite,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: 'Search candidates, positions...',
            hintStyle: TextStyle(color: DashboardColors.textGray, fontSize: 14),
            prefixIcon: const Icon(
              Icons.search,
              color: DashboardColors.textGray,
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Obx(() {
      // Access observable directly to ensure GetX tracks it
      final selectedCategory = _controller.selectedCategory.value;
      final categories = _controller.categories;

      return SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedCategory == category;

            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _controller.setCategory(category);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? DashboardColors.accent
                        : DashboardColors.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.black
                          : DashboardColors.textGray,
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildSection({
    required String title,
    required List<Election> elections,
    required bool showPriority,
  }) {
    if (elections.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: DashboardColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (showPriority && title == 'Active Now') ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'PRIORITY',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...elections.map(
          (election) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildElectionCard(election, title == 'Upcoming'),
          ),
        ),
      ],
    );
  }

  Widget _buildElectionCard(Election election, bool isUpcoming) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DashboardColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Badge
                _buildStatusBadge(election, isUpcoming),
                const SizedBox(height: 12),
                // Title
                Text(
                  election.title,
                  style: const TextStyle(
                    color: DashboardColors.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Description
                Text(
                  election.description,
                  style: TextStyle(
                    color: DashboardColors.textGray,
                    fontSize: 14,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Turnout info (for active elections)
                if (!isUpcoming && !election.hasEnded)
                  _buildTurnoutInfo(election),
                // Time Info
                _buildTimeInfo(election, isUpcoming),
                const SizedBox(height: 16),
                // Action Button
                _buildActionButton(election, isUpcoming),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Image/Icon
          _buildElectionImage(election, isUpcoming),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(Election election, bool isUpcoming) {
    if (isUpcoming) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'STARTS ${election.formattedStartDate}',
          style: const TextStyle(
            color: Colors.blue,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      );
    }

    // Check if election has ended first
    if (election.hasEnded) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'CLOSED',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      );
    }

    if (election.hasVoted) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle,
            color: DashboardColors.accent,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            'VOTED',
            style: TextStyle(
              color: DashboardColors.accent,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      );
    }

    // Only show "VOTING OPEN" if election is actually active and not ended
    if (election.isActive && !election.hasEnded) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'VOTING OPEN',
            style: TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      );
    }

    // Fallback for any other status
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          election.currentStatus.toUpperCase(),
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeInfo(Election election, bool isUpcoming) {
    if (isUpcoming) {
      return Row(
        children: [
          const Icon(
            Icons.calendar_today,
            size: 14,
            color: DashboardColors.textGray,
          ),
          const SizedBox(width: 6),
          Text(
            'Starts: ${election.formattedStartDate}',
            style: TextStyle(color: DashboardColors.textGray, fontSize: 13),
          ),
        ],
      );
    }

    if (election.hasVoted) {
      return Row(
        children: [
          const Icon(
            Icons.calendar_today,
            size: 14,
            color: DashboardColors.textGray,
          ),
          const SizedBox(width: 6),
          Text(
            'Results: ${election.formattedEndDate}',
            style: TextStyle(color: DashboardColors.textGray, fontSize: 13),
          ),
        ],
      );
    }

    // Always show countdown timer for active elections
    if (!election.hasEnded) {
      return _buildCountdownTimer(election);
    }

    // If ended, show ended message
    return Row(
      children: [
        const Icon(Icons.access_time, size: 14, color: Colors.red),
        const SizedBox(width: 6),
        Text(
          'Ended',
          style: TextStyle(
            color: Colors.red,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCountdownTimer(Election election) {
    return _CountdownTimerWidget(election: election);
  }

  Widget _buildTurnoutInfo(Election election) {
    return FutureBuilder(
      future: _controller.getElectionTurnout(election.id),
      builder: (context, snapshot) {
        // Loading state - show nothing (compact)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        // Error state - show nothing (fail silently)
        if (snapshot.hasError || snapshot.data == null) {
          return const SizedBox.shrink();
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
                  'Participation',
                  style: TextStyle(
                    color: DashboardColors.textGray,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${participationRate.toStringAsFixed(1)}% / ${participationGoal.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: DashboardColors.textWhite,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: DashboardColors.surfaceLight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  DashboardColors.accent,
                ),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Widget _buildActionButton(Election election, bool isUpcoming) {
    // Check if election is closed/ended
    if (election.hasEnded) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: null, // Disabled
          icon: const Icon(Icons.lock_outline, size: 18),
          label: const Text(
            'Election Closed',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: DashboardColors.surfaceLight.withValues(
              alpha: 0.5,
            ),
            foregroundColor: DashboardColors.textGray,
            disabledBackgroundColor: DashboardColors.surfaceLight.withValues(
              alpha: 0.3,
            ),
            disabledForegroundColor: DashboardColors.textGray,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    if (isUpcoming) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            // TODO: Set reminder/notification
          },
          icon: const Icon(
            Icons.notifications_outlined,
            size: 18,
            color: DashboardColors.accent,
          ),
          label: const Text(
            'Set Reminder',
            style: TextStyle(
              color: DashboardColors.accent,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: DashboardColors.accent, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    if (election.hasVoted) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            // Navigate to voting page to view selection
            Get.to(() => VotingPage(electionId: election.id));
          },
          icon: const Icon(
            Icons.visibility,
            size: 18,
            color: DashboardColors.textWhite,
          ),
          label: const Text(
            'View Selection',
            style: TextStyle(
              color: DashboardColors.textWhite,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: DashboardColors.surfaceLight,
            foregroundColor: DashboardColors.textWhite,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // Navigate to voting page
          Get.to(() => VotingPage(electionId: election.id));
        },
        icon: const Icon(Icons.how_to_vote, size: 18, color: Colors.black),
        label: const Text(
          'Cast Vote',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: DashboardColors.accent,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildElectionImage(Election election, bool isUpcoming) {
    if (isUpcoming) {
      return GestureDetector(
        onTap: () {
          // TODO: Set reminder
        },
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: DashboardColors.accent.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.notifications_outlined,
            color: DashboardColors.accent,
            size: 24,
          ),
        ),
      );
    }

    // Placeholder image - can be replaced with actual election image if available
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: DashboardColors.backgroundDark,
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DashboardColors.accent.withValues(alpha: 0.3),
            DashboardColors.surfaceLight,
          ],
        ),
      ),
      child: Icon(
        Icons.how_to_vote,
        color: DashboardColors.accent.withValues(alpha: 0.7),
        size: 32,
      ),
    );
  }
}

/// Widget that displays a live countdown timer
class _CountdownTimerWidget extends StatefulWidget {
  final Election election;

  const _CountdownTimerWidget({required this.election});

  @override
  State<_CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<_CountdownTimerWidget> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final remaining = widget.election.endTimestamp - now;

    if (remaining <= 0) {
      return Row(
        children: [
          const Icon(Icons.access_time, size: 14, color: Colors.red),
          const SizedBox(width: 6),
          Text(
            'Ended',
            style: TextStyle(
              color: Colors.red,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    final hours = remaining ~/ 3600;
    final minutes = (remaining % 3600) ~/ 60;
    final seconds = remaining % 60;

    String timeStr;
    if (hours > 0) {
      timeStr = '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      timeStr = '${minutes}m ${seconds}s';
    } else {
      timeStr = '${seconds}s';
    }

    // Use orange/red when ending soon (less than 1 hour), gray otherwise
    final isUrgent = remaining < 3600; // Less than 1 hour
    final color = isUrgent ? Colors.orange : DashboardColors.textGray;
    final icon = isUrgent ? Icons.timer : Icons.access_time;

    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          'Ends in $timeStr',
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: isUrgent ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

/// Filter Bottom Sheet Widget
class _FilterBottomSheet extends StatelessWidget {
  final ElectionController controller;

  const _FilterBottomSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: DashboardColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: DashboardColors.textGray.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Elections',
                  style: TextStyle(
                    color: DashboardColors.textWhite,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Obx(
                  () => controller.hasActiveFilters
                      ? TextButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            controller.resetFilters();
                          },
                          child: const Text(
                            'Reset',
                            style: TextStyle(
                              color: DashboardColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          // Sort By Section
          _buildSection(
            title: 'Sort By',
            options: ElectionController.sortOptions,
            selectedValue: controller.sortBy,
            onSelect: controller.setSortBy,
          ),
          const SizedBox(height: 16),
          // Show Filter Section
          _buildSection(
            title: 'Show',
            options: ElectionController.showOptions,
            selectedValue: controller.showFilter,
            onSelect: controller.setShowFilter,
          ),
          const SizedBox(height: 16),
          // Status Filter Section
          _buildSection(
            title: 'Status',
            options: ElectionController.statusOptions,
            selectedValue: controller.statusFilter,
            onSelect: controller.setStatusFilter,
          ),
          const SizedBox(height: 24),
          // Apply Button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DashboardColors.accent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          // Safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Map<String, String> options,
    required RxString selectedValue,
    required Function(String) onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            title,
            style: TextStyle(
              color: DashboardColors.textGray,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: Obx(() {
            // Access the reactive value directly in Obx scope for proper tracking
            final currentValue = selectedValue.value;

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: options.length,
              itemBuilder: (context, index) {
                final key = options.keys.elementAt(index);
                final label = options[key]!;
                final isSelected = currentValue == key;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onSelect(key);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? DashboardColors.accent
                            : DashboardColors.surfaceLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? DashboardColors.accent
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.black
                              : DashboardColors.textWhite,
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
