import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/utils/Route/app_routes.dart';
import 'package:news_app/features/Discover/Pages/discover_page.dart';
import 'package:news_app/features/Discover/cubit/discover_cubit.dart';
import 'package:news_app/features/Favorites/pages/favorites_page.dart';
import 'package:news_app/features/home/views/pages/aricle_details_page.dart';
import 'package:news_app/features/home/cubit/home_cubit.dart';
import 'package:news_app/features/home/models/top_headlines_response.dart';
import 'package:news_app/features/home/views/pages/home_page.dart';
import 'package:news_app/features/home/views/pages/notification_page.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return CupertinoPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => HomeCubit()
              ..fetchTopHeadlines()
              ..fetchRecommendedNews(),
            child: const HomePage(),
          ),
          settings: settings,
        );
      case AppRoutes.detailsPage:
        final article = settings.arguments as Article;
        return CupertinoPageRoute(
          builder: (_) => ArticleDetailsPage(article: article),
        );
      case AppRoutes.discoverPage:
        return CupertinoPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => DiscoverCubit()..fetchDiscoverArticles(),
            child: const DiscoverPage(),
          ),
          settings: settings,
        );
      case AppRoutes.notificationPage:
        return CupertinoPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => HomeCubit()..fetchTopHeadlines(),
            child: const NotificationPage(),
          ),
        );
      case AppRoutes.favoritesPage:
        return CupertinoPageRoute(builder: (_) => const FavoritesPage());
      default:
        return CupertinoPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No Route Found in ${settings.name}')),
          ),
          settings: settings,
        );
    }
  }
}
