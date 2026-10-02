import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../error/exceptions.dart';
import 'api_client.dart';

typedef AuthTokenProvider = Future<String?> Function();

class HttpApiClient implements ApiClient {
  final String baseUrl;
  final http.Client _client;
  final Duration timeout;
  final AuthTokenProvider? authTokenProvider;

  HttpApiClient({
    required this.baseUrl,
    http.Client? client,
    this.timeout = const Duration(seconds: 20),
    this.authTokenProvider,
  }) : _client = client ?? http.Client();

  @override
  Future<dynamic> get(String path, {Map<String, String>? query}) {
    return _send('GET', path, query: query);
  }

  @override
  Future<dynamic> post(String path, {Object? body}) {
    return _send('POST', path, body: body);
  }

  @override
  Future<dynamic> put(String path, {Object? body}) {
    return _send('PUT', path, body: body);
  }

  @override
  Future<void> delete(String path) async {
    await _send('DELETE', path);
  }

  Uri _uri(String path, Map<String, String>? query) {
    final base = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$base$cleanPath');
    return query == null || query.isEmpty
        ? uri
        : uri.replace(queryParameters: {...uri.queryParameters, ...query});
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
  }) async {
    final request = http.Request(method, _uri(path, query))
      ..headers['Accept'] = 'application/json';
    final token = await authTokenProvider?.call();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }

    final http.Response response;
    try {
      final streamed = await _client.send(request).timeout(timeout);
      response = await http.Response.fromStream(streamed).timeout(timeout);
    } on TimeoutException {
      throw const NetworkException('Request timed out');
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } on Exception catch (e) {
      // Socket / TLS errors not wrapped by the http package.
      throw NetworkException(e.toString());
    }

    final status = response.statusCode;
    if (status == 401 || status == 403) {
      throw const UnauthorizedException('Not authorized');
    }
    if (status == 404) {
      throw NotFoundException('Not found: $method ${request.url.path}');
    }
    if (status < 200 || status >= 300) {
      throw ServerException(status, 'Server error ($status)');
    }
    if (response.body.isEmpty) return null;
    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw ServerException(status, 'Invalid JSON response');
    }
  }
}
