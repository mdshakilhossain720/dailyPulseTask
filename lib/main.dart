import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/network/dio_client.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/news/data/datasource/news_remote_datasource.dart';
import 'features/news/data/repository/news_repository_impl.dart';
import 'features/news/domain/repository/news_repository.dart';
import 'features/news/domain/usecases/get_news_usecase.dart';
import 'features/news/presentation/bloc/news_bloc.dart';
import 'features/news/presentation/bloc/news_event.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final dio = DioClient.create();
  final NewsRemoteDataSource remote = NewsRemoteDataSourceImpl(dio: dio);
  final NewsRepository repository = NewsRepositoryImpl(remoteDataSource: remote);
  final getTopHeadlines = GetTopHeadlinesUseCase(repository);
  final searchNews = SearchNewsUseCase(repository);
  final router = createAppRouter();

  runApp(
    DailyPulseApp(
      router: router,
      getTopHeadlines: getTopHeadlines,
      searchNews: searchNews,
    ),
  );
}

class DailyPulseApp extends StatelessWidget {
  const DailyPulseApp({
    super.key,
    required this.router,
    required this.getTopHeadlines,
    required this.searchNews,
  });

  final GoRouter router;
  final GetTopHeadlinesUseCase getTopHeadlines;
  final SearchNewsUseCase searchNews;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NewsBloc(
        getTopHeadlines: getTopHeadlines,
        searchNews: searchNews,
      )..add(const NewsHeadlinesRequested()),
      child: MaterialApp.router(
        title: 'DailyPulse',
        theme: AppTheme.light(),
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
