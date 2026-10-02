import 'package:flutter_test/flutter_test.dart';
import 'package:minisprint/core/config/app_config.dart';

void main() {
  test('defaults to the local database', () {
    final config = AppConfig.parse(source: '');
    expect(config.dataSource, DataSourceType.local);
  });

  test('uses the remote API when configured with a valid URL', () {
    final config = AppConfig.parse(
      source: 'remote',
      apiBaseUrl: 'https://api.example.com/v1',
    );
    expect(config.isRemote, isTrue);
    expect(config.apiBaseUrl, 'https://api.example.com/v1');
  });

  test('falls back to local when remote is requested without a valid URL', () {
    final config = AppConfig.parse(source: 'remote', apiBaseUrl: 'not a url');
    expect(config.dataSource, DataSourceType.local);
  });
}
