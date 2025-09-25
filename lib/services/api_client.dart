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

  static Future<http.Response> patch(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    return _send('PATCH', uri, headers: headers, body: body, encoding: encoding);
  }

  static Future<http.Response> postMultipart(
    Uri uri, {
    Map<String, String>? headers,
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
  }) async {
    final requestId = _nextRequestId();
    final stopWatch = Stopwatch()..start();

    _logRequest(
      method: 'POST (multipart)',
      uri: uri,
      requestId: requestId,
      headers: headers,
      bodyDescription: _describeMultipart(fields: fields, files: files),
    );

    final request = http.MultipartRequest('POST', uri);
    if (headers != null && headers.isNotEmpty) {
      request.headers.addAll(headers);
    }
    if (fields != null && fields.isNotEmpty) {
      request.fields.addAll(fields);
    }
    if (files != null && files.isNotEmpty) {
      request.files.addAll(files);
    }

    http.StreamedResponse streamed;
    try {
      streamed = await _client.send(request);
    } catch (error) {
      stopWatch.stop();
      print('[API][$requestId] ERROR after ${stopWatch.elapsedMilliseconds}ms: $error');
      rethrow;
    }

    final response = await http.Response.fromStream(streamed);
    stopWatch.stop();
    _logResponse(requestId: requestId, stopwatch: stopWatch, response: response);
    return response;
  }

  static Future<http.Response> _send(
    String method,
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final requestId = _nextRequestId();
    final stopWatch = Stopwatch()..start();

    _logRequest(
      method: method,
      uri: uri,
      requestId: requestId,
      headers: headers,
      bodyDescription: body,
    );

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
      } else if (method == 'PATCH') {
        response = await _client.patch(
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
    _logResponse(requestId: requestId, stopwatch: stopWatch, response: response);
    return response;
  }

  static const int _maxLogBodyLength = 1000;

  static int _nextRequestId() => DateTime.now().microsecondsSinceEpoch;

  static void _logRequest({
    required String method,
    required Uri uri,
    required int requestId,
    Map<String, String>? headers,
    Object? bodyDescription,
  }) {
    print('[API][$requestId] $method ${uri.toString()}');
    if (headers != null && headers.isNotEmpty) {
      print('[API][$requestId] headers: $headers');
    }
    if (bodyDescription != null) {
      print('[API][$requestId] body: ${_truncate(bodyDescription.toString())}');
    }
  }

  static void _logResponse({
    required int requestId,
    required Stopwatch stopwatch,
    required http.Response response,
  }) {
    print('[API][$requestId] response ${response.statusCode} (${stopwatch.elapsedMilliseconds}ms)');
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
  }

  static String _describeMultipart({
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
  }) {
    final buffer = StringBuffer('multipart');
    if (fields != null && fields.isNotEmpty) {
      buffer.write(' fields=${fields.map((key, value) => MapEntry(key, _truncate(value))).toString()}');
    }
    if (files != null && files.isNotEmpty) {
      final fileSummaries = files.map((file) {
        final length = file.length;
        return '{field:${file.field}, name:${file.filename}, length:${length}}';
      }).join(', ');
      buffer.write(' files=[$fileSummaries]');
    }
    return buffer.toString();
  }

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
