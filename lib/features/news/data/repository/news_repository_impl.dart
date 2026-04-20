import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/article.dart';
import '../../domain/repository/news_repository.dart';
import '../datasource/news_local_datasource.dart';
import '../datasource/news_remote_datasource.dart';

class NewsRepositoryImpl implements NewsRepository {
  NewsRepositoryImpl({
    required NewsRemoteDataSource remoteDataSource,
    required NewsLocalDataSource localDataSource,
  })  : _remote = remoteDataSource,
        _local = localDataSource;

  final NewsRemoteDataSource _remote;
  final NewsLocalDataSource _local;

  @override
  Future<Result<List<Article>>> getTopHeadlines(String category) async {
    try {
      final models = await _remote.fetchTopHeadlines(category: category);
      await _local.cacheHeadlines(category: category, articles: models);
      return Success(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      final cached = await _local.getCachedHeadlines(category);
      if (cached != null && cached.isNotEmpty) {
        return Success(cached.map((m) => m.toEntity()).toList());
      }
      return Failure(_mapError(e));
    }
  }

  @override
  Future<Result<List<Article>>> searchNews(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      return const Success([]);
    }
    try {
      final models = await _remote.fetchEverything(query: q);
      await _local.cacheSearchResults(query: q, articles: models);
      return Success(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      final cached = await _local.getCachedSearchResults(q);
      if (cached != null && cached.isNotEmpty) {
        return Success(cached.map((m) => m.toEntity()).toList());
      }
      return Failure(_mapError(e));
    }
  }

  String _mapError(Object error) {
    if (error is DioException) {
      return ApiException.message(error);
    }
    return error.toString().replaceFirst('Exception: ', '');
  }
}
