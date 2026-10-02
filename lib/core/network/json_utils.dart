import '../error/exceptions.dart';

/// Accepts either a bare JSON list or an envelope like `{"data": [...]}`.
List<Map<String, dynamic>> jsonList(dynamic body) {
  final value = body is Map<String, dynamic> && body.containsKey('data')
      ? body['data']
      : body;
  if (value is! List) {
    throw const ServerException(200, 'Expected a JSON list');
  }
  return value.whereType<Map<String, dynamic>>().toList();
}

/// Accepts either a bare JSON object or an envelope like `{"data": {...}}`.
Map<String, dynamic> jsonObject(dynamic body) {
  final value = body is Map<String, dynamic> && body['data'] is Map
      ? body['data']
      : body;
  if (value is! Map<String, dynamic>) {
    throw const ServerException(200, 'Expected a JSON object');
  }
  return value;
}

int? jsonInt(Object? value) => switch (value) {
  int v => v,
  num v => v.toInt(),
  String v => int.tryParse(v),
  _ => null,
};
