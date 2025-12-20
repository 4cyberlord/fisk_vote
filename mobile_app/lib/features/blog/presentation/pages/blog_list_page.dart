import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../controllers/blog_controller.dart';
import '../../data/models/blog_post.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import 'blog_detail_page.dart';
import 'all_articles_page.dart';

/// Blog List Page - "The Fisk Voice"
/// Modern, feature-rich blog section with hero, popular posts, and enhanced UI
class BlogListPage extends StatefulWidget {
  const BlogListPage({super.key});

  @override
  State<BlogListPage> createState() => _BlogListPageState();
}

class _BlogListPageState extends State<BlogListPage> {
  late final BlogController _controller;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(BlogController());
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  void _onSearchChanged() {
    // Debounce search - only search after user stops typing
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
        child: RefreshIndicator(
          onRefresh: () => _controller.refresh(),
          color: DashboardColors.accent,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App Bar with Search
              SliverAppBar(
                pinned: true,
                floating: false,
                backgroundColor: DashboardColors.background,
                elevation: 0,
                title: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Blog',
                    style: TextStyle(
                      color: DashboardColors.textWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                ),
              ),
                titleSpacing: 16,
                actions: [
                  Obx(() {
                    final hasActiveFilters =
                        _controller.selectedCategory.value != 'All' ||
                        _controller.searchQuery.value.isNotEmpty;
                    return IconButton(
                      icon: Stack(
                  children: [
                          Icon(
                            Icons.tune,
                            color: DashboardColors.textWhite,
                            size: 24,
                          ),
                          if (hasActiveFilters)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: DashboardColors.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _showFilterModal(context);
                      },
                    );
                  }),
                  const SizedBox(width: 8),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(80),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: _buildSearchBar(),
                ),
              ),
              ),

              // Category Filters
              SliverToBoxAdapter(child: _buildCategoryFilters()),

              // Hero Featured Post
                    Obx(() {
                      final featured = _controller.featuredPost;
                      if (featured != null) {
                        return SliverToBoxAdapter(
                          child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: _buildHeroFeaturedCard(featured),
                          ),
                        );
                      }
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    }),

              // Popular Posts Section
              Obx(() {
                if (_controller.popularPosts.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
                return SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.local_fire_department,
                                  color: DashboardColors.accent,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Popular Now',
                                  style: TextStyle(
                                    color: DashboardColors.textWhite,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 280,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _controller.popularPosts.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: _buildPopularPostCard(
                                _controller.popularPosts[index],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              }),

              // Latest Updates Header
                    SliverToBoxAdapter(
                      child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: _buildLatestUpdatesHeader(),
                      ),
                    ),

                    // Posts List
                    Obx(() {
                if (_controller.isLoading.value && _controller.posts.isEmpty) {
                        return const SliverFillRemaining(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: DashboardColors.accent,
                            ),
                          ),
                        );
                      }

                      if (_controller.error.value.isNotEmpty &&
                          _controller.posts.isEmpty) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: DashboardColors.textGray,
                                ),
                                const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                                  _controller.error.value,
                              style: const TextStyle(
                                    color: DashboardColors.textWhite,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                            ),
                                ),
                                const SizedBox(height: 16),
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

