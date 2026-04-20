import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/article.dart';

class ArticleDetailScreen extends StatelessWidget {
  const ArticleDetailScreen({super.key, required this.article});

  final Article article;

  Future<void> _openInBrowser() async {
    final uri = Uri.tryParse(article.url);
    if (uri == null) {
      return;
    }
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = article.publishedAt != null
        ? DateFormat.yMMMMEEEEd()
            .add_jm()
            .format(article.publishedAt!.toLocal())
        : null;

    final bodyText = _bodyCopy(article);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                article.sourceName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
                ),
              ),
              background: _HeroImage(url: article.urlToImage),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  article.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Chip(
                      avatar: const Icon(Icons.source_outlined, size: 18),
                      label: Text(article.sourceName),
                    ),
                    if (article.author != null && article.author!.isNotEmpty)
                      Chip(
                        avatar: const Icon(Icons.person_outline, size: 18),
                        label: Text(
                          article.author!,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (dateStr != null)
                      Text(
                        dateStr,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                if (article.description.isNotEmpty)
                  Text(
                    article.description,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                if (article.description.isNotEmpty) const SizedBox(height: 16),
                Text(
                  bodyText,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: article.url.isEmpty ? null : _openInBrowser,
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('Open in browser'),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _bodyCopy(Article a) {
    final content = a.content;
    if (content != null && content.isNotEmpty) {
      return content;
    }
    if (a.description.isNotEmpty) {
      return a.description;
    }
    return 'No article text is available from the source. Use Open in browser to read the full story.';
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: url!,
          fit: BoxFit.cover,
          placeholder: (_, _) => Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          errorWidget: (_, _, _) => Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.broken_image_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black38,
                Colors.transparent,
                Colors.black54,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
