import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:news_app/features/Favorites/cubit/favorites_cubit.dart';
import 'package:news_app/features/home/models/top_headlines_response.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleDetailsPage extends StatelessWidget {
  final Article article;
  const ArticleDetailsPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final formattedDate = article.publishedAt != null
        ? DateFormat.yMMMd().format(article.publishedAt!)
        : '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 🔹 App bar with image + gradient
          SliverAppBar(
            pinned: true,
            expandedHeight: 280,
            backgroundColor: Colors.black,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: Colors.white,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                article.source?.name ?? "News",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl:
                        article.urlToImage ??
                        'https://placehold.co/1200x800/png?text=No+Image',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),

                  // 🔹 Favorite button (with BlocBuilder)
                  Positioned(
                    top: kToolbarHeight + 16,
                    right: 16,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: BlocBuilder<FavoritesCubit, FavoritesState>(
                            buildWhen: (previous, current) =>
                                current is FavoritesLoaded ||
                                current is FavoritesError ||
                                current is FavoritesLoading,
                            builder: (context, state) {
                              // Loading spinner
                              if (state is FavoritesLoading) {
                                return const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              }

                              // Error icon
                              if (state is FavoritesError) {
                                return IconButton(
                                  icon: const Icon(
                                    Icons.error,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error: ${state.message}',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  },
                                );
                              }

                              // Default: not loaded yet
                              if (state is! FavoritesLoaded) {
                                return IconButton(
                                  icon: const Icon(
                                    Icons.bookmark_border,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => context
                                      .read<FavoritesCubit>()
                                      .addFavorite(article),
                                );
                              }

                              // Loaded state → check if article is favorite
                              final isFav = state.articles.any(
                                (a) => a.url == article.url,
                              );

                              return IconButton(
                                icon: Icon(
                                  isFav
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  color: isFav
                                      ? Colors.lightBlueAccent
                                      : Colors.white,
                                ),
                                onPressed: () {
                                  final cubit = context.read<FavoritesCubit>();
                                  isFav
                                      ? cubit.removeFavorite(article)
                                      : cubit.addFavorite(article);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🔹 Content
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(color: Colors.white),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      article.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                    ),
                    const SizedBox(height: 10),

                    // Source + Date row
                    Row(
                      children: [
                        if (article.source?.name != null) ...[
                          const Icon(
                            Icons.public,
                            size: 16,
                            color: Colors.lightBlueAccent,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              article.source!.name,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.black54),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        if (article.source?.name != null &&
                            formattedDate.isNotEmpty)
                          const SizedBox(width: 12),
                        if (formattedDate.isNotEmpty) ...[
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: Colors.lightBlueAccent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formattedDate,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.black54),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Description
                    Text(
                      article.description?.isNotEmpty == true
                          ? article.description!
                          : "No description available.",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.black87,
                        height: 1.6,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Content
                    if (article.content != null) ...[
                      Text(
                        article.content!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    const Divider(),

                    // Read More Button
                    if (article.url.isNotEmpty)
                      Center(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 2,
                          ),
                          onPressed: () async {
                            final uri = Uri.parse(article.url);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Could not open the article"),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.open_in_new),
                          label: const Text(
                            "Read Full Article",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
