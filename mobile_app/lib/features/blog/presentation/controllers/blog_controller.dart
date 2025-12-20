import 'package:get/get.dart';
import '../../data/models/blog_post.dart';
import '../../data/models/blog_category.dart';
import '../../data/repositories/blog_repository.dart';
import '../../../../core/network/api_exceptions.dart';

/// Blog Controller
class BlogController extends GetxController {
  final BlogRepository _repository;

  BlogController({BlogRepository? repository})
    : _repository = repository ?? BlogRepository();

  // State
  final RxList<BlogPost> posts = <BlogPost>[].obs;
  final RxList<BlogPost> featuredPosts = <BlogPost>[].obs;
  final RxList<BlogPost> popularPosts = <BlogPost>[].obs;
  final RxList<BlogPost> recentPosts = <BlogPost>[].obs;
  final RxList<BlogCategory> categoriesList = <BlogCategory>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Search and filters
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxBool hasMore = true.obs;
  final RxBool isLoadingMore = false.obs;

  // Available categories (will be populated from posts and API)
  final RxList<String> categories = <String>['All'].obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  /// Load all initial data
  Future<void> loadInitialData() async {
    await Future.wait([
      fetchCategories(),
      fetchFeatured(),
      fetchPopular(),
      fetchPosts(),
    ]);
  }

  /// Fetch blog posts
  Future<void> fetchPosts({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }
      error.value = '';

      final categoryFilter = selectedCategory.value == 'All'
          ? null
          : selectedCategory.value;
      final searchFilter = searchQuery.value.isEmpty ? null : searchQuery.value;

      final response = await _repository.getPosts(
        category: categoryFilter,
        search: searchFilter,
        page: currentPage.value,
        perPage: 10,
      );

      if (refresh || currentPage.value == 1) {
        posts.value = response.data;
      } else {
        posts.addAll(response.data);
      }

      // Update featured posts
      featuredPosts.value = response.data
          .where((post) => post.featured)
          .toList();

      // Update categories from posts
      _updateCategories(response.data);

      // Update pagination
      currentPage.value = response.meta.currentPage;
      totalPages.value = response.meta.lastPage;
      hasMore.value = response.meta.currentPage < response.meta.lastPage;

      if (refresh) {
        isLoading.value = false;
      } else {
        isLoadingMore.value = false;
      }
    } on ApiException catch (e) {
      error.value = e.message;
      if (refresh) {
        isLoading.value = false;
      } else {
        isLoadingMore.value = false;
      }
    } catch (e) {
      error.value = 'Failed to load blog posts: ${e.toString()}';
      if (refresh) {
        isLoading.value = false;
      } else {
        isLoadingMore.value = false;
      }
    }
  }

  /// Fetch categories from API
  Future<void> fetchCategories() async {
    try {
      final categoriesData = await _repository.getCategories();
      categoriesList.value = categoriesData;
      
      // Update string categories list
      final categoryNames = categoriesData.map((c) => c.name).toList()..sort();
      categories.value = ['All', ...categoryNames];
    } catch (e) {
      // If categories API fails, fall back to extracting from posts
      _updateCategoriesFromPosts();
    }
  }

  /// Fetch featured posts
  Future<void> fetchFeatured() async {
    try {
      final response = await _repository.getFeatured(limit: 3);
      featuredPosts.value = response.data;
    } catch (e) {
      // Silently fail - featured posts are optional
    }
  }

  /// Fetch popular posts
  Future<void> fetchPopular() async {
    try {
      final response = await _repository.getPopular(limit: 5);
      popularPosts.value = response.data;
    } catch (e) {
      // Silently fail - popular posts are optional
    }
  }

  /// Update categories list from posts (fallback)
  void _updateCategoriesFromPosts() {
    final categoryNames =
        posts.map((post) => post.category.name).toSet().toList()..sort();
    categories.value = ['All', ...categoryNames];
  }

  /// Update categories list from posts
  void _updateCategories(List<BlogPost> posts) {
    final categoryNames =
        posts.map((post) => post.category.name).toSet().toList()..sort();
    if (categories.length == 1 && categories.first == 'All') {
    categories.value = ['All', ...categoryNames];
    } else {
      // Merge with existing categories
      final existing = categories.toSet();
      existing.addAll(categoryNames);
      categories.value = ['All', ...existing.where((c) => c != 'All').toList()..sort()];
    }
  }

  /// Set search query and fetch posts
  void setSearchQuery(String query) {
    searchQuery.value = query;
    fetchPosts(refresh: true);
  }

  /// Set selected category and fetch posts
  void setCategory(String category) {
    selectedCategory.value = category;
    fetchPosts(refresh: true);
  }

  /// Load more posts (pagination)
  Future<void> loadMore() async {
    if (!hasMore.value || isLoadingMore.value) return;

    currentPage.value++;
    await fetchPosts();
  }

  /// Refresh posts
  @override
  Future<void> refresh() async {
    await fetchPosts(refresh: true);
  }

  /// Get filtered posts (excluding featured)
  List<BlogPost> get regularPosts {
    return posts.where((post) => !post.featured).toList();
  }

  /// Get featured post (first featured post)
  BlogPost? get featuredPost {
    if (featuredPosts.isEmpty && posts.isNotEmpty) {
      // If no featured posts but we have posts, use the first one
      return posts.first;
    }
    return featuredPosts.isNotEmpty ? featuredPosts.first : null;
  }
}
