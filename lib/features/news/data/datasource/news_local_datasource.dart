import 'dart:convert';

import 'package:hive/hive.dart';

import '../models/article_model.dart';

/// Persists article lists as JSON for offline reads.
abstract class NewsLocalDataSource {
  Future<void> cacheHeadlines({
    required String category,
    required List<ArticleModel> articles,
  });

  Future<List<ArticleModel>?> getCachedHeadlines(String category);

  Future<void> cacheSearchResults({
    required String query,
    required List<ArticleModel> articles,
  });

  Future<List<ArticleModel>?> getCachedSearchResults(String query);
}

class NewsLocalDataSourceImpl implements NewsLocalDataSource {
  NewsLocalDataSourceImpl({required Box<String> box}) : _box = box;

  final Box<String> _box;

  static String _headlinesKey(String category) => 'headlines_${category.trim()}';

  static String _searchKey(String query) {
    final q = query.trim().toLowerCase();
    return 'search_$q';
  }

  @override
  Future<void> cacheHeadlines({
    required String category,
    required List<ArticleModel> articles,
  }) async {
    final payload = jsonEncode(articles.map((e) => e.toJson()).toList());
    await _box.put(_headlinesKey(category), payload);
  }

  @override
  Future<List<ArticleModel>?> getCachedHeadlines(String category) async {
    final raw = _box.get(_headlinesKey(category));
    return _decodeList(raw);
  }

  @override
  Future<void> cacheSearchResults({
    required String query,
    required List<ArticleModel> articles,
  }) async {
    final payload = jsonEncode(articles.map((e) => e.toJson()).toList());
    await _box.put(_searchKey(query), payload);
  }

  @override
  Future<List<ArticleModel>?> getCachedSearchResults(String query) async {
    final raw = _box.get(_searchKey(query));
    return _decodeList(raw);
  }

  List<ArticleModel>? _decodeList(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) {
        return null;
      }
      return decoded
          .map((e) => ArticleModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on FormatException {
      return null;
    }
  }
}
