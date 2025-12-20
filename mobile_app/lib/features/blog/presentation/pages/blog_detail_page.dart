import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';

import '../controllers/blog_detail_controller.dart';
import '../../data/models/blog_post.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';

/// Blog Detail Page
class BlogDetailPage extends StatelessWidget {
  final String postId;

  const BlogDetailPage({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      BlogDetailController(postId: postId),
      tag: postId,
    );

    return Scaffold(
      backgroundColor: DashboardColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: DashboardColors.accent),
          );
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: DashboardColors.textGray,
                ),
                const SizedBox(height: 16),
                Text(
                  controller.error.value,
                  style: const TextStyle(
                    color: DashboardColors.textWhite,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchPost(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DashboardColors.accent,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final post = controller.post.value;
        if (post == null) {
          return const Center(
            child: Text(
              'Post not found',
              style: TextStyle(color: DashboardColors.textWhite, fontSize: 16),
            ),
          );
        }

        return SafeArea(
          top: false, // Allow hero image to extend behind status bar
          child: CustomScrollView(
            slivers: [
              // Hero Image with Overlay Buttons
              _buildHeroImage(post, controller),
              // Article Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Category Tag
                    _buildCategoryTag(post),
                    const SizedBox(height: 16),
                    // Title
                    _buildTitle(post),
                    const SizedBox(height: 16),
                    // Author & Date Info
                    _buildAuthorInfo(post),
                    const SizedBox(height: 24),
                    // Article Content
                    _buildContent(post),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeroImage(BlogPost post, BlogDetailController controller) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: false,
      backgroundColor: DashboardColors.background,
      flexibleSpace: Stack(
        children: [
          // Hero Image
          FlexibleSpaceBar(
            background: post.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: post.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: DashboardColors.backgroundDark,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: DashboardColors.accent,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: DashboardColors.backgroundDark,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: DashboardColors.textGray,
                        size: 48,
                      ),
                    ),
                  )
                : Container(
                    color: DashboardColors.backgroundDark,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: DashboardColors.textGray,
                      size: 48,
                    ),
                  ),
          ),
          // Overlay Buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  _buildOverlayButton(
                    icon: Icons.arrow_back,
                    onTap: () => Get.back(),
                  ),
                  // Right Buttons
                  Row(
                    children: [
                      // Bookmark Button
                      Obx(
                        () => _buildOverlayButton(
                          icon: controller.isBookmarked.value
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            controller.toggleBookmark();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Share Button
                      _buildOverlayButton(
                        icon: Icons.share,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          controller.sharePost();
                          if (post.url != null) {
                            Share.share(post.url!);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black87, size: 22),
      ),
    );
  }

  Widget _buildCategoryTag(BlogPost post) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: DashboardColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getCategoryIcon(post.category.name),
              color: DashboardColors.accent,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              post.category.name.toUpperCase(),
              style: const TextStyle(
                color: DashboardColors.accent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(BlogPost post) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        post.title,
        style: const TextStyle(
          color: DashboardColors.textWhite,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _buildAuthorInfo(BlogPost post) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Author Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: DashboardColors.backgroundDark,
            backgroundImage: post.authorAvatarUrl != null
                ? NetworkImage(post.authorAvatarUrl!)
                : null,
            child: post.authorAvatarUrl == null
                ? Text(
                    post.author.name.isNotEmpty
                        ? post.author.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: DashboardColors.textWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          // Author Name & Role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  post.author.name,
                  style: const TextStyle(
                    color: DashboardColors.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Editor-in-Chief', // TODO: Get from API if available
                  style: TextStyle(
                    color: DashboardColors.textGray,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Date & Read Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (post.publishedAt != null)
                Text(
                  _formatDate(post.publishedAt!),
                  style: const TextStyle(
                    color: DashboardColors.textWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: DashboardColors.textGray,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post.readTimeMinutes} min read',
                    style: TextStyle(
                      color: DashboardColors.textGray,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BlogPost post) {
    // Parse content and render with proper formatting
    final content = post.content;
    if (content.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          post.excerpt,
          style: TextStyle(
            color: DashboardColors.textGray,
            fontSize: 16,
            height: 1.7,
          ),
        ),
      );
    }

    // Simple content rendering - can be enhanced with HTML parsing if needed
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _parseAndRenderContent(content),
    );
  }

  Widget _parseAndRenderContent(String content) {
    final widgets = <Widget>[];

    // Try to parse as HTML first
    if (content.contains('<')) {
      return _parseHtmlContent(content);
    }

    // Otherwise parse as plain text with markdown-like syntax
    final lines = content.split('\n');
    String? currentParagraph = '';

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) {
        if (currentParagraph!.isNotEmpty) {
          widgets.add(_buildParagraph(currentParagraph));
          widgets.add(const SizedBox(height: 16));
          currentParagraph = '';
        } else {
          widgets.add(const SizedBox(height: 16));
        }
        continue;
      }

      // Check for blockquote (starts with > or quote markers)
      if (line.startsWith('>') || (line.startsWith('"') && line.length > 10)) {
        if (currentParagraph!.isNotEmpty) {
          widgets.add(_buildParagraph(currentParagraph));
          widgets.add(const SizedBox(height: 16));
          currentParagraph = '';
        }
        widgets.add(
          _buildBlockQuote(line.replaceAll(RegExp(r'^[>"]\s*'), '').trim()),
        );
        widgets.add(const SizedBox(height: 16));
        continue;
      }

      // Check for heading (starts with ##)
      if (line.startsWith('##')) {
        if (currentParagraph!.isNotEmpty) {
          widgets.add(_buildParagraph(currentParagraph));
          widgets.add(const SizedBox(height: 16));
          currentParagraph = '';
        }
        widgets.add(
          _buildSubHeading(line.replaceAll(RegExp(r'^#+\s*'), '').trim()),
        );
        widgets.add(const SizedBox(height: 12));
        continue;
      }

      // Accumulate paragraph text
      if (currentParagraph!.isNotEmpty) {
        currentParagraph += ' $line';
      } else {
        currentParagraph = line;
      }
    }

    // Add remaining paragraph
    if (currentParagraph!.isNotEmpty) {
      widgets.add(_buildParagraph(currentParagraph));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _parseHtmlContent(String html) {
    final widgets = <Widget>[];

    // Remove HTML tags and extract text content
    // This is a simplified parser - for production, consider using flutter_html package
    String cleanText = html
        .replaceAll(RegExp(r'<script[^>]*>.*?</script>', dotAll: true), '')
        .replaceAll(RegExp(r'<style[^>]*>.*?</style>', dotAll: true), '')
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // Split by common HTML block elements
    final blocks = cleanText.split(RegExp(r'\n\s*\n'));

    for (var block in blocks) {
      block = block.trim();
      if (block.isEmpty) continue;

      // Check if it looks like a quote (contains quotes or italic markers)
      if (block.startsWith('"') && block.endsWith('"') && block.length > 20) {
        widgets.add(_buildBlockQuote(block.replaceAll('"', '').trim()));
        widgets.add(const SizedBox(height: 16));
      } else if (block.length > 50 && block.contains('.')) {
        // Regular paragraph
        widgets.add(_buildParagraph(block));
        widgets.add(const SizedBox(height: 16));
      }
    }

    // If no blocks found, just render the cleaned text
    if (widgets.isEmpty && cleanText.isNotEmpty) {
      widgets.add(_buildParagraph(cleanText));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: TextStyle(
        color: DashboardColors.textWhite,
        fontSize: 16,
        height: 1.7,
      ),
    );
  }

  Widget _buildSubHeading(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: DashboardColors.accent,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        height: 1.4,
      ),
    );
  }

  Widget _buildBlockQuote(String text) {
    return Container(
      padding: const EdgeInsets.only(left: 16, top: 12, bottom: 12, right: 12),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: DashboardColors.accent, width: 4),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: DashboardColors.textWhite,
          fontSize: 18,
          fontStyle: FontStyle.italic,
          height: 1.6,
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('campaign')) {
      return Icons.campaign;
    } else if (name.contains('policy')) {
      return Icons.description;
    } else if (name.contains('event')) {
      return Icons.event;
    } else if (name.contains('campus') || name.contains('news')) {
      return Icons.newspaper;
    } else if (name.contains('student')) {
      return Icons.school;
    }
    return Icons.article;
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
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
    } catch (e) {
      return dateString;
    }
  }
}
