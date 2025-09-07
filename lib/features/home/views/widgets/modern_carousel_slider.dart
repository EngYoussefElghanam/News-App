import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:news_app/core/utils/Route/app_routes.dart';
import 'package:news_app/features/Favorites/cubit/favorites_cubit.dart';
import 'package:news_app/features/home/models/top_headlines_response.dart';

class ModernCarousel extends StatefulWidget {
  final List<Article> articles;
  const ModernCarousel({super.key, required this.articles});

  @override
  State<ModernCarousel> createState() => _ModernCarouselState();
}

class _ModernCarouselState extends State<ModernCarousel> {
  @override
  void initState() {
    super.initState();
  }

  final CarouselSliderController _controller = CarouselSliderController();
  int _current = 0;

  List<Widget> buildSlides(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final radius = width * 0.05; // responsive corner radius
    final titleFont = width * 0.045; // ~18px on phone
    final subtitleFont = width * 0.035; // ~14px on phone
    final dateFont = width * 0.032; // ~13px on phone
    final padding = width * 0.04;

    return widget.articles.map((item) {
      final formattedDate = item.publishedAt != null
          ? DateFormat.yMMMd().format(item.publishedAt!)
          : '';

      return InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.detailsPage,
          arguments: item,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 🔹 Background image
              CachedNetworkImage(
                imageUrl:
                    (item.urlToImage != null && item.urlToImage!.isNotEmpty)
                    ? item.urlToImage!
                    : 'https://via.placeholder.com/800x400.png?text=No+Image',
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                    const Center(child: Icon(Icons.broken_image, size: 50)),
              ),

              // 🔹 Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),

              // 🔹 Favorite button (top-right)
              Positioned(
                top: padding,
                right: padding,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    child: BlocBuilder<FavoritesCubit, FavoritesState>(
                      buildWhen: (previous, current) =>
                          current is FavoritesLoaded ||
                          current is FavoritesError ||
                          current is FavoritesLoading,
                      builder: (context, state) {
                        // 🔹 Show loading spinner
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

                        // 🔹 Show error icon
                        if (state is FavoritesError) {
                          return IconButton(
                            icon: const Icon(Icons.error, color: Colors.red),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${state.message}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            },
                          );
                        }

                        // 🔹 Default case (when not loaded yet) → let user add to favorites
                        if (state is! FavoritesLoaded) {
                          return IconButton(
                            icon: const Icon(
                              Icons.bookmark_border,
                              color: Colors.white,
                            ),
                            onPressed: () => context
                                .read<FavoritesCubit>()
                                .addFavorite(item),
                          );
                        }

                        // 🔹 Loaded state → check if current item is favorite
                        final isFav = state.articles.any(
                          (a) => a.url == item.url,
                        );

                        return IconButton(
                          icon: Icon(
                            isFav ? Icons.bookmark : Icons.bookmark_border,
                            color: isFav
                                ? Colors.lightBlueAccent
                                : Colors.white,
                          ),
                          onPressed: () {
                            final cubit = context.read<FavoritesCubit>();
                            isFav
                                ? cubit.removeFavorite(item)
                                : cubit.addFavorite(item);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),

              // 🔹 Text content
              Positioned(
                left: padding,
                right: padding,
                bottom: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: titleFont,
                        fontWeight: FontWeight.bold,
                        shadows: const [
                          Shadow(
                            blurRadius: 6,
                            color: Colors.black54,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: padding * 0.3),

                    // Source + Date
                    Row(
                      children: [
                        if (item.source?.name != null) ...[
                          Icon(
                            Icons.verified,
                            size: subtitleFont * 1.2,
                            color: Colors.blueAccent,
                          ),
                          SizedBox(width: padding * 0.2),
                          Flexible(
                            child: Text(
                              item.source!.name,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: subtitleFont,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        if (item.source?.name != null &&
                            formattedDate.isNotEmpty)
                          SizedBox(width: padding * 0.7),
                        if (formattedDate.isNotEmpty) ...[
                          Icon(
                            Icons.calendar_today_outlined,
                            size: dateFont * 1.3,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          SizedBox(width: padding * 0.2),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: dateFont,
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
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        CarouselSlider(
          items: buildSlides(context),
          carouselController: _controller,
          options: CarouselOptions(
            autoPlay: true,
            enlargeCenterPage: true,
            aspectRatio: width > 600 ? 16 / 7 : 16 / 9,
            viewportFraction: 0.85,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
        ),
        SizedBox(height: width * 0.02),

        // 🔹 Responsive indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.articles.asMap().entries.map((entry) {
            bool isActive = _current == entry.key;
            return GestureDetector(
              onTap: () => _controller.animateToPage(entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isActive ? width * 0.05 : width * 0.03,
                height: width * 0.03,
                margin: EdgeInsets.symmetric(
                  vertical: width * 0.015,
                  horizontal: width * 0.01,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(width * 0.02),
                  color: isActive
                      ? Colors.lightBlueAccent
                      : Colors.grey.withOpacity(0.4),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: Colors.lightBlueAccent.withOpacity(0.5),
                            blurRadius: width * 0.02,
                            spreadRadius: 1,
                          ),
                        ]
                      : [],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
