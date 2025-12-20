import 'package:get/get.dart';
import '../../data/models/election.dart';
import '../../data/models/election_turnout.dart';
import '../../data/repositories/election_repository.dart';
import '../../../../core/network/api_exceptions.dart';

/// Election Controller
class ElectionController extends GetxController {
  final ElectionRepository _repository;

  ElectionController({ElectionRepository? repository})
    : _repository = repository ?? ElectionRepository();

  // State
  final RxList<Election> allElections = <Election>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Search and filters
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All Elections'.obs;

  // Advanced filters
  final RxString sortBy = 'newest'.obs; // newest, oldest, name_asc, name_desc
  final RxString showFilter = 'all'.obs; // all, not_voted, voted
  final RxString statusFilter = 'all'.obs; // all, active, upcoming, closed

  // Available categories
  final List<String> categories = ['All Elections', 'Active Now', 'Upcoming'];

  // Sort options
  static const Map<String, String> sortOptions = {
    'newest': 'Newest First',
    'oldest': 'Oldest First',
    'name_asc': 'Name (A-Z)',
    'name_desc': 'Name (Z-A)',
    'ending_soon': 'Ending Soon',
  };

  // Show filter options
  static const Map<String, String> showOptions = {
    'all': 'All Elections',
    'not_voted': 'Not Voted',
    'voted': 'Already Voted',
  };

  // Status filter options
  static const Map<String, String> statusOptions = {
    'all': 'All Statuses',
    'active': 'Active Only',
    'upcoming': 'Upcoming Only',
    'closed': 'Closed Only',
  };

  @override
  void onInit() {
    super.onInit();
    // Fetch immediately
    fetchElections();
  }

  /// Fetch elections
  Future<void> fetchElections() async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _repository.getElections();
      allElections.value = response.data;
    } on UnauthorizedException {
      error.value = 'Unauthenticated. Please login again.';
    } on ApiException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = 'Failed to load elections: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh elections (called on pull to refresh)
  @override
  Future<void> refresh() async {
    await fetchElections();
  }

  /// Set search query
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Set selected category
  void setCategory(String category) {
    selectedCategory.value = category;
  }

  /// Get filtered elections
  List<Election> get filteredElections {
    List<Election> elections = allElections.toList();

    // Filter by category (quick filter chips)
    if (selectedCategory.value == 'Active Now') {
      elections = elections.where((e) => e.isActive && !e.hasEnded).toList();
    } else if (selectedCategory.value == 'Upcoming') {
      elections = elections.where((e) => e.isUpcoming).toList();
    }

    // Apply status filter (from filter dialog)
    switch (statusFilter.value) {
      case 'active':
        elections = elections.where((e) => e.isActive && !e.hasEnded).toList();
        break;
      case 'upcoming':
        elections = elections.where((e) => e.isUpcoming).toList();
        break;
      case 'closed':
        elections = elections.where((e) => e.hasEnded).toList();
        break;
    }

    // Apply show filter (voted/not voted)
    switch (showFilter.value) {
      case 'not_voted':
        elections = elections.where((e) => !e.hasVoted && !e.hasEnded).toList();
        break;
      case 'voted':
        elections = elections.where((e) => e.hasVoted).toList();
        break;
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      elections = elections
          .where(
            (e) =>
                e.title.toLowerCase().contains(query) ||
                e.description.toLowerCase().contains(query),
          )
          .toList();
    }

    // Apply sorting
    switch (sortBy.value) {
      case 'newest':
        elections.sort((a, b) => b.startTimestamp.compareTo(a.startTimestamp));
        break;
      case 'oldest':
        elections.sort((a, b) => a.startTimestamp.compareTo(b.startTimestamp));
        break;
      case 'name_asc':
        elections.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
      case 'name_desc':
        elections.sort(
          (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()),
        );
        break;
      case 'ending_soon':
        elections.sort((a, b) => a.endTimestamp.compareTo(b.endTimestamp));
        break;
    }

    return elections;
  }

  /// Set sort option
  void setSortBy(String sort) {
    sortBy.value = sort;
  }

  /// Set show filter
  void setShowFilter(String filter) {
    showFilter.value = filter;
  }

  /// Set status filter
  void setStatusFilter(String status) {
    statusFilter.value = status;
  }

  /// Reset all filters
  void resetFilters() {
    sortBy.value = 'newest';
    showFilter.value = 'all';
    statusFilter.value = 'all';
    selectedCategory.value = 'All Elections';
    searchQuery.value = '';
  }

  /// Check if any filters are active
  bool get hasActiveFilters {
    return sortBy.value != 'newest' ||
        showFilter.value != 'all' ||
        statusFilter.value != 'all';
  }

  /// Get all elections (no filtering)
  List<Election> get allElectionsList {
    return allElections.toList();
  }

  /// Get active elections (must be active and not ended)
  List<Election> get activeElections {
    return filteredElections.where((e) => e.isActive && !e.hasEnded).toList();
  }

  /// Get upcoming elections
  List<Election> get upcomingElections {
    return filteredElections.where((e) => e.isUpcoming).toList();
  }

  // Turnout cache (electionId -> ElectionTurnout)
  final Map<int, ElectionTurnout> _turnoutCache = {};
  final Map<int, DateTime> _turnoutCacheTime = {};
  static const Duration _turnoutCacheDuration = Duration(seconds: 30);

  /// Get turnout for an election (with caching)
  Future<ElectionTurnout?> getElectionTurnout(int electionId) async {
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
      final turnout = await _repository.getElectionTurnout(
        electionId,
        includeBreakdown: false,
      );

      // Update cache
      _turnoutCache[electionId] = turnout;
      _turnoutCacheTime[electionId] = DateTime.now();

      return turnout;
    } catch (e) {
      Get.log('Error loading turnout for election $electionId: $e');
      return null;
    }
  }

  /// Clear turnout cache
  void clearTurnoutCache() {
    _turnoutCache.clear();
    _turnoutCacheTime.clear();
  }
}
