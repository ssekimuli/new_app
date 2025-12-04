class Articles {
  int id;
  String title;
  // "source": {
  // "id": null,
  // "name": "BBC News"
  // },
  String author;
  String description;
  String url;
  String urlToImage;
  String publishedAt;
  String content;

  String category;

  String source;
  Articles({
    required this.id,
    required this.title,
    required this.author,
    required this.content,
    required this.description,
    required this.publishedAt,
    required this.url,
    required this.urlToImage,
    this.category = 'general',
    required this.source,

  });

  factory Articles.fromJson(Map<String, dynamic> json) {
    return Articles(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      author: json['author'] ?? 'Unknown',
      content: json['content'] ?? '',
      description: json['description'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'] ?? '',
      category: json['category'] ?? 'general',
      source: json['source']['name'] ?? 'Unknown',
    );
  }



}
