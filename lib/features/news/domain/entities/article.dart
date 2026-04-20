import 'package:equatable/equatable.dart';

/// Domain entity — independent of JSON / API details.
class Article extends Equatable {
  const Article({
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

  @override
  List<Object?> get props => [
        title,
        description,
        url,
        urlToImage,
        publishedAt,
        author,
        content,
        sourceName,
      ];
}
