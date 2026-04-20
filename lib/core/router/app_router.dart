import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/news/domain/entities/article.dart';
import '../../features/news/presentation/screens/article_detail_screen.dart';
import '../../features/news/presentation/screens/news_screen.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const article = '/article';
}

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const NewsScreen(),
      ),
      GoRoute(
        path: AppRoutes.article,
        name: 'article',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! Article) {
            return const Scaffold(
              body: Center(child: Text('Missing article')),
            );
          }
          return ArticleDetailScreen(article: extra);
        },
      ),
    ],
  );
}
