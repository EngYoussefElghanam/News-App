import 'package:hive/hive.dart';
part 'top_headlines_response.g.dart';

class TopHeadlinesResponse {
  final String status;
  final int totalResults;
  final List<Article> articles;

  TopHeadlinesResponse({
    required this.status,
    required this.totalResults,
    required this.articles,
  });

  factory TopHeadlinesResponse.fromMap(Map<String, dynamic> map) {
    return TopHeadlinesResponse(
      status: map['status'] as String,
      totalResults: map['totalResults'] as int,
      articles: map['articles'] != null
          ? List<Article>.from(
              (map['articles'] as List).map(
                (x) => Article.fromMap(x as Map<String, dynamic>),
              ),
            )
          : [],
    );
  }
}

@HiveType(typeId: 0)
class Article {
  @HiveField(0)
  final Source? source;
  @HiveField(1)
  final String? author;
  @HiveField(2)
  final String title;
  @HiveField(3)
  final String? description;
  @HiveField(4)
  final String url;
  @HiveField(5)
  final String? urlToImage;
  @HiveField(6)
  final DateTime? publishedAt;
  @HiveField(7)
  final String? content;

  Article({
    this.source,
    this.author,
    required this.title,
    this.description,
    required this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
  });

  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      source: map['source'] != null
          ? Source.fromMap(map['source'] as Map<String, dynamic>)
          : null,
      author: map['author'] as String?,
      title: map['title'] as String,
      description: map['description'] as String?,
      url: map['url'] as String,
      urlToImage: map['urlToImage'] as String?,
      publishedAt: map['publishedAt'] != null
          ? DateTime.parse(map['publishedAt'] as String) // ✅ FIXED
          : null,
      content: map['content'] as String?,
    );
  }
}

@HiveType(typeId: 1)
class Source {
  @HiveField(0)
  final String? id;
  @HiveField(1)
  final String name;

  Source({this.id, required this.name});

  factory Source.fromMap(Map<String, dynamic> map) {
    return Source(id: map['id'] as String?, name: map['name'] as String);
  }
}
