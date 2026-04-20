import 'package:flutter/material.dart';

/// Display label → NewsAPI `category` query value.
const Map<String, String> kNewsCategories = <String, String>{
  'General': 'general',
  'Business': 'business',
  'Tech': 'technology',
  'Entertainment': 'entertainment',
  'Sports': 'sports',
  'Science': 'science',
  'Health': 'health',
};

class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  final String selectedCategory;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final entries = kNewsCategories.entries.toList();

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: entries.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = entries[index].key;
          final value = entries[index].value;
          final selected = selectedCategory == value;
          return FilterChip(
            label: Text(label),
            selected: selected,
            onSelected: (_) => onSelected(value),
            showCheckmark: false,
          );
        },
      ),
    );
  }
}
