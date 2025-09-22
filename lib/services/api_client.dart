import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient._();

  static final http.Client _client = http.Client();

  static Future<http.Response> get(
    Uri uri, {
    Map<String, String>? headers,
  }) async {
    return _send('GET', uri, headers: headers);
  }

  static Future<http.Response> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    return _send('POST', uri, headers: headers, body: body, encoding: encoding);
  }

  static Future<http.Response> _send(
    String method,
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final requestId = DateTime.now().microsecondsSinceEpoch;
    final stopWatch = Stopwatch()..start();

    print('[API][$requestId] $method ${uri.toString()}');
    if (headers != null && headers.isNotEmpty) {
      print('[API][$requestId] headers: $headers');
    }
    if (body != null) {
      print('[API][$requestId] body: $body');
    }

    http.Response response;
    try {
      if (method == 'GET') {
        response = await _client.get(uri, headers: headers);
      } else if (method == 'POST') {
        response = await _client.post(
          uri,
          headers: headers,
          body: body,
          encoding: encoding,
        );
      } else {
        throw UnsupportedError('Unsupported method $method');
      }
    } catch (error) {
      stopWatch.stop();
      print('[API][$requestId] ERROR after ${stopWatch.elapsedMilliseconds}ms: $error');
      rethrow;
    }

    stopWatch.stop();
    print('[API][$requestId] response ${response.statusCode} (${stopWatch.elapsedMilliseconds}ms)');
    final rawBody = response.body;
    if (rawBody.isEmpty) {
      print('[API][$requestId] response body: <empty>');
    } else {
      final trimmedBody = rawBody.trim();
      final contentType = response.headers['content-type'] ?? '';
      if (contentType.contains('application/json')) {
        try {
          final decoded = jsonDecode(trimmedBody);
          if (decoded == null) {
            print('[API][$requestId] response json: null');
          } else if (decoded is Map && decoded.isEmpty) {
            print('[API][$requestId] response json: {} (empty object)');
          } else if (decoded is List && decoded.isEmpty) {
            print('[API][$requestId] response json: [] (empty list)');
          } else {
            print('[API][$requestId] response json: ${_stringifyJson(decoded)}');
          }
        } catch (error) {
          print('[API][$requestId] response body (invalid json): ${_truncate(trimmedBody)}');
        }
      } else if (trimmedBody.toLowerCase() == 'null') {
        print('[API][$requestId] response body: null');
      } else {
        print('[API][$requestId] response body: ${_truncate(trimmedBody)}');
      }
    }

    return response;
  }

  static const int _maxLogBodyLength = 1000;

  static String _truncate(String value) {
    if (value.length <= _maxLogBodyLength) {
      return value;
    }
    return '${value.substring(0, _maxLogBodyLength)}... (truncated ${value.length - _maxLogBodyLength} chars)';
  }

  static String _stringifyJson(dynamic json) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      final pretty = encoder.convert(json);
      return _truncate(pretty);
    } catch (_) {
      return _truncate(json.toString());
    }
  }
}
