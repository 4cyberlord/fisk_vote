import 'blog_post.dart';

/// Pagination Links Model
class PaginationLinks {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  PaginationLinks({this.first, this.last, this.prev, this.next});

  factory PaginationLinks.fromJson(Map<String, dynamic> json) {
    return PaginationLinks(
      first: json['first'] as String?,
      last: json['last'] as String?,
      prev: json['prev'] as String?,
      next: json['next'] as String?,
    );
  }
}

/// Pagination Meta Model
class PaginationMeta {
  final int currentPage;
  final int from;
  final int lastPage;
  final String path;
  final int perPage;
  final int to;
  final int total;

  PaginationMeta({
    required this.currentPage,
    required this.from,
    required this.lastPage,
    required this.path,
    required this.perPage,
    required this.to,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] as int? ?? 1,
      from: json['from'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      path: json['path'] as String? ?? '',
      perPage: json['per_page'] as int? ?? 0,
      to: json['to'] as int? ?? 1,
      total: json['total'] as int? ?? 0,
    );
  }
}

/// Blog Posts Response Model
class BlogPostsResponse {
  final List<BlogPost> data;
  final PaginationLinks links;
  final PaginationMeta meta;

  BlogPostsResponse({
    required this.data,
    required this.links,
    required this.meta,
  });

  factory BlogPostsResponse.fromJson(Map<String, dynamic> json) {
    return BlogPostsResponse(
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => BlogPost.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      links: PaginationLinks.fromJson(
        json['links'] as Map<String, dynamic>? ?? {},
      ),
      meta: PaginationMeta.fromJson(
        json['meta'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
