import 'package:dio/dio.dart';

/// Maps [DioException] to user-facing messages.
abstract final class ApiException {
  static String message(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return 'Network error. Check your connection and try again.';
        case DioExceptionType.badResponse:
          final code = error.response?.statusCode;
          final data = error.response?.data;
          if (data is Map && data['message'] is String) {
            return data['message'] as String;
          }
          return 'Server error${code != null ? ' ($code)' : ''}. Try again later.';
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        case DioExceptionType.badCertificate:
          return 'Secure connection could not be verified.';
        case DioExceptionType.unknown:
          return error.message ?? 'Something went wrong. Please try again.';
      }
    }
    return error.toString();
  }
}
