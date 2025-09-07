import 'package:hive/hive.dart';
import 'package:news_app/features/home/models/top_headlines_response.dart';

abstract class HiveService {
  Future<void> addFavorite(Article article);
  Future<void> removeFavorite(Article article);
  Future<List<Article>> getFavorites();
  Future<bool> isFavorite(Article article);
  Future<void> clearFavorites();
}

class HiveServiceImpl implements HiveService {
  static const String boxName = 'favorites';

  Box<Article> get _box => Hive.box<Article>(boxName);

  @override
  Future<void> addFavorite(Article article) async {
    // Use article.url as the key to avoid duplicates
    await _box.put(article.url, article);
  }

  @override
  Future<void> removeFavorite(Article article) async {
    await _box.delete(article.url);
  }

  @override
  Future<List<Article>> getFavorites() async {
    return _box.values.toList();
  }

  @override
  Future<bool> isFavorite(Article article) async {
    return _box.containsKey(article.url);
  }

  @override
  Future<void> clearFavorites() async {
    await _box.clear();
  }
}
