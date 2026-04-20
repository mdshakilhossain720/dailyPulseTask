/// Input validation for search and other user-driven queries.
abstract final class SearchValidators {
  SearchValidators._();

  static const int minQueryLength = 2;
  static const int maxQueryLength = 200;

  static String normalize(String raw) => raw.trim();

  /// Returns `null` if valid, otherwise a user-facing error string.
  static String? validateSearchQuery(String raw) {
    final q = normalize(raw);
    if (q.isEmpty) {
      return null;
    }
    if (q.length < minQueryLength) {
      return 'Enter at least $minQueryLength characters to search.';
    }
    if (q.length > maxQueryLength) {
      return 'Search is too long (max $maxQueryLength characters).';
    }
    return null;
  }

  static bool isEffectivelyEmpty(String raw) => normalize(raw).isEmpty;
}
