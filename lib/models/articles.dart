import 'package:hive/hive.dart';

part 'articles.g.dart';

@HiveType(typeId: 0)
class Article {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String? description;

  @HiveField(2)
  final String? url;

  @HiveField(3)
  final String? urlToImage;

  @HiveField(4)
  final DateTime? publishedAt;

  @HiveField(5)
  final String? content;

  @HiveField(6)
  final String? author;

  @HiveField(7)
  final String? sourceName;

  @HiveField(8)
  final String category; // Store category for filtering

  Article({
    required this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
    this.author,
    this.sourceName,
    required this.category,
  });

  factory Article.fromJson(Map<String, dynamic> json, String category) {
    return Article(
      title: json['title'] ?? 'No Title',
      description: json['description'],
      url: json['url'],
      urlToImage: json['urlToImage'],
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'])
          : null,
      content: json['content'],
      author: json['author'],
      sourceName: json['source'] != null
          ? (json['source'] is Map
                ? json['source']['name']
                : json['source'].toString())
          : null,
      category: category,
    );
  }

  get source => null;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt?.toIso8601String(),
      'content': content,
      'author': author,
      'source': {'name': sourceName},
      'category': category,
    };
  }
}
