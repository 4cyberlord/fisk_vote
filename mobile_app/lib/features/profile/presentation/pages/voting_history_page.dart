import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../controllers/voting_history_controller.dart';

/// Voting History Page - Shows all elections the user has voted in
class VotingHistoryPage extends StatelessWidget {
  const VotingHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VotingHistoryController());

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
          'Voting History',
          style: TextStyle(
            color: DashboardColors.textWhite,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: DashboardColors.accent),
          );
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: DashboardColors.textGray,
                ),
                const SizedBox(height: 16),
                Text(
                  controller.error.value,
                  style: const TextStyle(
                    color: DashboardColors.textWhite,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.loadHistory(),
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

        final votes = controller.votes;

        return RefreshIndicator(
          onRefresh: controller.loadHistory,
          color: DashboardColors.accent,
          child: votes.isEmpty
              ? _buildEmptyState()
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Summary Card
                    _buildSummaryCard(controller),
                    const SizedBox(height: 20),
                    // Votes List
                    ...votes.map((vote) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildVoteCard(vote),
                        )),
                  ],
                ),
        );
      }),
    );
  }

  Widget _buildSummaryCard(VotingHistoryController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DashboardColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            '${controller.votes.length}',
            'Total Votes',
            DashboardColors.accent,
          ),
          _buildSummaryItem(
            '${controller.getUniqueElectionsCount()}',
            'Elections',
            DashboardColors.textWhite,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: DashboardColors.textGray,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildVoteCard(Map<String, dynamic> vote) {
    final election = vote['election'] as Map<String, dynamic>?;
    final votedAt = vote['voted_at'] as String?;
    final electionTitle = election?['title'] as String? ?? 'Unknown Election';
    final electionStatus = election?['current_status'] as String? ?? 'Closed';
    final electionType = election?['type'] as String? ?? 'single';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DashboardColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  electionTitle,
                  style: const TextStyle(
                    color: DashboardColors.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(electionStatus).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  electionStatus.toUpperCase(),
                  style: TextStyle(
                    color: _getStatusColor(electionStatus),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (votedAt != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: DashboardColors.textGray,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatDate(votedAt),
                  style: TextStyle(
                    color: DashboardColors.textGray,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.how_to_vote,
                  size: 14,
                  color: DashboardColors.textGray,
                ),
                const SizedBox(width: 6),
                Text(
                  _getElectionTypeLabel(electionType),
                  style: TextStyle(
                    color: DashboardColors.textGray,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.how_to_vote_outlined,
            size: 64,
            color: DashboardColors.textGray,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Voting History',
            style: TextStyle(
              color: DashboardColors.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your voting history will appear here',
            style: TextStyle(
              color: DashboardColors.textGray,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.green;
      case 'closed':
        return DashboardColors.textGray;
      case 'upcoming':
        return DashboardColors.accent;
      default:
        return DashboardColors.textGray;
    }
  }

  String _getElectionTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'single':
        return 'Single Choice';
      case 'multiple':
        return 'Multiple Choice';
      case 'ranked':
        return 'Ranked Choice';
      default:
        return type;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        final months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        return '${months[date.month - 1]} ${date.day}, ${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }
}

