import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/election_results.dart';
import '../../data/repositories/results_repository.dart';
import '../controllers/results_controller.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../elections/data/models/election_turnout.dart';
import '../../../elections/data/repositories/election_repository.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  late ResultsController controller;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  /// Get unique years from election data
  List<String> _getFilters(List<ArchiveElection> results) {
    final years = <String>{};
    for (final election in results) {
      if (election.endTime != null) {
        try {
          final date = DateTime.parse(election.endTime!);
          years.add(date.year.toString());
        } catch (_) {}
      }
    }
    final sortedYears = years.toList()
      ..sort((a, b) => b.compareTo(a)); // Descending
    return ['All', ...sortedYears];
  }

  /// Filter results based on selected year
  List<ArchiveElection> _getFilteredResults(List<ArchiveElection> results) {
    // Apply search filter
    var filtered = results;
    final query = _searchController.text.toLowerCase().trim();
    if (query.isNotEmpty) {
      filtered = filtered.where((e) {
        return e.title.toLowerCase().contains(query) ||
            (e.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Apply year filter
    if (_selectedFilter != 'All') {
      filtered = filtered.where((e) {
        if (e.endTime == null) return false;
        try {
          final date = DateTime.parse(e.endTime!);
          return date.year.toString() == _selectedFilter;
        } catch (_) {
          return false;
        }
      }).toList();
    }

    return filtered;
  }

  @override
  void initState() {
    super.initState();
    controller = Get.put(ResultsController());
    controller.fetchAllResults();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeader(),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSearchBar(),
            ),
            const SizedBox(height: 16),
            // Filter Chips
            Obx(() => _buildFilterChips(controller.allResults)),
            const SizedBox(height: 8),
            // Results List
            Expanded(
              child: Obx(() {
                if (controller.isLoadingAll.value) {
                  return _buildLoadingState();
                }
                if (controller.errorAll.value.isNotEmpty) {
                  return _buildErrorState();
                }
                final results = controller.allResults;
                if (results.isEmpty) {
                  return _buildEmptyState();
                }
                final filtered = _getFilteredResults(results);
                if (filtered.isEmpty) {
                  return _buildNoMatchState();
                }
                return _buildResultsList(filtered);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Trophy Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: DashboardColors.accentGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: DashboardColors.accent.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Colors.black,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Election Results',
                  style: TextStyle(
                    color: DashboardColors.textWhite,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Past election outcomes',
                  style: TextStyle(
                    color: DashboardColors.textGray,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: DashboardColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: DashboardColors.surfaceLight.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(color: DashboardColors.textWhite, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Search election history...',
          hintStyle: TextStyle(color: DashboardColors.textMuted, fontSize: 14),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: DashboardColors.textGray,
            size: 22,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  child: Icon(
                    Icons.close_rounded,
                    color: DashboardColors.textGray,
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(List<ArchiveElection> results) {
    final filters = _getFilters(results);
    // Reset filter if it's no longer valid
    if (!filters.contains(_selectedFilter)) {
      _selectedFilter = 'All';
    }
    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _selectedFilter = filter;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? DashboardColors.accent
                    : DashboardColors.surfaceElevated,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? DashboardColors.accent
                      : DashboardColors.surfaceLight.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.black : DashboardColors.textGray,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: DashboardColors.accent),
          const SizedBox(height: 16),
          Text(
            'Loading results...',
            style: TextStyle(color: DashboardColors.textGray, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: Colors.red.shade400,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load results',
                  style: TextStyle(
                    color: DashboardColors.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.errorAll.value.isNotEmpty
                      ? controller.errorAll.value
                      : 'Please try again later.',
                  style: TextStyle(
                    color: DashboardColors.textGray,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => controller.fetchAllResults(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DashboardColors.accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: DashboardColors.textGray,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Results Available',
              style: TextStyle(
                color: DashboardColors.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Results will appear here once elections are closed.',
              style: TextStyle(color: DashboardColors.textGray, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoMatchState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: DashboardColors.textGray,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Matches Found',
              style: TextStyle(
                color: DashboardColors.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filter.',
              style: TextStyle(color: DashboardColors.textGray, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _selectedFilter = 'All';
                });
              },
              child: Text(
                'Clear Filters',
                style: TextStyle(
                  color: DashboardColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(List<ArchiveElection> results) {
    return RefreshIndicator(
      onRefresh: () => controller.refresh(),
      color: DashboardColors.accent,
      backgroundColor: DashboardColors.surface,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        itemCount: results.length + 1, // +1 for footer
        itemBuilder: (context, index) {
          if (index == results.length) {
            return _buildFooter(results.length);
          }
          return _ResultCard(
            election: results[index],
            onTap: () => _navigateToDetails(results[index]),
          );
        },
      ),
    );
  }

  Widget _buildFooter(int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 32),
      child: Center(
        child: Text(
          'SHOWING LATEST $count ELECTIONS',
          style: TextStyle(
            color: DashboardColors.textGray,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  void _navigateToDetails(ArchiveElection election) {
    HapticFeedback.mediumImpact();
    Get.to(() => ElectionResultsDetailPage(electionId: election.id));
  }
}

class _ResultCard extends StatefulWidget {
  final ArchiveElection election;
  final VoidCallback onTap;

  const _ResultCard({required this.election, required this.onTap});

  @override
  State<_ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<_ResultCard> {
  final ElectionRepository _electionRepository = ElectionRepository();

  // Turnout cache
  final Map<int, ElectionTurnout> _turnoutCache = {};
  final Map<int, DateTime> _turnoutCacheTime = {};
  static const Duration _turnoutCacheDuration = Duration(hours: 1);

  /// Get turnout for an election (with caching for closed elections)
  Future<ElectionTurnout?> _getElectionTurnout(int electionId) async {
    // Check cache first
    final cached = _turnoutCache[electionId];
    final cacheTime = _turnoutCacheTime[electionId];

    if (cached != null && cacheTime != null) {
      final age = DateTime.now().difference(cacheTime);
      if (age < _turnoutCacheDuration) {
        return cached;
      }
    }

    // Fetch from API
    try {
      final turnout = await _electionRepository.getElectionTurnout(
        electionId,
        includeBreakdown: false,
      );

      // Update cache
      _turnoutCache[electionId] = turnout;
      _turnoutCacheTime[electionId] = DateTime.now();

      return turnout;
    } catch (e) {
      // Silently fail - will show fallback UI
      return null;
    }
  }

  /// Build stats row (fallback when turnout unavailable)
  Widget _buildStatsRow(ArchiveElection election) {
    return Row(
      children: [
        // Date Stat
        _buildStatChip(
          icon: Icons.event_rounded,
          label: election.formattedEndDate,
          color: DashboardColors.primary,
        ),
        const SizedBox(width: 10),
        // Votes Stat
        _buildStatChip(
          icon: Icons.how_to_vote_rounded,
          label: '${_formatNumber(election.totalVotes)} votes',
          color: DashboardColors.accent,
        ),
        const Spacer(),
        // Arrow Button
        GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: DashboardColors.accentGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: DashboardColors.accent.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.black,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getElectionIcon() {
    final title = widget.election.title.toLowerCase();
    if (title.contains('royal') ||
        title.contains('miss') ||
        title.contains('queen') ||
        title.contains('king')) {
      return Icons.emoji_events_rounded;
    }
    if (title.contains('freshman') ||
        title.contains('sophomore') ||
        title.contains('junior') ||
        title.contains('senior')) {
      return Icons.school_rounded;
    }
    return Icons.emoji_events_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final election = widget.election;
    final onTap = widget.onTap;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [DashboardColors.surfaceElevated, DashboardColors.surface],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: DashboardColors.accent.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Decorative accent circle
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        DashboardColors.accent.withValues(alpha: 0.15),
                        DashboardColors.accent.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row with Icon and Status
                    Row(
                      children: [
                        // Icon Container
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: DashboardColors.accentGradient,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: DashboardColors.accent.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            _getElectionIcon(),
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                        const Spacer(),
                        // Completed Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: DashboardColors.success.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: DashboardColors.success.withValues(
                                alpha: 0.3,
                              ),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: DashboardColors.success,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Completed',
                                style: TextStyle(
                                  color: DashboardColors.success,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Title
                    Text(
                      election.title,
                      style: const TextStyle(
                        color: DashboardColors.textWhite,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    if (election.description != null &&
                        election.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        election.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: DashboardColors.textGray,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    // Divider
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            DashboardColors.surfaceLight.withValues(alpha: 0),
                            DashboardColors.surfaceLight.withValues(alpha: 0.3),
                            DashboardColors.surfaceLight.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Turnout info (for closed elections)
                    FutureBuilder<ElectionTurnout?>(
                      future: _getElectionTurnout(election.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        }

                        final turnout = snapshot.data;
                        if (turnout == null) {
                          // Fallback to just showing votes if turnout unavailable
                          return _buildStatsRow(election);
                        }

                        final participationRate =
                            turnout.turnout.participationRate;
                        final participationGoal =
                            turnout.turnout.participationGoal;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Participation info
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatChip(
                                    icon: Icons.people_rounded,
                                    label:
                                        '${participationRate.toStringAsFixed(1)}% turnout',
                                    color: DashboardColors.accent,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildStatChip(
                                    icon: Icons.how_to_vote_rounded,
                                    label:
                                        '${_formatNumber(election.totalVotes)} votes',
                                    color: DashboardColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: participationGoal > 0
                                    ? (participationRate / participationGoal)
                                          .clamp(0.0, 1.0)
                                    : 0.0,
                                backgroundColor: DashboardColors.surfaceLight,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  DashboardColors.accent,
                                ),
                                minHeight: 4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Stats Row with Date and Arrow
                            Row(
                              children: [
                                _buildStatChip(
                                  icon: Icons.event_rounded,
                                  label: election.formattedEndDate,
                                  color: DashboardColors.primary,
                                ),
                                const Spacer(),
                                // Arrow Button
                                GestureDetector(
                                  onTap: onTap,
                                  child: Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      gradient: DashboardColors.accentGradient,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: DashboardColors.accent
                                              .withValues(alpha: 0.4),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Election Results Detail Page
class ElectionResultsDetailPage extends StatefulWidget {
  final int electionId;

  const ElectionResultsDetailPage({super.key, required this.electionId});

  @override
  State<ElectionResultsDetailPage> createState() =>
      _ElectionResultsDetailPageState();
}

class _ElectionResultsDetailPageState extends State<ElectionResultsDetailPage> {
  final ResultsRepository _repository = ResultsRepository();
  final ElectionRepository _electionRepository = ElectionRepository();
  ElectionResult? _result;
  ElectionTurnout? _turnout;
  bool _isLoading = true;
  bool _isLoadingTurnout = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchResults();
    _fetchTurnout();
  }

  Future<void> _fetchResults() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _repository.getElectionResults(widget.electionId);
      setState(() {
        _result = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchTurnout() async {
    setState(() {
      _isLoadingTurnout = true;
    });

    try {
      final turnout = await _electionRepository.getElectionTurnout(
        widget.electionId,
        includeBreakdown: true, // Get class year breakdown for demographics
      );
      setState(() {
        _turnout = turnout;
        _isLoadingTurnout = false;
      });
    } catch (e) {
      debugPrint('Error loading turnout: $e');
      setState(() {
        _isLoadingTurnout = false;
      });
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardColors.background,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: DashboardColors.accent),
            )
          : _error != null
          ? _buildErrorView()
          : _result != null
          ? _buildResultsView()
          : const SizedBox.shrink(),
    );
  }

  Widget _buildErrorView() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              const Text(
                'Failed to load results',
                style: TextStyle(
                  color: DashboardColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error ?? 'Please try again later.',
                style: TextStyle(color: DashboardColors.textGray, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _fetchResults,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DashboardColors.accent,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _selectedTabIndex = 0;

  Widget _buildResultsView() {
    final result = _result!;
    return CustomScrollView(
      slivers: [
        // Fixed App Bar (Back button and title)
        SliverAppBar(
          pinned: true,
          floating: false,
          backgroundColor: const Color(0xFF1E3A5F),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            'Election Results',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.share_rounded,
                color: Colors.white,
                size: 22,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
              },
            ),
          ],
        ),
        // Election Card (scrollable)
        SliverToBoxAdapter(child: _buildElectionCard(result)),
        // Stats Row
        SliverToBoxAdapter(child: _buildStatsRow(result)),
        // Tab Bar
        SliverToBoxAdapter(child: _buildTabBar()),
        // Tab Content based on selection
        if (_selectedTabIndex == 0) ...[
          // List View Tab Content
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildPositionCard(result.positions[index]),
                childCount: result.positions.length,
              ),
            ),
          ),
        ] else ...[
          // Analytics View Tab Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTurnoutCard(result),
                  const SizedBox(height: 16),
                  _buildTurnoutOverTimeCard(result),
                  const SizedBox(height: 16),
                  _buildDemographicCard(result),
                ],
              ),
            ),
          ),
        ],
        // Abstentions Section
        SliverToBoxAdapter(child: _buildAbstentionsSection(result)),
        // Spacer before footer
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
        // Certification Footer
        SliverToBoxAdapter(child: _buildCertificationFooter(result)),
        // Bottom padding
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildTurnoutCard(ElectionResult result) {
    // Use real turnout data if available, otherwise fallback to result data
    final turnout = _turnout;
    final voted = turnout?.turnout.totalVoted ?? result.totalVotes;
    final totalEligible =
        turnout?.turnout.totalEligibleVoters ?? (result.totalVotes * 2);
    final didNotVote = totalEligible - voted;
    final percentage = totalEligible > 0
        ? ((voted / totalEligible) * 100).round()
        : 0;
    final participationRate =
        turnout?.turnout.participationRate ?? percentage.toDouble();
    final goal = turnout?.turnout.participationGoal ?? 0.0;
    final progressToGoal = goal > 0
        ? (participationRate / goal).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DashboardColors.surfaceElevated,
            DashboardColors.surfaceElevated.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: DashboardColors.accent.withValues(alpha: 0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: DashboardColors.accent.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: RadialGradient(
                    center: Alignment.topRight,
                    radius: 1.5,
                    colors: [DashboardColors.accent, Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Turnout',
                      style: TextStyle(
                        color: DashboardColors.textWhite,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: DashboardColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: DashboardColors.accent,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: DashboardColors.accent.withValues(
                                    alpha: 0.6,
                                  ),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Live',
                            style: TextStyle(
                              color: DashboardColors.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),

                // Main stats row
                Row(
                  children: [
                    // Circular progress indicator
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background circle
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: CircularProgressIndicator(
                              value: 1.0,
                              strokeWidth: 12,
                              backgroundColor: DashboardColors.backgroundDark,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                DashboardColors.backgroundDark,
                              ),
                            ),
                          ),
                          // Progress circle
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: CircularProgressIndicator(
                              value: participationRate / 100,
                              strokeWidth: 12,
                              strokeCap: StrokeCap.round,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                DashboardColors.accent,
                              ),
                            ),
                          ),
                          // Center content
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                participationRate.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: DashboardColors.textWhite,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  height: 1.0,
                                ),
                              ),
                              Text(
                                '%',
                                style: TextStyle(
                                  color: DashboardColors.textMuted,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Stats column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCompactStat(
                            icon: Icons.how_to_vote_rounded,
                            value: _formatNumber(voted),
                            label: 'Voted',
                            color: DashboardColors.accent,
                          ),
                          const SizedBox(height: 20),
                          _buildCompactStat(
                            icon: Icons.people_outline_rounded,
                            value: _formatNumber(totalEligible),
                            label: 'Eligible Voters',
                            color: DashboardColors.primary,
                          ),
                          const SizedBox(height: 20),
                          _buildCompactStat(
                            icon: Icons.person_off_outlined,
                            value: _formatNumber(didNotVote),
                            label: 'Didn\'t Vote',
                            color: const Color(0xFF6B7280),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Goal progress section
                if (goal > 0) ...[
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: DashboardColors.backgroundDark.withValues(
                        alpha: 0.4,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: DashboardColors.accent.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.flag_rounded,
                                  color: DashboardColors.accent,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Participation Goal',
                                  style: TextStyle(
                                    color: DashboardColors.textGray,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${goal.toStringAsFixed(0)}%',
                              style: TextStyle(
                                color: DashboardColors.accent,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              Container(
                                height: 12,
                                decoration: BoxDecoration(
                                  color: DashboardColors.backgroundDark,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: progressToGoal.clamp(0.0, 1.0),
                                child: Container(
                                  height: 12,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        DashboardColors.accent,
                                        DashboardColors.accent.withValues(
                                          alpha: 0.8,
                                        ),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(progressToGoal * 100).toStringAsFixed(1)}% of goal achieved',
                          style: TextStyle(
                            color: DashboardColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: DashboardColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: DashboardColors.textGray,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTurnoutOverTimeCard(ElectionResult result) {
    // Use real turnout data if available, otherwise show placeholder

    // For now, use mock data for time series (this would need a separate API endpoint)
    // TODO: Implement API endpoint for turnout over time
    final spots = [
      const FlSpot(0, 20),
      const FlSpot(1, 35),
      const FlSpot(2, 45),
      const FlSpot(3, 55),
      const FlSpot(4, 65),
      const FlSpot(5, 80),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DashboardColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DashboardColors.surfaceLight.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Voter Turnout Over Time',
                style: TextStyle(
                  color: DashboardColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'HOURLY',
                style: TextStyle(
                  color: DashboardColors.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xFFEEEEEE),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index == 0 ||
                            index == 2 ||
                            index == 4 ||
                            index == 5) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              index == 0
                                  ? '8 AM'
                                  : index == 2
                                  ? '12 PM'
                                  : index == 4
                                  ? '4 PM'
                                  : '8 PM',
                              style: const TextStyle(
                                color: Color(0xFF999999),
                                fontSize: 11,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 5,
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: DashboardColors.accent,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: index == spots.length - 1 ? 5 : 0,
                          color: DashboardColors.accent,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          DashboardColors.accent.withValues(alpha: 0.3),
                          DashboardColors.accent.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemographicCard(ElectionResult result) {
    // Use real demographic data from turnout API if available
    final turnout = _turnout;
    final classYearBreakdown = turnout?.byClassYear ?? [];

    // Map class year breakdown to demographics format
    final demographics = classYearBreakdown.isNotEmpty
        ? classYearBreakdown.map((item) {
            // Determine color based on percentage
            Color color;
            if (item.percentage >= 70) {
              color = DashboardColors.accent;
            } else if (item.percentage >= 50) {
              color = const Color(0xFF3B5998);
            } else if (item.percentage >= 30) {
              color = const Color(0xFF8E8E93);
            } else {
              color = const Color(0xFF6B7A3D);
            }

            return {
              'label': item.label,
              'percentage': item.percentage.round(),
              'voted': item.voted,
              'total': item.total,
              'color': color,
            };
          }).toList()
        : [
            // Fallback mock data if no breakdown available
            {
              'label': 'Seniors',
              'percentage': 85,
              'voted': 0,
              'total': 0,
              'color': DashboardColors.accent,
            },
            {
              'label': 'Juniors',
              'percentage': 62,
              'voted': 0,
              'total': 0,
              'color': const Color(0xFF3B5998),
            },
            {
              'label': 'Sophomores',
              'percentage': 45,
              'voted': 0,
              'total': 0,
              'color': const Color(0xFF8E8E93),
            },
            {
              'label': 'Freshmen',
              'percentage': 38,
              'voted': 0,
              'total': 0,
              'color': const Color(0xFF3B5998),
            },
          ];

    // Sort by percentage descending
    demographics.sort(
      (a, b) => (b['percentage'] as int).compareTo(a['percentage'] as int),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DashboardColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DashboardColors.surfaceLight.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Demographic Breakdown',
            style: TextStyle(
              color: DashboardColors.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Filter chips
          Row(
            children: [
              _buildFilterChip('Class Year', isSelected: true),
              const SizedBox(width: 8),
              _buildFilterChip('Major', isSelected: false),
              const SizedBox(width: 8),
              _buildFilterChip('Residence', isSelected: false),
            ],
          ),
          const SizedBox(height: 20),
          // Demographics list
          if (_isLoadingTurnout)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: DashboardColors.accent),
              ),
            )
          else if (demographics.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No demographic data available',
                  style: TextStyle(
                    color: DashboardColors.textGray,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...demographics.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildDemographicRow(
                  label: item['label'] as String,
                  percentage: item['percentage'] as int,
                  color: item['color'] as Color,
                  voted: item['voted'] as int?,
                  total: item['total'] as int?,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? DashboardColors.accent : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? DashboardColors.accent
              : DashboardColors.surfaceLight.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.black : DashboardColors.textMuted,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDemographicRow({
    required String label,
    required int percentage,
    required Color color,
    int? voted,
    int? total,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: DashboardColors.textWhite,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    color: DashboardColors.textWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (voted != null && total != null)
                  Text(
                    '$voted / $total',
                    style: TextStyle(
                      color: DashboardColors.textGray,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: DashboardColors.backgroundDark,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: percentage / 100,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAbstentionsSection(ElectionResult result) {
    // Calculate total abstentions across all positions
    int totalAbstentions = 0;
    for (final position in result.positions) {
      totalAbstentions += position.abstentions;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: DashboardColors.surfaceLight.withValues(alpha: 0.5),
          strokeWidth: 1.5,
          dashWidth: 6,
          dashSpace: 4,
          borderRadius: 16,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DashboardColors.surfaceElevated,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Abstentions',
                      style: TextStyle(
                        color: DashboardColors.textWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Students who voted in the election\nbut skipped these positions.',
                      style: TextStyle(
                        color: DashboardColors.textMuted,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$totalAbstentions',
                    style: const TextStyle(
                      color: DashboardColors.textWhite,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'VOTES',
                    style: TextStyle(
                      color: DashboardColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCertificationFooter(ElectionResult result) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DashboardColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: DashboardColors.success.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.verified_rounded,
              color: DashboardColors.success,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: DashboardColors.textMuted,
                  fontSize: 12,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'Official results certified by the '),
                  TextSpan(
                    text: 'Student Election Commission',
                    style: TextStyle(
                      color: DashboardColors.textWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: ' on ${_formatDate(result.election.endTime)}.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
            },
            style: TextButton.styleFrom(
              foregroundColor: DashboardColors.accent,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text(
              'Details',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElectionCard(ElectionResult result) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1E3A5F),
            const Color(0xFF152A40),
            DashboardColors.background,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xFF2A4A6F), const Color(0xFF1A3A5F)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Certified Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: DashboardColors.success.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: DashboardColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Certified Final',
                            style: TextStyle(
                              color: DashboardColors.success,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Title
                    Text(
                      result.election.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Subtitle
                    Text(
                      'Fisk University Campus',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Right - Illustration placeholder
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.how_to_vote_rounded,
                  color: Colors.white.withValues(alpha: 0.4),
                  size: 40,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(ElectionResult result) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          // Date Row
          _buildInfoRow(
            icon: Icons.event_rounded,
            label: 'DATE',
            value: _formatDate(result.election.endTime),
            color: DashboardColors.accent,
          ),
          const SizedBox(height: 10),
          // Turnout Row
          _buildInfoRow(
            icon: Icons.people_rounded,
            label: 'TOTAL TURNOUT',
            value: '${_formatNumber(result.totalVotes)} Votes',
            suffix: _buildPercentageBadge('+12%'),
            color: DashboardColors.primary,
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    Widget? suffix,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DashboardColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: DashboardColors.surfaceLight.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: DashboardColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
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
          if (suffix != null) ...[const Spacer(), suffix],
        ],
      ),
    );
  }

  Widget _buildPercentageBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: DashboardColors.success.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: DashboardColors.success,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: DashboardColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedTabIndex = 0);
                  HapticFeedback.lightImpact();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _selectedTabIndex == 0
                        ? DashboardColors.accent
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'List View',
                      style: TextStyle(
                        color: _selectedTabIndex == 0
                            ? Colors.black
                            : DashboardColors.textGray,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedTabIndex = 1);
                  HapticFeedback.lightImpact();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _selectedTabIndex == 1
                        ? DashboardColors.accent
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Analytics View',
                      style: TextStyle(
                        color: _selectedTabIndex == 1
                            ? Colors.black
                            : DashboardColors.textGray,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionCard(PositionResult position) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: DashboardColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DashboardColors.surfaceLight.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Position Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                // Position indicator line
                Container(
                  width: 3,
                  height: 36,
                  decoration: BoxDecoration(
                    color: DashboardColors.accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    position.positionName,
                    style: const TextStyle(
                      color: DashboardColors.textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: DashboardColors.textMuted.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '100% Reporting',
                    style: TextStyle(
                      color: DashboardColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Candidates List
          ...position.candidates.asMap().entries.map((entry) {
            final index = entry.key;
            final candidate = entry.value;
            final isWinner = position.winners.any(
              (w) => w.candidateId == candidate.candidateId,
            );
            return _buildCandidateCard(
              candidate,
              isWinner,
              index + 1,
              position.totalVotes,
            );
          }),
          // View Detailed Breakdown Button
          // View Detailed Breakdown Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_outline_rounded,
                    color: DashboardColors.accent,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'VIEW DETAILED BREAKDOWN',
                    style: TextStyle(
                      color: DashboardColors.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: DashboardColors.accent,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateCard(
    CandidateResult candidate,
    bool isWinner,
    int rank,
    int totalVotes,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isWinner
                ? DashboardColors.accent.withValues(alpha: 0.06)
                : DashboardColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isWinner
                  ? DashboardColors.accent.withValues(alpha: 0.25)
                  : DashboardColors.surfaceLight.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Avatar with winner badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: isWinner
                          ? DashboardColors.accentGradient
                          : null,
                      color: isWinner ? null : DashboardColors.surfaceLight,
                      shape: BoxShape.circle,
                      border: isWinner
                          ? Border.all(color: DashboardColors.accent, width: 2)
                          : null,
                    ),
                    child: ClipOval(
                      child: candidate.candidatePhoto != null
                          ? Image.network(
                              candidate.candidatePhoto!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _buildAvatarFallback(
                                candidate.candidateName,
                                isWinner,
                              ),
                            )
                          : _buildAvatarFallback(
                              candidate.candidateName,
                              isWinner,
                            ),
                    ),
                  ),
                  // Winner trophy badge
                  if (isWinner)
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: DashboardColors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: DashboardColors.surfaceElevated,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.emoji_events_rounded,
                          color: Colors.black,
                          size: 10,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.candidateName,
                      style: TextStyle(
                        color: DashboardColors.textWhite,
                        fontSize: 14,
                        fontWeight: isWinner
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                    if (candidate.candidateTagline != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        candidate.candidateTagline!,
                        style: TextStyle(
                          color: DashboardColors.textMuted,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    // Progress Bar
                    Stack(
                      children: [
                        Container(
                          height: 5,
                          decoration: BoxDecoration(
                            color: DashboardColors.backgroundDark,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: candidate.percentage / 100,
                          child: Container(
                            height: 5,
                            decoration: BoxDecoration(
                              gradient: isWinner
                                  ? DashboardColors.accentGradient
                                  : LinearGradient(
                                      colors: [
                                        DashboardColors.primary,
                                        DashboardColors.primary.withValues(
                                          alpha: 0.7,
                                        ),
                                      ],
                                    ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${candidate.votes} Votes',
                      style: TextStyle(
                        color: DashboardColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Percentage
              Text(
                '${candidate.percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: isWinner
                      ? DashboardColors.accent
                      : DashboardColors.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // WINNER Diagonal Banner
        if (isWinner)
          Positioned(
            top: 5,
            right: 16,
            child: SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                children: [
                  // Diagonal ribbon
                  Positioned(
                    top: 12,
                    right: -20,
                    child: Transform.rotate(
                      angle: 0.785398, // 45 degrees
                      child: Container(
                        width: 100,
                        height: 22,
                        decoration: BoxDecoration(
                          gradient: DashboardColors.accentGradient,
                          boxShadow: [
                            BoxShadow(
                              color: DashboardColors.accent.withValues(
                                alpha: 0.4,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'WINNER',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatarFallback(String name, bool isWinner) {
    final initials = name
        .split(' ')
        .take(2)
        .map((n) => n.isNotEmpty ? n[0] : '')
        .join('')
        .toUpperCase();
    return Container(
      color: isWinner ? Colors.transparent : DashboardColors.surfaceLight,
      child: Center(
        child: Text(
          initials.isNotEmpty ? initials : 'C',
          style: TextStyle(
            color: isWinner ? Colors.black : DashboardColors.textWhite,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(borderRadius),
        ),
      );

    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
