import '../../../../core/utils/result.dart';
import '../entities/article.dart';

/// News data contract — implemented in the data layer.
abstract class NewsRepository {
  Future<Result<List<Article>>> getTopHeadlines(String category);

  Future<Result<List<Article>>> searchNews(String query);
}
