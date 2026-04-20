import 'package:equatable/equatable.dart';

sealed class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object?> get props => [];
}

/// Initial / default load for current category.
final class NewsHeadlinesRequested extends NewsEvent {
  const NewsHeadlinesRequested();
}

final class NewsCategorySelected extends NewsEvent {
  const NewsCategorySelected(this.category);
  final String category;

  @override
  List<Object?> get props => [category];
}

final class NewsSearchSubmitted extends NewsEvent {
  const NewsSearchSubmitted(this.rawQuery);
  final String rawQuery;

  @override
  List<Object?> get props => [rawQuery];
}

final class NewsSearchCleared extends NewsEvent {
  const NewsSearchCleared();
}

final class NewsRefreshed extends NewsEvent {
  const NewsRefreshed();
}
