import '../../../../core/utils/result.dart';
import '../entities/article.dart';


abstract class NewsRepository {
  Future<Result<List<Article>>> getTopHeadlines(String category);

  Future<Result<List<Article>>> searchNews(String query);
}
