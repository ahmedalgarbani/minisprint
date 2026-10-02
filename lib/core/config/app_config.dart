/// Where the app reads and writes its data.
enum DataSourceType { local, remote }

/// Build-time configuration.
///
/// Values come from `--dart-define` so no URL or secret is hardcoded:
///
/// ```sh
/// flutter run --dart-define=DATA_SOURCE=remote \
///             --dart-define=API_BASE_URL=https://api.example.com/v1
/// ```
class AppConfig {
  final DataSourceType dataSource;
  final String apiBaseUrl;
  final Duration requestTimeout;

  const AppConfig({
    required this.dataSource,
    this.apiBaseUrl = '',
    this.requestTimeout = const Duration(seconds: 20),
  });

  bool get isRemote => dataSource == DataSourceType.remote;

  factory AppConfig.fromEnvironment() {
    const source = String.fromEnvironment('DATA_SOURCE', defaultValue: 'local');
    const baseUrl = String.fromEnvironment('API_BASE_URL');
    return AppConfig.parse(source: source, apiBaseUrl: baseUrl);
  }

  /// Falls back to [DataSourceType.local] when the remote config is incomplete
  /// so a misconfigured build never starts without a working data source.
  factory AppConfig.parse({required String source, String apiBaseUrl = ''}) {
    final wantsRemote = source.trim().toLowerCase() == 'remote';
    final uri = Uri.tryParse(apiBaseUrl.trim());
    final validUrl = uri != null && uri.hasScheme && uri.host.isNotEmpty;
    if (wantsRemote && validUrl) {
      return AppConfig(
        dataSource: DataSourceType.remote,
        apiBaseUrl: apiBaseUrl.trim(),
      );
    }
    return const AppConfig(dataSource: DataSourceType.local);
  }
}
