import 'package:dio/dio.dart';
import 'package:news_app/core/utils/app_constants.dart';
import 'package:news_app/features/home/models/top_headlines_response.dart';
import 'package:news_app/models/everything_body.dart';

class DiscoverServices {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl, // ✅ make sure you have this in constants
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<TopHeadlinesResponse> fetchDiscoverArticles(
    EverythingBody body,
  ) async {
    try {
      final query = body.toMap()..['apiKey'] = AppConstants.apiKey;

      final response = await _dio.get(
        AppConstants
            .everyThing, // should be relative path, e.g. "/v2/everything"
        queryParameters: query,
      );

      if (response.statusCode == 200 && response.data != null) {
        return TopHeadlinesResponse.fromMap(response.data);
      } else {
        throw Exception("Failed: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      // ✅ better error messages
      throw Exception(
        "Dio error: ${e.message} | Response: ${e.response?.data}",
      );
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }
}
