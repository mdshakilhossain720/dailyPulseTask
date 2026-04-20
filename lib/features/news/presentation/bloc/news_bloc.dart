import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/article.dart';
import '../../domain/usecases/get_news_usecase.dart';
import 'news_event.dart';
import 'news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  NewsBloc({
    required GetTopHeadlinesUseCase getTopHeadlines,
    required SearchNewsUseCase searchNews,
  })  : _getTopHeadlines = getTopHeadlines,
        _searchNews = searchNews,
        super(const NewsState()) {
    on<NewsHeadlinesRequested>(_onHeadlinesRequested);
    on<NewsCategorySelected>(_onCategorySelected);
    on<NewsSearchSubmitted>(_onSearchSubmitted);
    on<NewsSearchCleared>(_onSearchCleared);
    on<NewsRefreshed>(_onRefreshed);
  }

  final GetTopHeadlinesUseCase _getTopHeadlines;
  final SearchNewsUseCase _searchNews;

  Future<void> _onHeadlinesRequested(
    NewsHeadlinesRequested event,
    Emitter<NewsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: NewsStatus.loading,
        clearError: true,
        clearSearchValidation: true,
      ),
    );
    final result = await _getTopHeadlines(state.category);
    _emitHeadlinesResult(emit, result, searchQuery: '');
  }

  Future<void> _onCategorySelected(
    NewsCategorySelected event,
    Emitter<NewsState> emit,
  ) async {
    emit(
      state.copyWith(
        category: event.category,
        searchQuery: '',
        status: NewsStatus.loading,
        clearError: true,
        clearSearchValidation: true,
      ),
    );
    final result = await _getTopHeadlines(event.category);
    _emitHeadlinesResult(emit, result, searchQuery: '');
  }

  Future<void> _onSearchSubmitted(
    NewsSearchSubmitted event,
    Emitter<NewsState> emit,
  ) async {
    if (SearchValidators.isEffectivelyEmpty(event.rawQuery)) {
      add(const NewsSearchCleared());
      return;
    }

    final validation = SearchValidators.validateSearchQuery(event.rawQuery);
    if (validation != null) {
      emit(
        state.copyWith(
          searchValidationMessage: validation,
          clearError: true,
        ),
      );
      return;
    }

    final q = SearchValidators.normalize(event.rawQuery);
    emit(
      state.copyWith(
        status: NewsStatus.loading,
        searchQuery: q,
        clearError: true,
        clearSearchValidation: true,
      ),
    );
    final result = await _searchNews(q);
    _emitSearchResult(emit, result, q);
  }

  Future<void> _onSearchCleared(
    NewsSearchCleared event,
    Emitter<NewsState> emit,
  ) async {
    emit(
      state.copyWith(
        searchQuery: '',
        clearSearchValidation: true,
        status: NewsStatus.loading,
        clearError: true,
      ),
    );
    final result = await _getTopHeadlines(state.category);
    _emitHeadlinesResult(emit, result, searchQuery: '');
  }

  Future<void> _onRefreshed(
    NewsRefreshed event,
    Emitter<NewsState> emit,
  ) async {
    emit(state.copyWith(status: NewsStatus.loading, clearError: true));
    if (state.searchQuery.isNotEmpty) {
      final result = await _searchNews(state.searchQuery);
      _emitSearchResult(emit, result, state.searchQuery);
    } else {
      final result = await _getTopHeadlines(state.category);
      _emitHeadlinesResult(emit, result, searchQuery: '');
    }
  }

  void _emitHeadlinesResult(
    Emitter<NewsState> emit,
    Result<List<Article>> result, {
    required String searchQuery,
  }) {
    switch (result) {
      case Success(:final data):
        emit(
          state.copyWith(
            status: NewsStatus.success,
            articles: data,
            searchQuery: searchQuery,
          ),
        );
      case Failure(:final message):
        emit(
          state.copyWith(
            status: NewsStatus.failure,
            articles: const [],
            errorMessage: message,
            searchQuery: searchQuery,
          ),
        );
    }
  }

  void _emitSearchResult(
    Emitter<NewsState> emit,
    Result<List<Article>> result,
    String query,
  ) {
    switch (result) {
      case Success(:final data):
        emit(
          state.copyWith(
            status: NewsStatus.success,
            articles: data,
            searchQuery: query,
          ),
        );
      case Failure(:final message):
        emit(
          state.copyWith(
            status: NewsStatus.failure,
            articles: const [],
            errorMessage: message,
            searchQuery: query,
          ),
        );
    }
  }
}
