import '../../../../core/utils/result.dart';
import '../entities/article.dart';
import '../repository/news_repository.dart';

/// Loads top headlines for a NewsAPI category (e.g. `business`, `general`).
class GetTopHeadlinesUseCase {
  const GetTopHeadlinesUseCase(this._repository);

  final NewsRepository _repository;

  Future<Result<List<Article>>> call(String category) {
    return _repository.getTopHeadlines(category);
  }
}

/// Full-text search via NewsAPI `/everything`.
class SearchNewsUseCase {
  const SearchNewsUseCase(this._repository);

  final NewsRepository _repository;

  Future<Result<List<Article>>> call(String query) {
    return _repository.searchNews(query);
  }
}
