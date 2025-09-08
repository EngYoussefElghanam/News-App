import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:news_app/core/utils/Route/app_router.dart';
import 'package:news_app/core/utils/Route/app_routes.dart';
import 'package:news_app/core/utils/Theme/app_theme.dart';
import 'package:news_app/core/utils/app_constants.dart';
import 'package:news_app/features/Favorites/cubit/favorites_cubit.dart';
import 'package:news_app/features/home/models/top_headlines_response.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  Hive.registerAdapter(ArticleAdapter());
  Hive.registerAdapter(SourceAdapter());
  await Hive.openBox<Article>('favorites');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FavoritesCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppConstants.appName,
        theme: AppTheme.mainTheme,
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: AppRoutes.home,
      ),
    );
  }
}
