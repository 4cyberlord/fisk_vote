import 'package:get/get.dart';
import '../../data/models/blog_post.dart';
import '../../data/repositories/blog_repository.dart';
import '../../../../core/network/api_exceptions.dart';

/// Blog Detail Controller
class BlogDetailController extends GetxController {
  final BlogRepository _repository;
  final String postId;

  BlogDetailController({required this.postId, BlogRepository? repository})
    : _repository = repository ?? BlogRepository();

  // State
  final Rx<BlogPost?> post = Rx<BlogPost?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxBool isBookmarked = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPost();
  }

  /// Fetch blog post details
  Future<void> fetchPost() async {
    try {
      isLoading.value = true;
      error.value = '';

      final postData = await _repository.getPost(postId);
      post.value = postData;
    } on ApiException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = 'Failed to load post: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle bookmark
  void toggleBookmark() {
    isBookmarked.value = !isBookmarked.value;
    // TODO: Implement API call to save/remove bookmark
  }

  /// Share post
  void sharePost() {
    // TODO: Implement share functionality
  }
}
