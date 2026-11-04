import 'package:dio/dio.dart';
import 'package:e_demand/utils/curlLoggerInterceptor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('credentials and customer details are redacted from debug requests', () {
    final output = CurlLoggerInterceptor.formatRequest(
      RequestOptions(
        path: 'https://example.test/api?token=query-secret&limit=10',
        method: 'POST',
        headers: {
          'Authorization': 'Bearer session-secret',
          'Cookie': 'cookie-secret',
        },
        data: FormData.fromMap({
          'password': 'password-secret',
          'otp': '654321',
          'email': 'private@example.test',
          'phone': 'private-phone',
          'limit': 10,
        }),
      ),
    );
    for (final secret in [
      'query-secret',
      'session-secret',
      'cookie-secret',
      'password-secret',
      '654321',
      'private@example.test',
      'private-phone',
    ]) {
      expect(output, isNot(contains(secret)));
    }
    expect(output, contains('REDACTED'));
    expect(output, contains('limit=10'));
  });

  test('list and raw request bodies do not crash the debug interceptor', () {
    for (final body in [
      <Object>['private-value'],
      'private-value',
    ]) {
      final output = CurlLoggerInterceptor.formatRequest(
        RequestOptions(path: 'https://example.test/api', data: body),
      );
      expect(output, isNot(contains('private-value')));
    }
  });
}
