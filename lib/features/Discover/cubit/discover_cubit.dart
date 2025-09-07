import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/features/Discover/services/discover_services.dart';
import 'package:news_app/features/home/models/top_headlines_response.dart';
import 'package:news_app/models/everything_body.dart';

part 'discover_state.dart';

class DiscoverCubit extends Cubit<DiscoverState> {
  DiscoverCubit() : super(DiscoverInitial());

  // 🔹 Pagination helpers
  int _currentPage = 1;
  bool _isFetching = false;
  bool _hasMore = true;
  final List<Article> _articles = [];
  String? _currentQuery;

  bool get hasMore => _hasMore;
  String? get currentQuery => _currentQuery;

  // 🔹 Initial fetch (Discover tab)
  Future<void> fetchDiscoverArticles({bool refresh = false}) async {
    if (_isFetching) return;
    _isFetching = true;

    if (refresh) {
      _currentPage = 1;
      _articles.clear();
      _hasMore = true;
      _currentQuery = null;
      emit(DiscoverLoading());
    }

    try {
      final body = EverythingBody(page: _currentPage, pageSize: 20);
      final response = await DiscoverServices().fetchDiscoverArticles(body);

      if (response.articles.isEmpty) {
        _hasMore = false;
      } else {
        _articles.addAll(response.articles);
        _currentPage++;
      }

      emit(DiscoverLoaded(List<Article>.from(_articles)));
    } catch (e) {
      emit(DiscoverError(e.toString()));
    } finally {
      _isFetching = false;
    }
  }

  // 🔹 Search with pagination
  Future<void> searchArticles(String query, {bool refresh = false}) async {
    if (_isFetching) return;
    _isFetching = true;

    if (refresh || _currentQuery != query) {
      _currentPage = 1;
      _articles.clear();
      _hasMore = true;
      _currentQuery = query;
      emit(DiscoverLoading());
    }

    try {
      final body = EverythingBody(q: query, page: _currentPage, pageSize: 20);
      final response = await DiscoverServices().fetchDiscoverArticles(body);

      if (response.articles.isEmpty) {
        _hasMore = false;
      } else {
        _articles.addAll(response.articles);
        _currentPage++;
      }

      emit(DiscoverLoaded(List<Article>.from(_articles)));
    } catch (e) {
      emit(DiscoverError(e.toString()));
    } finally {
      _isFetching = false;
    }
  }
}
