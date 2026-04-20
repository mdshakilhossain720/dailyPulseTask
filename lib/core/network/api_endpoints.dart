
abstract final class ApiEndpoints {
  static const String baseUrl = 'https://newsapi.org/v2';

  static const String topHeadlines = '/top-headlines';
  static const String everything = '/everything';

 
  static const String defaultCountry = 'us';

  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  
  static const String newsApiKey = String.fromEnvironment(
    'NEWS_API_KEY',
    defaultValue: '',
  );

  static const String xApiKeyHeader = 'X-Api-Key';

  static Map<String, dynamic> defaultHeaders() => <String, dynamic>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
}
