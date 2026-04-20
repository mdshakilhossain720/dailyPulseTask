import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_button.dart';
import '../bloc/news_bloc.dart';
import '../bloc/news_event.dart';
import '../bloc/news_state.dart';
import '../widgets/article_card.dart';
import '../widgets/category_chips.dart';
import '../widgets/news_shimmer_list.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'DailyPulse',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search headlines…',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        tooltip: 'Clear',
                        onPressed: () {
                          _searchController.clear();
                          context.read<NewsBloc>().add(const NewsSearchCleared());
                        },
                        icon: const Icon(Icons.clear),
                      ),
                    ),
                    onSubmitted: (value) {
                      FocusScope.of(context).unfocus();
                      context.read<NewsBloc>().add(NewsSearchSubmitted(value));
                    },
                  ),
                  BlocBuilder<NewsBloc, NewsState>(
                    buildWhen: (a, b) =>
                        a.searchValidationMessage != b.searchValidationMessage,
                    builder: (context, state) {
                      final msg = state.searchValidationMessage;
                      if (msg == null || msg.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          msg,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            BlocBuilder<NewsBloc, NewsState>(
              buildWhen: (a, b) => a.category != b.category,
              builder: (context, state) {
                return CategoryChips(
                  selectedCategory: state.category,
                  onSelected: (cat) {
                    _searchController.clear();
                    context.read<NewsBloc>().add(NewsCategorySelected(cat));
                  },
                );
              },
            ),
            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<NewsBloc, NewsState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const NewsShimmerList();
                  }
                  if (state.hasError) {
                    return _ErrorBody(
                      message: state.errorMessage ?? 'Unknown error',
                      onRetry: () => context.read<NewsBloc>().add(
                            const NewsRefreshed(),
                          ),
                    );
                  }
                  if (state.isEmptySuccess) {
                    return _EmptyBody(
                      searchActive: state.searchQuery.isNotEmpty,
                      onReset: () {
                        _searchController.clear();
                        context.read<NewsBloc>().add(const NewsSearchCleared());
                      },
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<NewsBloc>().add(const NewsRefreshed());
                      await context.read<NewsBloc>().stream.firstWhere(
                            (s) => !s.isLoading,
                          );
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: state.articles.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final article = state.articles[index];
                        return ArticleCard(
                          article: article,
                          onTap: () => context.push(
                            AppRoutes.article,
                            extra: article,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            AppPrimaryButton(
              label: 'Try again',
              icon: Icons.refresh,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({
    required this.searchActive,
    required this.onReset,
  });

  final bool searchActive;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              searchActive ? Icons.search_off : Icons.article_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              searchActive
                  ? 'No articles match your search.'
                  : 'No headlines right now.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (searchActive) ...[
              const SizedBox(height: 16),
              AppOutlinedButton(
                label: 'Clear search',
                onPressed: onReset,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
