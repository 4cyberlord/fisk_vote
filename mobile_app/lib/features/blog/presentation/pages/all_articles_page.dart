import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../controllers/blog_controller.dart';
import '../../data/models/blog_post.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import 'blog_detail_page.dart';

/// All Articles Page - Shows all blog posts
class AllArticlesPage extends StatefulWidget {
  const AllArticlesPage({super.key});

  @override
  State<AllArticlesPage> createState() => _AllArticlesPageState();
}

class _AllArticlesPageState extends State<AllArticlesPage> {
  late final BlogController _controller;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    // Use existing controller or create new one
    _controller = Get.isRegistered<BlogController>()
        ? Get.find<BlogController>()
        : Get.put(BlogController());
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    
    // Load all posts if not already loaded
    if (_controller.posts.isEmpty) {
      _controller.fetchPosts(refresh: true);
    }
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text != _controller.searchQuery.value) {
        _controller.setSearchQuery(_searchController.text);
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _controller.loadMore();
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(),
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: _buildSearchBar(),
            ),
            // Category Filters
            _buildCategoryFilters(),
            const SizedBox(height: 20),
            // Articles List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _controller.refresh(),
                color: DashboardColors.accent,
                child: Obx(() {
                  if (_controller.isLoading.value &&
                      _controller.posts.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: DashboardColors.accent,
                      ),
                    );
                  }

                  if (_controller.error.value.isNotEmpty &&
                      _controller.posts.isEmpty) {
                    return _buildErrorView();
                  }

                  if (_controller.posts.isEmpty) {
                    return _buildEmptyView();
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: _controller.posts.length + (_controller.hasMore.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _controller.posts.length) {
                        // Loading more indicator
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Obx(() => _controller.isLoadingMore.value
                                ? const CircularProgressIndicator(
                                    color: DashboardColors.accent,
                                  )
                                : const SizedBox.shrink()),
                          ),
                        );
                      }

                      final post = _controller.posts[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildPostCard(post),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: DashboardColors.background,
        border: Border(
          bottom: BorderSide(
            color: DashboardColors.surface.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Get.back();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: DashboardColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: DashboardColors.textWhite,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Title
          const Expanded(
            child: Text(
              'All Articles',
              style: TextStyle(
                color: DashboardColors.textWhite,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Article count
          Obx(() => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: DashboardColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_controller.posts.length}',
              style: const TextStyle(
                color: DashboardColors.accent,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: DashboardColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(
          color: DashboardColors.textWhite,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: 'Search articles...',
          hintStyle: TextStyle(
            color: DashboardColors.textGray,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: DashboardColors.textGray,
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: DashboardColors.textGray,
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _controller.setSearchQuery('');
                  },
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

  Widget _buildCategoryFilters() {
    return Obx(() {
      final categories = _controller.categories;
      final selectedCategory = _controller.selectedCategory.value;

      return SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedCategory == category;

            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _controller.setCategory(category);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? DashboardColors.accent
                        : DashboardColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? DashboardColors.accent
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.black
                          : DashboardColors.textWhite,
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildPostCard(BlogPost post) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Get.to(() => BlogDetailPage(postId: post.id.toString()));
      },
      child: Container(
        decoration: BoxDecoration(
          color: DashboardColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: post.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: post.imageUrl!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 120,
                        height: 120,
                        color: DashboardColors.backgroundDark,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: DashboardColors.accent,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 120,
                        height: 120,
                        color: DashboardColors.backgroundDark,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: DashboardColors.textGray,
                          size: 32,
                        ),
                      ),
                    )
                  : Container(
                      width: 120,
                      height: 120,
                      color: DashboardColors.backgroundDark,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: DashboardColors.textGray,
                        size: 32,
                      ),
                    ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Icon
                    Row(
                      children: [
                        Icon(
                          _getCategoryIcon(post.category.name),
                          size: 14,
                          color: DashboardColors.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          post.category.name.toUpperCase(),
                          style: const TextStyle(
                            color: DashboardColors.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (post.featured) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: DashboardColors.accent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'FEATURED',
                              style: TextStyle(
                                color: DashboardColors.accent,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Title
                    Text(
                      post.title,
                      style: const TextStyle(
                        color: DashboardColors.textWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Excerpt
                    Text(
                      post.excerpt,
                      style: TextStyle(
                        color: DashboardColors.textGray,
                        fontSize: 12,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Author & Read Time
                    Row(
                      children: [
                        // Author Avatar
                        CircleAvatar(
                          radius: 12,
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
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 6),
                        // Author Name & Read Time
                        Expanded(
                          child: Text(
                            '${post.author.name} • ${post.readTimeMinutes} min read',
                            style: TextStyle(
                              color: DashboardColors.textGray,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Date
                        if (post.publishedAt != null)
                          Text(
                            _formatDate(post.publishedAt!),
                            style: TextStyle(
                              color: DashboardColors.textGray.withValues(alpha: 0.7),
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
              'Failed to Load Articles',
              style: TextStyle(
                color: DashboardColors.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _controller.error.value,
              style: TextStyle(
                color: DashboardColors.textGray,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _controller.refresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: DashboardColors.accent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 48,
              color: DashboardColors.textGray,
            ),
            const SizedBox(height: 16),
            Text(
              'No Articles Found',
              style: TextStyle(
                color: DashboardColors.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                color: DashboardColors.textGray,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
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
    } else if (name.contains('campus') || name.contains('life')) {
      return Icons.school;
    }
    return Icons.article;
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '${weeks}w ago';
      } else {
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
        return '${months[date.month - 1]} ${date.day}';
      }
    } catch (e) {
      return dateString;
    }
  }
}

