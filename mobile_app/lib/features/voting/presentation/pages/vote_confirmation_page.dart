import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../data/models/vote.dart';

/// Vote Confirmation Page
class VoteConfirmationPage extends StatelessWidget {
  final int electionId;
  final String electionTitle;
  final CastVoteData voteData;

  const VoteConfirmationPage({
    super.key,
    required this.electionId,
    required this.electionTitle,
    required this.voteData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardColors.background,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              const Text(
                'OFFICIAL VERIFICATION',
                style: TextStyle(
                  color: DashboardColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 40),
              // Main Content Card
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: DashboardColors.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Success Icon with Shield
                      _buildSuccessIcon(),
                      const SizedBox(height: 32),
                      // Main Message
                      const Text(
                        'Vote Secured!',
                        style: TextStyle(
                          color: DashboardColors.textWhite,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Subtitle
                      Text(
                        'Your ballot has been encrypted and recorded on the official university ledger.',
                        style: TextStyle(
                          color: DashboardColors.textGray,
                          fontSize: 14,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      // Transaction Receipt Card
                      _buildTransactionReceipt(),
                      const Spacer(),
                      // Action Buttons
                      _buildActionButtons(),
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

  Widget _buildSuccessIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer dashed circles
        CustomPaint(
          size: const Size(120, 120),
          painter: DashedCirclePainter(
            color: DashboardColors.accent.withValues(alpha: 0.3),
            strokeWidth: 2,
            dashWidth: 8,
            dashSpace: 4,
          ),
        ),
        // Middle dashed circle
        CustomPaint(
          size: const Size(100, 100),
          painter: DashedCirclePainter(
            color: DashboardColors.accent.withValues(alpha: 0.5),
            strokeWidth: 2,
            dashWidth: 6,
            dashSpace: 3,
          ),
        ),
        // Shield icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.blue.shade900,
            shape: BoxShape.circle,
            border: Border.all(color: DashboardColors.accent, width: 3),
          ),
          child: const Icon(
            Icons.verified,
            color: DashboardColors.accent,
            size: 40,
          ),
        ),
        // Small checkmark badge
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: DashboardColors.accent,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.black, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionReceipt() {
    // Parse voted_at timestamp
    final votedAt = DateTime.tryParse(voteData.votedAt) ?? DateTime.now();
    final dateStr = _formatDate(votedAt);
    final timeStr = _formatTime(votedAt);

    // Generate confirmation ID from vote_id
    final confirmationId = _generateConfirmationId(voteData.voteId);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DashboardColors.backgroundDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Election Info
          _buildReceiptRow(
            icon: Icons.how_to_vote,
            label: 'ELECTION',
            value: electionTitle,
          ),
          const SizedBox(height: 20),
          // Timestamp
          _buildReceiptRow(
            icon: Icons.access_time,
            label: 'TIMESTAMP',
            value: '$dateStr • $timeStr EST',
          ),
          const SizedBox(height: 20),
          // Confirmation ID
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lock, color: DashboardColors.accent, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'CONFIRMATION ID',
                    style: TextStyle(
                      color: DashboardColors.textGray,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade900,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'End-to-End Encrypted',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                confirmationId,
                style: TextStyle(
                  color: DashboardColors.accent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: DashboardColors.accent, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: DashboardColors.textGray,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: DashboardColors.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Return to Dashboard button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Navigate to dashboard
              Get.offAll(() => const DashboardPage());
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
              'Return to Dashboard',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // View Verified Ballot button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // Navigate back to voting page to view the ballot
              Get.back();
            },
            icon: const Icon(
              Icons.description,
              color: DashboardColors.accent,
              size: 20,
            ),
            label: const Text(
              'View Verified Ballot',
              style: TextStyle(
                color: DashboardColors.accent,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: DashboardColors.accent, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
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

  String _formatTime(DateTime date) {
    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    final second = date.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second $amPm';
  }

  String _generateConfirmationId(int voteId) {
    // Generate a confirmation ID based on vote_id
    // Format: XXXX-XX (e.g., 8X92-B2)
    final base = voteId.toString().padLeft(6, '0');
    final part1 = base.substring(0, 4);
    final part2 = base.substring(4, 6);
    return '$part1-$part2';
  }
}

/// Custom painter for dashed circles
class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final path = Path();
    final circumference = 2 * 3.14159 * radius;
    final dashCount = (circumference / (dashWidth + dashSpace)).floor();
    final angleStep = (2 * 3.14159) / dashCount;

    for (int i = 0; i < dashCount; i++) {
      final angle = i * angleStep;
      final startAngle = angle;
      final endAngle = angle + (dashWidth / radius);

      path.addArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        endAngle - startAngle,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
