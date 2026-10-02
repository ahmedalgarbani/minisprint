import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:minisprint/core/error/exceptions.dart';
import 'package:minisprint/core/network/http_api_client.dart';

void main() {
  HttpApiClient client(MockClientHandler handler, {String? token}) =>
      HttpApiClient(
        baseUrl: 'https://api.example.com/v1/',
        client: MockClient(handler),
        authTokenProvider: token == null ? null : () async => token,
      );

  test('joins the base URL and path and decodes JSON', () async {
    late http.Request sent;
    final api = client((request) async {
      sent = request;
      return http.Response(
        jsonEncode([
          {'id': 1},
        ]),
        200,
      );
    });

    final body = await api.get('/projects');

    expect(sent.url.toString(), 'https://api.example.com/v1/projects');
    expect(body, [
      {'id': 1},
    ]);
  });

  test('sends a JSON body and bearer token', () async {
    late http.Request sent;
    final api = client((request) async {
      sent = request;
      return http.Response('{"id": 7}', 201);
    }, token: 'secret');

    await api.post('/tasks', body: {'title': 'A'});

    expect(sent.method, 'POST');
    expect(sent.headers['Authorization'], 'Bearer secret');
    expect(jsonDecode(sent.body), {'title': 'A'});
  });

  test('maps 404 to NotFoundException', () async {
    final api = client((_) async => http.Response('', 404));
    expect(api.get('/projects/9'), throwsA(isA<NotFoundException>()));
  });

  test('maps 401 to UnauthorizedException', () async {
    final api = client((_) async => http.Response('', 401));
    expect(api.get('/projects'), throwsA(isA<UnauthorizedException>()));
  });

  test('maps 5xx to ServerException with the status code', () async {
    final api = client((_) async => http.Response('oops', 500));
    expect(
      api.get('/projects'),
      throwsA(
        isA<ServerException>().having((e) => e.statusCode, 'status', 500),
      ),
    );
  });

  test('maps connection errors to NetworkException', () async {
    final api = client((_) async => throw http.ClientException('offline'));
    expect(api.get('/projects'), throwsA(isA<NetworkException>()));
  });
}
