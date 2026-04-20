import 'package:equatable/equatable.dart';

import '../../domain/entities/article.dart';

enum NewsStatus { initial, loading, success, failure }

class NewsState extends Equatable {
  const NewsState({
    this.status = NewsStatus.initial,
    this.articles = const [],
    this.category = 'general',
    this.searchQuery = '',
    this.errorMessage,
    this.searchValidationMessage,
  });

  final NewsStatus status;
  final List<Article> articles;
  final String category;
  final String searchQuery;
  final String? errorMessage;
  final String? searchValidationMessage;

  bool get isLoading => status == NewsStatus.loading;
  bool get hasError => status == NewsStatus.failure && errorMessage != null;
  bool get isEmptySuccess =>
      status == NewsStatus.success && articles.isEmpty;

  NewsState copyWith({
    NewsStatus? status,
    List<Article>? articles,
    String? category,
    String? searchQuery,
    String? errorMessage,
    String? searchValidationMessage,
    bool clearError = false,
    bool clearSearchValidation = false,
  }) {
    return NewsState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      category: category ?? this.category,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      searchValidationMessage: clearSearchValidation
          ? null
          : (searchValidationMessage ?? this.searchValidationMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        articles,
        category,
        searchQuery,
        errorMessage,
        searchValidationMessage,
      ];
}
