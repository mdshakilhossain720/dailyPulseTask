import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_endpoints.dart';


final class _NewsApiKeyInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final key = ApiEndpoints.newsApiKey;
    if (key.isNotEmpty) {
      options.headers[ApiEndpoints.xApiKeyHeader] = key;
    }
    handler.next(options);
  }
}


abstract final class DioClient {
  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: ApiEndpoints.defaultHeaders(),
      ),
    );

    dio.interceptors.add(_NewsApiKeyInterceptor());

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestHeader: false,
          requestBody: false,
          responseBody: true,
          error: true,
          logPrint: (o) => debugPrint(o.toString()),
        ),
      );
    }

    return dio;
  }
}
