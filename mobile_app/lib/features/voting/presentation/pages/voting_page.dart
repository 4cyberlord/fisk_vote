import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/vote_controller.dart';
import '../../data/models/ballot.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../../core/widgets/modern_card.dart';
import '../../../../core/widgets/modern_button.dart';
import '../../../../core/config/app_config.dart';
import 'vote_confirmation_page.dart';

/// Voting Page - Official Ballot
class VotingPage extends StatelessWidget {
  final int electionId;

  const VotingPage({super.key, required this.electionId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VoteController());

    // Fetch ballot on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchBallot(electionId);
    });

    return Scaffold(
      backgroundColor: DashboardColors.background,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: DashboardColors.accent),
            );
          }

          if (controller.error.value.isNotEmpty &&
              controller.ballotData.value == null) {
            return _buildErrorView(controller);
          }

          final ballotData = controller.ballotData.value;
          if (ballotData == null) {
            return _buildEmptyView();
          }

          // Check if user has already voted
          if (ballotData.hasVoted) {
            return _buildAlreadyVotedView(ballotData);
          }

          // Check if election is open
          if (ballotData.election.currentStatus != 'Open') {
            return _buildElectionNotOpenView(ballotData);
          }

          return _buildVotingView(controller, ballotData);
        }),
      ),
    );
  }

  Widget _buildErrorView(VoteController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: DashboardColors.textGray,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Ballot',
              style: const TextStyle(
                color: DashboardColors.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.error.value,
              style: const TextStyle(
                color: DashboardColors.textGray,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => controller.fetchBallot(electionId),
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
    );
  }

  Widget _buildEmptyView() {
    return const Center(
      child: Text(
        'No ballot data available.',
        style: TextStyle(color: DashboardColors.textGray, fontSize: 16),
      ),
    );
  }

  Widget _buildAlreadyVotedView(BallotData ballotData) {
    return CustomScrollView(
      slivers: [
        _buildAppBar('Official Ballot'),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Already voted notice
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.blue,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You have already voted in this election.',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Election info
                _buildElectionHeader(ballotData.election),
                const SizedBox(height: 24),
                // Positions (read-only)
                ...ballotData.positions.map(
                  (position) =>
                      _buildPositionCard(position: position, isReadOnly: true),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildElectionNotOpenView(BallotData ballotData) {
    return CustomScrollView(
      slivers: [
        _buildAppBar('Official Ballot'),
        SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 48,
                    color: DashboardColors.textGray,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Election Not Open',
                    style: const TextStyle(
                      color: DashboardColors.textWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This election is not currently open for voting.\nStatus: ${ballotData.election.currentStatus}',
                    style: const TextStyle(
                      color: DashboardColors.textGray,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVotingView(VoteController controller, BallotData ballotData) {
    return CustomScrollView(
      slivers: [
        _buildAppBar('Official Ballot'),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Election header
                _buildElectionHeader(ballotData.election),
                const SizedBox(height: 24),
                // Disclaimer
                _buildDisclaimer(),
                const SizedBox(height: 24),
                // Positions
                ...ballotData.positions.map(
                  (position) => _buildPositionCard(
                    position: position,
                    controller: controller,
                    isReadOnly: false,
                  ),
                ),
                const SizedBox(height: 24),
                // Submit button
                _buildSubmitButton(controller, ballotData.election.id),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(String title) {
    return SliverAppBar(
      backgroundColor: DashboardColors.background,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: DashboardColors.textWhite),
        onPressed: () {
          HapticFeedback.lightImpact();
          Get.back();
        },
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: DashboardColors.textWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(
            Icons.info_outline_rounded,
            color: DashboardColors.textGray,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            // TODO: Show info dialog
          },
        ),
      ],
      pinned: true,
      elevation: 0,
    );
  }

  Widget _buildElectionHeader(BallotElection election) {
    return ModernCard(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(20),
      gradientColors: [DashboardColors.primary, DashboardColors.primaryLight],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  DashboardColors.success.withValues(alpha: 0.2),
                  DashboardColors.success.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: DashboardColors.success.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: DashboardColors.success,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: DashboardColors.success.withValues(alpha: 0.6),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'VOTING OPEN',
                  style: TextStyle(
                    color: DashboardColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            election.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          if (election.description != null) ...[
            const SizedBox(height: 10),
            Text(
              election.description!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return ModernCard(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DashboardColors.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: DashboardColors.warning,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Please review all candidates carefully. Your voice shapes our future. Once submitted, votes are final.',
              style: const TextStyle(
                color: DashboardColors.textWhite,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionCard({
    required BallotPosition position,
    VoteController? controller,
    required bool isReadOnly,
  }) {
    if (isReadOnly) {
      return ModernCard(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Position header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    position.name,
                    style: const TextStyle(
                      color: DashboardColors.textWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (position.description != null) ...[
              const SizedBox(height: 8),
              Text(
                position.description!,
                style: const TextStyle(
                  color: DashboardColors.textGray,
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: 16),
            // Candidates (read-only)
            if (position.type == 'single')
              _buildSingleChoiceCandidates(position, controller, isReadOnly)
            else if (position.type == 'multiple')
              _buildMultipleChoiceCandidates(position, controller, isReadOnly)
            else
              _buildRankedChoiceCandidates(position, controller, isReadOnly),
          ],
        ),
      );
    }

    // For editable positions, wrap in Obx to react to abstain changes
    return Obx(() {
      final isAbstained =
          controller != null && controller.isAbstained(position.id);

      return Opacity(
        opacity: isAbstained ? 0.5 : 1.0,
        child: ModernCard(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          borderRadius: BorderRadius.circular(18),
          gradientColors: isAbstained
              ? null
              : [DashboardColors.surface, DashboardColors.surfaceLight],
          borderColor: isAbstained
              ? DashboardColors.textMuted.withValues(alpha: 0.3)
              : null,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Position header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          position.name,
                          style: TextStyle(
                            color: isAbstained
                                ? DashboardColors.textMuted
                                : DashboardColors.textWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!isAbstained)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: DashboardColors.surfaceLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            position.type == 'single'
                                ? 'Select 1'
                                : position.type == 'multiple'
                                ? 'Select up to ${position.maxSelection ?? 2}'
                                : 'Rank up to ${position.rankingLevels ?? position.candidates.length}',
                            style: const TextStyle(
                              color: DashboardColors.textGray,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: DashboardColors.textMuted.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'ABSTAINED',
                            style: TextStyle(
                              color: DashboardColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (position.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      position.description!,
                      style: TextStyle(
                        color: isAbstained
                            ? DashboardColors.textMuted
                            : DashboardColors.textGray,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Candidates
                  if (position.type == 'single')
                    _buildSingleChoiceCandidates(
                      position,
                      controller,
                      isReadOnly,
                    )
                  else if (position.type == 'multiple')
                    _buildMultipleChoiceCandidates(
                      position,
                      controller,
                      isReadOnly,
                    )
                  else
                    _buildRankedChoiceCandidates(
                      position,
                      controller,
                      isReadOnly,
                    ),
                  // Abstain option
                  if (position.allowAbstain) ...[
                    const SizedBox(height: 16),
                    _buildAbstainOption(position, controller!),
                  ],
                ],
              ),
              // Overlay to prevent interaction when abstained
              if (isAbstained)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        color: DashboardColors.backgroundDark.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSingleChoiceCandidates(
    BallotPosition position,
    VoteController? controller,
    bool isReadOnly,
  ) {
    return Obx(() {
      final selectedId = controller != null
          ? (controller.getVote(position.id) as int?)
          : null;
      final isAbstained =
          controller != null && controller.isAbstained(position.id);

      return Column(
        children: position.candidates.map((candidate) {
          final isSelected = selectedId == candidate.id;
          return _buildCandidateCard(
            candidate: candidate,
            isSelected: isSelected,
            isReadOnly: isReadOnly,
            isAbstained: isAbstained,
            onTap: isReadOnly || isAbstained
                ? null
                : () => controller!.setVote(position.id, candidate.id),
            selectionType: SelectionType.radio,
          );
        }).toList(),
      );
    });
  }

  Widget _buildMultipleChoiceCandidates(
    BallotPosition position,
    VoteController? controller,
    bool isReadOnly,
  ) {
    return Obx(() {
      final selectedIds = controller != null
          ? (controller.getVote(position.id) as List<int>? ?? [])
          : <int>[];
      final isAbstained =
          controller != null && controller.isAbstained(position.id);

      return Column(
        children: position.candidates.map((candidate) {
          final isSelected = selectedIds.contains(candidate.id);
          return _buildCandidateCard(
            candidate: candidate,
            isSelected: isSelected,
            isReadOnly: isReadOnly,
            isAbstained: isAbstained,
            onTap: isReadOnly || isAbstained
                ? null
                : () {
                    final currentIds = List<int>.from(selectedIds);
                    if (isSelected) {
                      currentIds.remove(candidate.id);
                    } else {
                      if (position.maxSelection == null ||
                          currentIds.length < position.maxSelection!) {
                        currentIds.add(candidate.id);
                      }
                    }
                    controller!.setVote(position.id, currentIds);
                  },
            selectionType: SelectionType.checkbox,
          );
        }).toList(),
      );
    });
  }

  Widget _buildRankedChoiceCandidates(
    BallotPosition position,
    VoteController? controller,
    bool isReadOnly,
  ) {
    // Simplified ranked choice - can be enhanced later
    return const Text(
      'Ranked choice voting UI coming soon',
      style: TextStyle(color: DashboardColors.textGray, fontSize: 14),
    );
  }

  Widget _buildCandidateCard({
    required BallotCandidate candidate,
    required bool isSelected,
    required bool isReadOnly,
    required bool isAbstained,
    required VoidCallback? onTap,
    required SelectionType selectionType,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? DashboardColors.accent.withValues(alpha: 0.2)
              : DashboardColors.backgroundDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? DashboardColors.accent
                : DashboardColors.surfaceLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: DashboardColors.accent.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child:
                  candidate.user?.profilePhoto != null ||
                      candidate.photoUrl != null
                  ? ClipOval(
                      child: Image.network(
                        _getProfilePhotoUrl(
                        candidate.photoUrl ?? candidate.user!.profilePhoto!,
                        ),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            _buildAvatarFallback(candidate),
                      ),
                    )
                  : _buildAvatarFallback(candidate),
            ),
            const SizedBox(width: 12),
            // Candidate info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    candidate.displayName,
                    style: TextStyle(
                      color: DashboardColors.textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (candidate.tagline != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      candidate.tagline!,
                      style: const TextStyle(
                        color: DashboardColors.textGray,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Selection indicator
            if (!isReadOnly)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: selectionType == SelectionType.radio
                      ? BoxShape.circle
                      : BoxShape.rectangle,
                  borderRadius: selectionType == SelectionType.checkbox
                      ? BorderRadius.circular(4)
                      : null,
                  color: isSelected
                      ? DashboardColors.accent
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? DashboardColors.accent
                        : DashboardColors.textGray,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.black, size: 16)
                    : null,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(BallotCandidate candidate) {
    final initials = candidate.user?.firstName?.substring(0, 1) ?? 'C';
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          color: DashboardColors.accent,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAbstainOption(
    BallotPosition position,
    VoteController controller,
  ) {
    return Obx(() {
      final isAbstained = controller.isAbstained(position.id);
      return GestureDetector(
        onTap: () => controller.setAbstain(position.id, !isAbstained),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isAbstained
                ? DashboardColors.surfaceLight
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: DashboardColors.surfaceLight, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isAbstained
                      ? DashboardColors.textGray
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: DashboardColors.textGray, width: 2),
                ),
                child: isAbstained
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : null,
              ),
              const SizedBox(width: 12),
              const Text(
                'Abstain from voting for this position',
                style: TextStyle(color: DashboardColors.textGray, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSubmitButton(VoteController controller, int electionId) {
    return Obx(() {
      final error = controller.error.value;
      return Column(
        children: [
          if (error.isNotEmpty && !controller.isSubmitting.value)
            ModernCard(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              borderRadius: BorderRadius.circular(12),
              gradientColors: [
                DashboardColors.error.withValues(alpha: 0.2),
                DashboardColors.error.withValues(alpha: 0.15),
              ],
              borderColor: DashboardColors.error.withValues(alpha: 0.3),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: DashboardColors.error,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      error,
                      style: TextStyle(
                        color: DashboardColors.error,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ModernButton(
            label: 'Submit Vote',
            icon: Icons.how_to_vote_rounded,
            isLoading: controller.isSubmitting.value,
            onPressed: controller.isSubmitting.value
                ? null
                : () async {
                    HapticFeedback.mediumImpact();
                    final success = await controller.submitVote(electionId);
                    if (success) {
                      // Navigate to confirmation page
                      final voteData = controller.lastVoteData;
                      final ballotData = controller.ballotData.value;
                      if (voteData != null && ballotData != null) {
                        Get.off(
                          () => VoteConfirmationPage(
                            electionId: electionId,
                            electionTitle: ballotData.election.title,
                            voteData: voteData,
                          ),
                        );
                      } else {
                        // Fallback: refresh ballot
                        await controller.fetchBallot(electionId);
                      }
                    }
                  },
          ),
        ],
      );
    });
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

enum SelectionType { radio, checkbox }
