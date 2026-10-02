/// Minimal JSON HTTP contract used by remote data sources.
///
/// Remote data sources depend on this interface only, so the HTTP library can
/// change (or be faked in tests) without touching feature code.
abstract class ApiClient {
  Future<dynamic> get(String path, {Map<String, String>? query});
  Future<dynamic> post(String path, {Object? body});
  Future<dynamic> put(String path, {Object? body});
  Future<void> delete(String path);
}