                      final regularPosts = _controller.regularPosts;
                      if (regularPosts.isEmpty) {
                        return SliverFillRemaining(
                    hasScrollBody: false,
                          child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.article_outlined,
                              size: 64,
                                  color: DashboardColors.textGray,
                                ),
                            const SizedBox(height: 16),
                            const Text(
                                  'No posts found',
                                  style: TextStyle(
                                    color: DashboardColors.textWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your filters or search',
                              style: TextStyle(
                                color: DashboardColors.textGray,
                                fontSize: 14,
                                  ),
                              textAlign: TextAlign.center,
                                ),
                              ],
                        ),
                            ),
                          ),
                        );
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index < regularPosts.length) {
                              return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: _buildPostCard(regularPosts[index]),
                              );
                            } else if (_controller.isLoadingMore.value) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: DashboardColors.accent,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                          childCount:
                              regularPosts.length +
                              (_controller.isLoadingMore.value ? 1 : 0),
                        ),
                      );
                    }),
                  ],
              ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
        decoration: BoxDecoration(
          color: DashboardColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        ),
        child: TextField(
          controller: _searchController,
        style: const TextStyle(color: DashboardColors.textWhite, fontSize: 16),
          decoration: InputDecoration(
          hintText: 'Search articles, topics, authors...',
            hintStyle: TextStyle(color: DashboardColors.textGray, fontSize: 14),
            prefixIcon: const Icon(
              Icons.search,
              color: DashboardColors.textGray,
            size: 22,
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
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Obx(() {
      final categories = _controller.categories;
      if (categories.isEmpty) return const SizedBox.shrink();

      return Container(
        height: 50,
        margin: const EdgeInsets.only(bottom: 16),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = _controller.selectedCategory.value == category;

            // Get category color from categoriesList
            Color? categoryColor;
            if (_controller.categoriesList.isNotEmpty) {
              try {
                final categoryData = _controller.categoriesList.firstWhere(
                  (c) => c.name == category,
                  orElse: () => _controller.categoriesList.first,
                );
                final colorString = categoryData.color;
                if (colorString != null && colorString.isNotEmpty) {
                  try {
                    categoryColor = Color(
                      int.parse(colorString.replaceFirst('#', '0xFF')),
                    );
                  } catch (e) {
                    categoryColor = DashboardColors.accent;
                  }
                }
              } catch (e) {
                // Ignore errors in category lookup
              }
            }

            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _controller.setCategory(category);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (categoryColor ?? DashboardColors.accent)
                        : DashboardColors.surface,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (category != 'All') ...[
                        Icon(
                          _getCategoryIcon(category),
                          size: 16,
                          color: isSelected
                              ? Colors.black
                              : DashboardColors.textGray,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        category,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.black
                              : DashboardColors.textGray,
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildHeroFeaturedCard(BlogPost post) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Get.to(() => BlogDetailPage(postId: post.id.toString()));
      },
      child: Container(
        decoration: BoxDecoration(
          color: DashboardColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image with Featured badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: post.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: post.imageUrl!,
                          width: double.infinity,
                          height: 240,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: double.infinity,
                            height: 240,
                            color: DashboardColors.backgroundDark,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: DashboardColors.accent,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: double.infinity,
                            height: 240,
                            color: DashboardColors.backgroundDark,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  DashboardColors.backgroundDark,
                                  DashboardColors.surface,
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.image_not_supported,
                              color: DashboardColors.textGray,
                              size: 48,
                            ),
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          height: 240,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                DashboardColors.accent.withValues(alpha: 0.3),
                                DashboardColors.backgroundDark,
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.article,
                            color: DashboardColors.textGray,
                            size: 48,
                          ),
                        ),
                ),
                // Featured Badge
                  Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: DashboardColors.accent,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.black, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Featured',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // View Count
                if (post.viewCount > 0)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.visibility,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatViewCount(post.viewCount),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Category & Read Time
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: DashboardColors.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                        post.category.name.toUpperCase(),
                        style: const TextStyle(
                          color: DashboardColors.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.access_time,
                        size: 14,
                          color: DashboardColors.textGray,
                        ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.readTimeMinutes} min',
                        style: TextStyle(
                          color: DashboardColors.textGray,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    post.title,
                    style: const TextStyle(
                      color: DashboardColors.textWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Excerpt
                  Text(
                    post.excerpt,
                    style: TextStyle(
                      color: DashboardColors.textGray,
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  // Author & Date
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
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
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              post.author.name,
                              style: const TextStyle(
                                color: DashboardColors.textWhite,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (post.publishedAt != null)
                              Text(
                                _formatDate(post.publishedAt!),
                                style: TextStyle(
                                  color: DashboardColors.textGray,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Read More Arrow
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: DashboardColors.accent.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: DashboardColors.accent,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  // Tags
                  if (post.tags != null && post.tags!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: post.tags!.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: DashboardColors.backgroundDark,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '#$tag',
                            style: TextStyle(
                              color: DashboardColors.textGray,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularPostCard(BlogPost post) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Get.to(() => BlogDetailPage(postId: post.id.toString()));
      },
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: DashboardColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: post.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: post.imageUrl!,
                      width: double.infinity,
                      height: 140,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: double.infinity,
                        height: 140,
                        color: DashboardColors.backgroundDark,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: DashboardColors.accent,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: double.infinity,
                        height: 140,
                        color: DashboardColors.backgroundDark,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: DashboardColors.textGray,
                          size: 32,
                        ),
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      height: 140,
                      color: DashboardColors.backgroundDark,
                      child: const Icon(
                        Icons.article,
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
                    // Category
                    Text(
                      post.category.name.toUpperCase(),
                      style: const TextStyle(
                        color: DashboardColors.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Title
                    Expanded(
                      child: Text(
                        post.title,
                        style: const TextStyle(
                          color: DashboardColors.textWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Author & Read Time
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${post.readTimeMinutes} min',
                            style: TextStyle(
                              color: DashboardColors.textGray,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (post.viewCount > 0)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.visibility,
                                size: 12,
                                color: DashboardColors.textGray,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                _formatViewCount(post.viewCount),
                                style: TextStyle(
                                  color: DashboardColors.textGray,
                                  fontSize: 10,
                                ),
                              ),
                            ],
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

  Widget _buildLatestUpdatesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Latest Updates',
          style: TextStyle(
            color: DashboardColors.textWhite,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Get.to(() => const AllArticlesPage());
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: DashboardColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
                Text(
                'View All',
                style: TextStyle(
                  color: DashboardColors.accent,
                  fontSize: 14,
                    fontWeight: FontWeight.w600,
                ),
              ),
                SizedBox(width: 4),
                Icon(
                Icons.arrow_forward,
                color: DashboardColors.accent,
                size: 16,
              ),
            ],
            ),
          ),
        ),
      ],
    );
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
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
                      width: 130,
                      height: 130,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 130,
                        height: 130,
                        color: DashboardColors.backgroundDark,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: DashboardColors.accent,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 130,
                        height: 130,
                        color: DashboardColors.backgroundDark,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: DashboardColors.textGray,
                          size: 32,
                        ),
                      ),
                    )
                  : Container(
                      width: 130,
                      height: 130,
                      color: DashboardColors.backgroundDark,
                      child: const Icon(
                        Icons.article,
                        color: DashboardColors.textGray,
                        size: 32,
                      ),
                    ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
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
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                          post.category.name.toUpperCase(),
                          style: const TextStyle(
                            color: DashboardColors.accent,
                            fontSize: 11,
                              fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Title
                    Text(
                      post.title,
                      style: const TextStyle(
                        color: DashboardColors.textWhite,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
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
                    const SizedBox(height: 10),
                    // Author, Read Time & Views
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 10,
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
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${post.author.name} • ${post.readTimeMinutes} min',
                            style: TextStyle(
                              color: DashboardColors.textGray,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (post.viewCount > 0)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.visibility,
                                size: 12,
                                color: DashboardColors.textGray,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                _formatViewCount(post.viewCount),
                                style: TextStyle(
                                  color: DashboardColors.textGray,
                                  fontSize: 10,
                                ),
                              ),
                            ],
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
    } else if (name.contains('news')) {
      return Icons.newspaper;
    } else if (name.contains('sport')) {
      return Icons.sports;
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
        return '${difference.inDays} days ago';
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
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }

  String _formatViewCount(int count) {
    if (count < 1000) {
      return count.toString();
    } else if (count < 1000000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _FilterModal(controller: _controller),
    );
  }
}

/// Filter Modal Bottom Sheet
class _FilterModal extends StatefulWidget {
  final BlogController controller;

  const _FilterModal({required this.controller});

  @override
  State<_FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<_FilterModal> {
  String _selectedSort = 'newest';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.controller.selectedCategory.value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DashboardColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: DashboardColors.textGray.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter & Sort',
                      style: TextStyle(
                        color: DashboardColors.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedSort = 'newest';
                          _selectedCategory = 'All';
                        });
                        widget.controller.setCategory('All');
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Reset',
                        style: TextStyle(
                          color: DashboardColors.accent,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            ),
        ],
      ),
              ),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Sort By Section
                    _buildSectionTitle('Sort By'),
                    const SizedBox(height: 12),
                    _buildSortOption(
                      'newest',
                      'Newest First',
                      Icons.access_time,
                    ),
                    _buildSortOption('oldest', 'Oldest First', Icons.history),
                    _buildSortOption(
                      'popular',
                      'Most Popular',
                      Icons.local_fire_department,
                    ),
                    const SizedBox(height: 24),
                    // Category Filter Section
                    _buildSectionTitle('Category'),
                    const SizedBox(height: 12),
                    Obx(() {
                      return Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: widget.controller.categories.map((category) {
                          final isSelected = _selectedCategory == category;
                          return _buildCategoryChip(category, isSelected);
                        }).toList(),
                      );
                    }),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
              // Apply Button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: DashboardColors.surface,
                  border: Border(
                    top: BorderSide(
                      color: DashboardColors.backgroundDark,
                      width: 1,
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      if (_selectedCategory != null) {
                        widget.controller.setCategory(_selectedCategory!);
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DashboardColors.accent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
    );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: DashboardColors.textWhite,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSortOption(String value, String label, IconData icon) {
    final isSelected = _selectedSort == value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedSort = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? DashboardColors.accent.withValues(alpha: 0.2)
                : DashboardColors.backgroundDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? DashboardColors.accent
                  : DashboardColors.backgroundDark,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? DashboardColors.accent
                    : DashboardColors.textGray,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? DashboardColors.textWhite
                        : DashboardColors.textGray,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: DashboardColors.accent,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category, bool isSelected) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? DashboardColors.accent
              : DashboardColors.backgroundDark,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (category != 'All')
              Icon(
                _getCategoryIcon(category),
                size: 16,
                color: isSelected ? Colors.black : DashboardColors.textGray,
              ),
            if (category != 'All') const SizedBox(width: 6),
            Text(
              category,
              style: TextStyle(
                color: isSelected ? Colors.black : DashboardColors.textGray,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
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
    } else if (name.contains('news')) {
      return Icons.newspaper;
    } else if (name.contains('sport')) {
      return Icons.sports;
    }
    return Icons.article;
  }
}
