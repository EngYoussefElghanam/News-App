import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/services/hive_service.dart';
import 'package:news_app/features/home/models/top_headlines_response.dart';

part 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit() : super(FavoritesInitial());

  final _hive = HiveServiceImpl();

  Future<void> addFavorite(Article article) async {
    try {
      await _hive.addFavorite(article);
      final favorites = await _hive.getFavorites();
      emit(FavoritesLoaded(articles: favorites));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> removeFavorite(Article article) async {
    try {
      await _hive.removeFavorite(article);
      final favorites = await _hive.getFavorites();
      emit(FavoritesLoaded(articles: favorites));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> clearFavorites() async {
    try {
      await _hive.clearFavorites();
      emit(FavoritesLoaded(articles: []));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> getFavorites() async {
    try {
      final favorites = await _hive.getFavorites();
      emit(FavoritesLoaded(articles: favorites));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<bool> isFavorite(Article article) async {
    try {
      final favorites = await _hive.getFavorites();
      return favorites.any((fav) => fav.url == article.url);
    } catch (_) {
      return false;
    }
  }
}
