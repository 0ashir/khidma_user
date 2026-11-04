import 'dart:developer' as developer;
import 'package:dio/dio.dart';

class CurlLoggerInterceptor extends Interceptor {
  static bool _sensitive(String key) => RegExp(
    'authorization|cookie|password|token|otp|secret|api.?key|email|phone|mobile|message|address|name|identity|uid',
    caseSensitive: false,
  ).hasMatch(key);

  static String _quote(Object? value) =>
      "'${value.toString().replaceAll("'", "'\\''")}'";

  /// Debug output must never contain credentials or customer contact details.
  static String formatRequest(RequestOptions options) {
    final uri = options.uri;
    final safeUri = uri.hasQuery
        ? uri.replace(
            queryParameters: {
              for (final entry in uri.queryParameters.entries)
                entry.key: _sensitive(entry.key) ? '[REDACTED]' : entry.value,
            },
          )
        : uri;
    final parts = [
      'curl -X ${options.method.toUpperCase()} ${_quote(safeUri)}',
    ];
    options.headers.forEach((key, value) {
      parts.add(
        ' -H ${_quote('$key: ${_sensitive(key) ? '[REDACTED]' : value}')}',
      );
    });
    final data = options.data;
    if (data is FormData) {
      for (final field in data.fields) {
        parts.add(
          ' -F ${_quote('${field.key}=${_sensitive(field.key) ? '[REDACTED]' : field.value}')}',
        );
      }
      for (final file in data.files) {
        parts.add(' -F ${_quote('${file.key}=@[FILE]')}');
      }
    } else if (data is Map) {
      data.forEach((key, value) {
        parts.add(
          ' -F ${_quote('$key=${_sensitive(key.toString()) ? '[REDACTED]' : value}')}',
        );
      });
    } else if (data != null) {
      parts.add(" --data '[BODY OMITTED]'");
    }
    return parts.join();
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer.log(formatRequest(options), name: 'CURL_LOG');
    handler.next(options);
  }
}
