import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../models/article_model.dart';

abstract class NewsRemoteDataSource {
  Future<List<ArticleModel>> fetchTopHeadlines({required String category});

  Future<List<ArticleModel>> fetchEverything({required String query});
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  NewsRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  void _ensureApiKey() {
    if (ApiEndpoints.newsApiKey.isEmpty) {
      throw Exception(
        'Missing News API key. Run with --dart-define=NEWS_API_KEY=your_key',
      );
    }
  }

  /// Top headlines: `country` + `category` (see NewsAPI — cannot mix with `sources`).
  @override
  Future<List<ArticleModel>> fetchTopHeadlines({required String category}) async {
    _ensureApiKey();
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.topHeadlines,
      queryParameters: <String, dynamic>{
        'country': ApiEndpoints.defaultCountry,
        'category': category,
        'pageSize': ApiEndpoints.defaultPageSize,
        'page': 1,
      },
    );
    return _parseArticles(response.data);
  }

  /// Everything: `q` (query), `pageSize`, `page`, `sortBy`, `language`.
  @override
  Future<List<ArticleModel>> fetchEverything({required String query}) async {
    _ensureApiKey();
    final q = query.trim();
    if (q.isEmpty) {
      return [];
    }
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.everything,
      queryParameters: <String, dynamic>{
        'q': q,
        'pageSize': ApiEndpoints.defaultPageSize,
        'page': 1,
        'sortBy': 'publishedAt',
        'language': 'en',
      },
    );
    return _parseArticles(response.data);
  }

  List<ArticleModel> _parseArticles(Map<String, dynamic>? data) {
    if (data == null) {
      return [];
    }
    final status = data['status'] as String?;
    if (status == 'error') {
      final msg = data['message'] as String? ?? 'Unknown API error';
      throw Exception(msg);
    }
    final raw = data['articles'];
    if (raw is! List<dynamic>) {
      return [];
    }
    return raw
        .whereType<Map<String, dynamic>>()
        .map(ArticleModel.fromJson)
        .toList();
  }
}
