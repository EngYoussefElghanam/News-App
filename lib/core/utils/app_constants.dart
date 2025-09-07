import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static const appName = 'App Name';
  static final String apiKey = dotenv.env['API_KEY'] ?? '';
  static final String baseUrl = 'https://newsapi.org';
  static final String topHeadlines = '/v2/top-headlines';
  static final String everyThing = '/v2/everything';
}
