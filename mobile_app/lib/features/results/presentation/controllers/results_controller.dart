import 'package:get/get.dart';
import '../../data/models/election_results.dart';
import '../../data/repositories/results_repository.dart';
import '../../../../core/network/api_exceptions.dart';

/// Results Controller
class ResultsController extends GetxController {
  final ResultsRepository _repository;

  ResultsController({ResultsRepository? repository})
    : _repository = repository ?? ResultsRepository();

  // State for all results (archive)
  final RxList<ArchiveElection> allResults = <ArchiveElection>[].obs;
  final RxBool isLoadingAll = false.obs;
  final RxString errorAll = ''.obs;

  // State for featured/specific election result
  final Rx<ElectionResult?> featuredResult = Rx<ElectionResult?>(null);
  final RxBool isLoadingFeatured = false.obs;
  final RxString errorFeatured = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Fetch all results immediately
    fetchAllResults();
  }

  /// Fetch all closed elections with results
  Future<void> fetchAllResults() async {
    try {
      isLoadingAll.value = true;
      errorAll.value = '';

      final response = await _repository.getAllResults();
      allResults.value = response.data;

      // If we have results, automatically fetch the first one as featured
      if (response.data.isNotEmpty) {
        await fetchFeaturedResult(response.data.first.id);
      }
    } on UnauthorizedException {
      errorAll.value = 'Unauthenticated. Please login again.';
    } on ApiException catch (e) {
      errorAll.value = e.message;
    } catch (e) {
      errorAll.value = 'Failed to load results: ${e.toString()}';
    } finally {
      isLoadingAll.value = false;
    }
  }

  /// Fetch results for a specific election (featured result)
  Future<void> fetchFeaturedResult(int electionId) async {
    try {
      isLoadingFeatured.value = true;
      errorFeatured.value = '';

      final response = await _repository.getElectionResults(electionId);
      featuredResult.value = response.data;
    } on UnauthorizedException {
      errorFeatured.value = 'Unauthenticated. Please login again.';
    } on ApiException catch (e) {
      errorFeatured.value = e.message;
    } catch (e) {
      errorFeatured.value = 'Failed to load election results: ${e.toString()}';
    } finally {
      isLoadingFeatured.value = false;
    }
  }

  /// Refresh all results
  @override
  Future<void> refresh() async {
    await fetchAllResults();
  }

  /// Get archive results (excluding the featured one)
  List<ArchiveElection> get archiveResults {
    if (featuredResult.value == null) return allResults.toList();
    return allResults
        .where((e) => e.id != featuredResult.value!.election.id)
        .toList();
  }
}
