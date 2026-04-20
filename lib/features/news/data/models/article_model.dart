import '../../domain/entities/article.dart';


class ArticleModel {
  const ArticleModel({
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.publishedAt,
    required this.author,
    required this.content,
    required this.sourceName,
  });

  final String title;
  final String description;
  final String url;
  final String? urlToImage;
  final DateTime? publishedAt;
  final String? author;
  final String? content;
  final String sourceName;

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    final source = json['source'];
    var name = 'Unknown';
    if (source is Map<String, dynamic> && source['name'] is String) {
      name = source['name'] as String;
    }
    DateTime? published;
    final raw = json['publishedAt'];
    if (raw is String) {
      published = DateTime.tryParse(raw);
    }
    return ArticleModel(
      title: json['title'] as String? ?? 'Untitled',
      description: json['description'] as String? ?? '',
      url: json['url'] as String? ?? '',
      urlToImage: json['urlToImage'] as String?,
      publishedAt: published,
      author: json['author'] as String?,
      content: json['content'] as String?,
      sourceName: name,
    );
  }

  Article toEntity() {
    return Article(
      title: title,
      description: description,
      url: url,
      urlToImage: urlToImage,
      publishedAt: publishedAt,
      author: author,
      content: content,
      sourceName: sourceName,
    );
  }
}
