import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:news_app/core/utils/Route/app_routes.dart';
import 'package:news_app/features/Discover/cubit/discover_cubit.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Initial fetch
    context.read<DiscoverCubit>().fetchDiscoverArticles(refresh: true);

    // Pagination listener
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          context.read<DiscoverCubit>().hasMore) {
        final cubit = context.read<DiscoverCubit>();
        if (cubit.state is DiscoverLoaded && cubit.currentQuery != null) {
          cubit.searchArticles(cubit.currentQuery!);
        } else {
          cubit.fetchDiscoverArticles();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.black87,
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Title
              Text(
                "Discover",
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // 🔹 Search Bar
              TextField(
                controller: _searchController,
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    context.read<DiscoverCubit>().searchArticles(
                      value.trim(),
                      refresh: true,
                    );
                  } else {
                    context.read<DiscoverCubit>().fetchDiscoverArticles(
                      refresh: true,
                    );
                  }
                },
                decoration: InputDecoration(
                  hintText: "Search for news...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 20),

              // 🔹 News Feed
              Expanded(
                child: BlocBuilder<DiscoverCubit, DiscoverState>(
                  builder: (context, state) {
                    if (state is DiscoverLoading &&
                        (state is! DiscoverLoaded)) {
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    } else if (state is DiscoverLoaded) {
                      final articles = state.articles;

                      if (articles.isEmpty) {
                        return const Center(child: Text("No articles found."));
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: articles.length + 1, // +1 for loader
                        itemBuilder: (context, index) {
                          if (index == articles.length) {
                            if (context.read<DiscoverCubit>().hasMore) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator.adaptive(),
                                ),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }

                          final article = articles[index];
                          final formattedDate = article.publishedAt != null
                              ? DateFormat.yMMMd().format(article.publishedAt!)
                              : "";

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 3,
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.detailsPage,
                                  arguments: article,
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 🔹 Thumbnail
                                  if (article.urlToImage != null &&
                                      article.urlToImage!.isNotEmpty)
                                    CachedNetworkImage(
                                      imageUrl: article.urlToImage!,
                                      height: screenWidth * 0.5,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        height: screenWidth * 0.5,
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Icon(
                                            Icons.image,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                            height: screenWidth * 0.5,
                                            color: Colors.grey[300],
                                            child: const Center(
                                              child: Icon(
                                                Icons.broken_image,
                                                size: 40,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                    ),

                                  // 🔹 Text content
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          article.title,
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
                                                        color: Colors.grey[700],
                                                      ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                            if (article.source?.name != null &&
                                                formattedDate.isNotEmpty)
                                              const SizedBox(width: 12),
                                            if (formattedDate.isNotEmpty) ...[
                                              Icon(
                                                Icons.calendar_today_outlined,
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
                                                      color: Colors.grey[700],
                                                    ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else if (state is DiscoverError) {
                      return Center(child: Text("Error: ${state.message}"));
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
