import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:news_app/core/utils/Route/app_routes.dart';
import 'package:news_app/features/Favorites/cubit/favorites_cubit.dart';
import 'package:news_app/features/home/models/top_headlines_response.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorites"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FavoritesError) {
            return Center(
              child: Text(
                "Error: ${state.message}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (state is FavoritesLoaded) {
            final articles = state.articles;

            if (articles.isEmpty) {
              return const Center(
                child: Text(
                  "No favorites yet",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return ListView.separated(
              itemCount: articles.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final Article article = articles[index];
                final formattedDate = article.publishedAt != null
                    ? DateFormat.yMMMd().format(article.publishedAt!)
                    : '';

                return ListTile(
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.detailsPage,
                    arguments: article,
                  ),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl:
                          article.urlToImage ??
                          "https://placehold.co/120x80/png?text=No+Image",
                      width: 80,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    "${article.source?.name ?? 'Unknown'}  •  $formattedDate",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      context.read<FavoritesCubit>().removeFavorite(article);
                    },
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
