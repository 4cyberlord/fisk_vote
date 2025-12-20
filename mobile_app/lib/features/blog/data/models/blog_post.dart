import 'blog_category.dart';
import 'blog_author.dart';
import '../../../../core/config/app_config.dart';

/// Blog Post Model
class BlogPost {
  final int id;
  final String title;
  final String slug;
  final String excerpt;
  final String content;
  final BlogCategory category;
  final BlogAuthor author;
  final String? image;
  final bool featured;
  final String status;
  final String? date;
  final String? publishedAt;
  final String? readTime;
  final int readTimeMinutes;
  final int viewCount;
  final String? metaTitle;
  final String? metaDescription;
  final List<String>? tags;
  final String? url;

  BlogPost({
    required this.id,
    required this.title,
    required this.slug,
    required this.excerpt,
    required this.content,
    required this.category,
    required this.author,
    this.image,
    required this.featured,
    required this.status,
    this.date,
    this.publishedAt,
    this.readTime,
    required this.readTimeMinutes,
    required this.viewCount,
    this.metaTitle,
    this.metaDescription,
    this.tags,
    this.url,
  });

  factory BlogPost.fromJson(Map<String, dynamic> json) {
    return BlogPost(
      id: json['id'] as int,
      title: json['title'] as String,
      slug: json['slug'] as String,
      excerpt: json['excerpt'] as String? ?? '',
      content: json['content'] as String? ?? '',
      category: BlogCategory.fromJson(json['category'] as Map<String, dynamic>),
      author: BlogAuthor.fromJson(json['author'] as Map<String, dynamic>),
      image: json['image'] as String?,
      featured: json['featured'] as bool? ?? false,
      status: json['status'] as String? ?? 'published',
      date: json['date'] as String?,
      publishedAt: json['published_at'] as String?,
      readTime: json['readTime'] as String?,
      readTimeMinutes: json['read_time'] as int? ?? 0,
      viewCount: json['view_count'] as int? ?? 0,
      metaTitle: json['meta_title'] as String?,
      metaDescription: json['meta_description'] as String?,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : null,
      url: json['url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'excerpt': excerpt,
      'content': content,
      'category': category.toJson(),
      'author': author.toJson(),
      'image': image,
      'featured': featured,
      'status': status,
      'date': date,
      'published_at': publishedAt,
      'readTime': readTime,
      'read_time': readTimeMinutes,
      'view_count': viewCount,
      'meta_title': metaTitle,
      'meta_description': metaDescription,
      'tags': tags,
      'url': url,
    };
  }

  /// Get full URL for image
  String? get imageUrl {
    if (image == null) return null;
    if (image!.startsWith('http://') || image!.startsWith('https://')) {
      return image;
    }
    final cleanPath = image!.startsWith('/') ? image!.substring(1) : image!;
    return '${AppConfig.apiBaseUrl}/$cleanPath';
  }

  /// Get full URL for author avatar
  String? get authorAvatarUrl {
    if (author.avatar == null) return null;
    if (author.avatar!.startsWith('http://') ||
        author.avatar!.startsWith('https://')) {
      return author.avatar;
    }
    final cleanPath = author.avatar!.startsWith('/')
        ? author.avatar!.substring(1)
        : author.avatar!;
    return '${AppConfig.apiBaseUrl}/$cleanPath';
  }
}
