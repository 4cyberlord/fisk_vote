import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exceptions.dart';
import '../models/blog_posts_response.dart';
import '../models/blog_post.dart';
import '../models/blog_category.dart';

/// Repository for blog-related API calls.
class BlogRepository {
  final ApiClient _apiClient;

  BlogRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  /// Get all blog posts.
  ///
  /// Optionally filter by category, search query, and pagination.
  ///
  /// Throws [ServerException] for server errors.
  /// Throws [NetworkException] if no internet connection.
  Future<BlogPostsResponse> getPosts({
    String? category,
    String? search,
    int? page,
    int? perPage,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (category != null && category.isNotEmpty) {
        queryParameters['category'] = category;
      }
      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }
      if (page != null) {
        queryParameters['page'] = page;
      }
      if (perPage != null) {
        queryParameters['per_page'] = perPage;
      }

      final response = await _apiClient.get(
        ApiEndpoints.blogPosts,
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );

      final responseData = response.data as Map<String, dynamic>;

      // Handle API response structure: {data: [...], links: {...}, meta: {...}}
      return BlogPostsResponse.fromJson(responseData);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  /// Get a single blog post by ID or slug.
  ///
  /// Throws [NotFoundException] if post not found.
  /// Throws [ServerException] for server errors.
  /// Throws [NetworkException] if no internet connection.
  Future<BlogPost> getPost(String id) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.blogPost(id));

      final responseData = response.data as Map<String, dynamic>;

      // Handle API response structure: {data: {...}}
      Map<String, dynamic> data;
      if (responseData.containsKey('data') &&
          responseData['data'] is Map<String, dynamic>) {
        data = responseData['data'] as Map<String, dynamic>;
      } else {
        data = responseData;
      }

      return BlogPost.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  /// Get featured blog posts.
  Future<BlogPostsResponse> getFeatured({int? limit}) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (limit != null) {
        queryParameters['limit'] = limit;
      }

      final response = await _apiClient.get(
        ApiEndpoints.blogFeatured,
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );

      final responseData = response.data as Map<String, dynamic>;
      return BlogPostsResponse.fromJson(responseData);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  /// Get popular blog posts.
  Future<BlogPostsResponse> getPopular({int? limit}) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (limit != null) {
        queryParameters['limit'] = limit;
      }

      final response = await _apiClient.get(
        ApiEndpoints.blogPopular,
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );

      final responseData = response.data as Map<String, dynamic>;
      return BlogPostsResponse.fromJson(responseData);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  /// Get recent blog posts.
  Future<BlogPostsResponse> getRecent({int? limit, int? excludeId}) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (limit != null) {
        queryParameters['limit'] = limit;
      }
      if (excludeId != null) {
        queryParameters['exclude'] = excludeId;
      }

      final response = await _apiClient.get(
        ApiEndpoints.blogRecent,
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );

      final responseData = response.data as Map<String, dynamic>;
      return BlogPostsResponse.fromJson(responseData);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  /// Get blog categories.
  Future<List<BlogCategory>> getCategories() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.blogCategories);

      final responseData = response.data as Map<String, dynamic>;
      
      // Handle API response structure: {data: [...]}
      List<dynamic> data;
      if (responseData.containsKey('data') &&
          responseData['data'] is List) {
        data = responseData['data'] as List<dynamic>;
      } else if (responseData is List) {
        data = responseData as List<dynamic>;
      } else {
        data = [];
      }

      return data.map((json) => BlogCategory.fromJson(json as Map<String, dynamic>)).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }
}
