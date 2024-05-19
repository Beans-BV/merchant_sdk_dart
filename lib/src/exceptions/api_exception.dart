import 'package:http/http.dart';

class ApiException implements Exception {
  const ApiException(
    this.statusCode,
    this.response,
    this.message,
  );

  final int statusCode;
  final Response response;
  final String message;

  @override
  String toString() {
    return 'ApiException: $message (Status code: $statusCode, Response body: ${response.body})';
  }
}
