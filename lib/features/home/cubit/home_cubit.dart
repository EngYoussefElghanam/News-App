import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/features/home/models/top_headlines_body.dart';
import 'package:news_app/features/home/models/top_headlines_response.dart';
import 'package:news_app/features/home/services/home_services.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  // 🔹 For Top Headlines (carousel, one-time fetch)
  Future<void> fetchTopHeadlines() async {
    emit(TopHeadlinesLoading());
    try {
      final body = TopHeadlinesBody(
        category: 'business',
        country: 'us',
        page: 1,
        pageSize: 10,
      );
      final response = await HomeServices().getTopHeadlines(body);
      emit(TopHeadlinesLoaded(response.articles));
    } catch (e) {
      emit(TopHeadlinesError(e.toString()));
    }
  }

  // 🔹 For Recommended News (infinite scroll / pagination)
  int _currentPage = 1;
  bool _isFetching = false;
  bool _hasMore = true;
  final List<Article> _recommendedArticles = [];

  bool get hasMore => _hasMore;

  Future<void> fetchRecommendedNews({bool refresh = false}) async {
    if (_isFetching) return;
    _isFetching = true;

    if (refresh) {
      _currentPage = 1;
      _recommendedArticles.clear();
      _hasMore = true;
      emit(RecommendedNewsLoading());
    }

    try {
      final body = TopHeadlinesBody(
        country: 'us',
        page: _currentPage,
        pageSize: 15,
      );

      final response = await HomeServices().getTopHeadlines(body);

      if (response.articles.isEmpty) {
        _hasMore = false;
      } else {
        _recommendedArticles.addAll(response.articles);
        _currentPage++;
      }

      emit(RecommendedNewsLoaded(List<Article>.from(_recommendedArticles)));
    } catch (e) {
      emit(RecommendedNewsError(e.toString()));
    } finally {
      _isFetching = false;
    }
  }

  Future<void> searchNews(String query) async {
    if (query.isEmpty) return;

    emit(SearchNewsLoading());
    try {
      final body = TopHeadlinesBody(q: query, page: 1, pageSize: 20);

      final response = await HomeServices().getTopHeadlines(body);

      emit(SearchNewsLoaded(response.articles));
    } catch (e) {
      emit(SearchNewsError(e.toString()));
    }
  }
}
