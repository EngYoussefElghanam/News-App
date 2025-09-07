import 'package:dio/dio.dart';
import 'package:news_app/core/utils/app_constants.dart';
import 'package:news_app/features/home/models/top_headlines_body.dart';
import 'package:news_app/features/home/models/top_headlines_response.dart';

class HomeServices {
  final dio = Dio()..options.baseUrl = AppConstants.baseUrl;

  Future<TopHeadlinesResponse> getTopHeadlines(TopHeadlinesBody body) async {
    try {
      final query = body.toMap()..['apiKey'] = AppConstants.apiKey;

      final response = await dio.get(
        AppConstants.topHeadlines,
        queryParameters: query,
      );

      if (response.statusCode == 200) {
        return TopHeadlinesResponse.fromMap(response.data);
      } else {
        throw Exception(response.statusMessage);
      }
    } catch (e) {
      rethrow;
    }
  }
}
