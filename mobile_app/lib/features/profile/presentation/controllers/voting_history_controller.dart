import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../data/repositories/profile_repository.dart';
import '../../../../core/network/api_exceptions.dart';

/// Voting History Controller
class VotingHistoryController extends GetxController {
  final ProfileRepository _repository = ProfileRepository();

  final RxList<Map<String, dynamic>> votes = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  /// Load voting history from API
  Future<void> loadHistory() async {
    try {
      isLoading.value = true;
      error.value = '';

      final history = await _repository.getVotingHistory();
      votes.value = history;

      debugPrint('✅ Voting history loaded: ${history.length} votes');
    } on ApiException catch (e) {
      error.value = e.message;
      debugPrint('❌ Voting history API error: ${e.message}');
    } catch (e) {
      error.value = 'Failed to load voting history: ${e.toString()}';
      debugPrint('❌ Voting history error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get count of unique elections voted in
  int getUniqueElectionsCount() {
    final electionIds = votes
        .map((vote) => vote['election']?['id'] as int?)
        .whereType<int>()
        .toSet();
    return electionIds.length;
  }

  /// Refresh voting history
  @override
  Future<void> refresh() async {
    await loadHistory();
  }
}

