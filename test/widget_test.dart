import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:dailypulse/core/router/app_router.dart';
import 'package:dailypulse/core/storage/hive_boxes.dart';
import 'package:dailypulse/core/theme/app_theme.dart';
import 'package:dailypulse/features/news/data/datasource/news_local_datasource.dart';
import 'package:dailypulse/features/news/data/datasource/news_remote_datasource.dart';
import 'package:dailypulse/features/news/data/repository/news_repository_impl.dart';
import 'package:dailypulse/features/news/domain/usecases/get_news_usecase.dart';
import 'package:dailypulse/features/news/presentation/bloc/news_bloc.dart';
import 'package:dailypulse/features/news/presentation/bloc/news_event.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('dailypulse_hive_');
    Hive.init(tempDir.path);
    await Hive.openBox<String>(HiveBoxes.newsCache);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  testWidgets('DailyPulse shows title', (WidgetTester tester) async {
    final dio = Dio();
    final remote = NewsRemoteDataSourceImpl(dio: dio);
    final local = NewsLocalDataSourceImpl(box: Hive.box<String>(HiveBoxes.newsCache));
    final repository = NewsRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
    );
    final getTopHeadlines = GetTopHeadlinesUseCase(repository);
    final searchNews = SearchNewsUseCase(repository);
    final router = createAppRouter();

    await tester.pumpWidget(
      BlocProvider(
        create: (_) => NewsBloc(
          getTopHeadlines: getTopHeadlines,
          searchNews: searchNews,
        )..add(const NewsHeadlinesRequested()),
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: router,
        ),
      ),
    );

    await tester.pump();
    expect(find.text('DailyPulse'), findsOneWidget);
  });
}
