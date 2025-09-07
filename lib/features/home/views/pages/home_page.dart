import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:news_app/core/utils/Route/app_routes.dart';
import 'package:news_app/features/Favorites/cubit/favorites_cubit.dart';
import 'package:news_app/features/home/cubit/home_cubit.dart';
import 'package:news_app/features/home/views/widgets/modern_carousel_slider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Trigger initial loads
    context.read<HomeCubit>().fetchTopHeadlines();
    context.read<HomeCubit>().fetchRecommendedNews(refresh: true);
    context.read<FavoritesCubit>().getFavorites();
    // Pagination listener
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          context.read<HomeCubit>().hasMore) {
        context.read<HomeCubit>().fetchRecommendedNews();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSearchOpen = false;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Row(
          children: [
            Text(
              'News',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: 42,
                decoration: BoxDecoration(
                  color: _isSearchOpen
                      ? Colors.grey.shade200
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: _isSearchOpen
                      ? [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                child: _isSearchOpen
                    ? TextField(
                        controller: _controller,
                        autofocus: true,
                        style: const TextStyle(fontSize: 16),
                        textAlignVertical: TextAlignVertical.center,
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            context.read<HomeCubit>().searchNews(value);
                          }
                        },
                        decoration: const InputDecoration(
                          hintText: "Search news...",
                          border: InputBorder.none,
                          isCollapsed: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                _isSearchOpen ? Icons.close_rounded : Icons.search_rounded,
                color: Colors.black87,
              ),
              onPressed: () {
                setState(() {
                  if (_isSearchOpen) {
                    _controller.clear();
                    context.read<HomeCubit>().fetchRecommendedNews(
                      refresh: true,
                    );
                  }
                  _isSearchOpen = !_isSearchOpen;
                });
              },
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(10),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.black87,
            ),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.notificationPage),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(10),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.lightBlueAccent),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'News App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_outline),
              title: const Text('Saved Articles'),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.favoritesPage);
              },
            ),
            ListTile(
              leading: const Icon(Icons.public),
              title: const Text('Discover All News'),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.discoverPage);
              },
            ),
          ],
        ),
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<HomeCubit>().fetchTopHeadlines();
          await context.read<HomeCubit>().fetchRecommendedNews(refresh: true);
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // 🔹 Breaking News Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Breaking News',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.discoverPage),
                      child: Text(
                        'See All',
                        style: Theme.of(
                          context,
                        ).textTheme.titleSmall!.copyWith(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),

              // 🔹 Carousel
              SizedBox(
                height: screenHeight * 0.3,
                child: BlocBuilder<HomeCubit, HomeState>(
                  buildWhen: (previous, current) =>
                      current is TopHeadlinesLoaded ||
                      current is TopHeadlinesError ||
                      current is TopHeadlinesLoading,
                  builder: (context, state) {
                    if (state is TopHeadlinesLoading) {
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    } else if (state is TopHeadlinesLoaded) {
                      return ModernCarousel(articles: state.articles);
                    } else if (state is TopHeadlinesError) {
                      return Center(child: Text('Error: ${state.message}'));
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // 🔹 Recommended News OR Search Results
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _controller.text.isNotEmpty
                          ? 'Search Results'
                          : 'Recommended News',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.discoverPage),
                      child: Text(
                        'See All',
                        style: Theme.of(
                          context,
                        ).textTheme.titleSmall!.copyWith(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),

              // 🔹 BlocBuilder (Recommended News + Search)
              BlocBuilder<HomeCubit, HomeState>(
                buildWhen: (previous, current) =>
                    current is RecommendedNewsLoading ||
                    current is RecommendedNewsLoaded ||
                    current is RecommendedNewsError ||
                    current is SearchNewsLoading ||
                    current is SearchNewsLoaded ||
                    current is SearchNewsError,
                builder: (context, state) {
                  if (state is RecommendedNewsLoading ||
                      state is SearchNewsLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    );
                  } else if (state is RecommendedNewsLoaded ||
                      state is SearchNewsLoaded) {
                    final articles = state is RecommendedNewsLoaded
                        ? state.articles
                        : (state as SearchNewsLoaded).articles;

                    return ListView.builder(
                      itemCount: articles.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemBuilder: (context, index) {
                        final article = articles[index];
                        final formattedDate = article.publishedAt != null
                            ? DateFormat.yMMMd().format(article.publishedAt!)
                            : '';

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.antiAlias,
                          elevation: 2,
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.detailsPage,
                                arguments: article,
                              );
                            },
                            child: Stack(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 🔹 Thumbnail
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        bottomLeft: Radius.circular(12),
                                      ),
                                      child: SizedBox(
                                        width: 120,
                                        height: 90,
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              (article.urlToImage != null &&
                                                  article
                                                      .urlToImage!
                                                      .isNotEmpty)
                                              ? article.urlToImage!
                                              : 'https://via.placeholder.com/120x90.png?text=No+Image',
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                                color: Colors.grey[300],
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.image,
                                                    size: 30,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                                color: Colors.grey[300],
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    size: 30,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                        ),
                                      ),
                                    ),

                                    // 🔹 Text content
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              article.title,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                if (article.source?.name !=
                                                    null) ...[
                                                  Icon(
                                                    Icons.public,
                                                    size: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Flexible(
                                                    child: Text(
                                                      article.source!.name,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                            color: Colors
                                                                .grey[700],
                                                          ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                                if (article.source?.name !=
                                                        null &&
                                                    formattedDate.isNotEmpty)
                                                  const SizedBox(width: 12),
                                                if (formattedDate
                                                    .isNotEmpty) ...[
                                                  Icon(
                                                    Icons
                                                        .calendar_today_outlined,
                                                    size: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    formattedDate,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color:
                                                              Colors.grey[700],
                                                        ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // 🔹 Favorite button on top-left of the card
                                Positioned(
                                  top: 6,
                                  left: 6,
                                  child:
                                      BlocBuilder<
                                        FavoritesCubit,
                                        FavoritesState
                                      >(
                                        builder: (context, state) {
                                          if (state is FavoritesLoading) {
                                            return const CircularProgressIndicator.adaptive();
                                          } else if (state is FavoritesLoaded) {
                                            final isFavorited = state.articles
                                                .any(
                                                  (fav) =>
                                                      fav.url == article.url,
                                                );

                                            return ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              child: Container(
                                                color: Colors.white,
                                                child: IconButton(
                                                  icon: Icon(
                                                    isFavorited
                                                        ? Icons.bookmark
                                                        : Icons.bookmark_border,
                                                    color: isFavorited
                                                        ? Colors.lightBlueAccent
                                                        : Colors.black,
                                                  ),
                                                  constraints:
                                                      const BoxConstraints(),
                                                  onPressed: () {
                                                    if (isFavorited) {
                                                      context
                                                          .read<
                                                            FavoritesCubit
                                                          >()
                                                          .removeFavorite(
                                                            article,
                                                          );
                                                    } else {
                                                      context
                                                          .read<
                                                            FavoritesCubit
                                                          >()
                                                          .addFavorite(article);
                                                    }
                                                  },
                                                ),
                                              ),
                                            );
                                          } else if (state is FavoritesError) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Error: ${state.message}',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return const Icon(
                                              Icons.error,
                                              color: Colors.red,
                                            );
                                          }

                                          return const SizedBox.shrink();
                                        },
                                      ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state is RecommendedNewsError ||
                      state is SearchNewsError) {
                    final message = state is RecommendedNewsError
                        ? state.message
                        : (state as SearchNewsError).message;
                    return Center(child: Text('Error: $message'));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
