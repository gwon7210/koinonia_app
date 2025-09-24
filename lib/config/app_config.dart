enum AppEnvironment { dev, prod }

class AppConfig {
  AppConfig._();

  static const String _rawEnv = String.fromEnvironment('APP_ENV', defaultValue: 'dev');

  static AppEnvironment get environment =>
      _rawEnv.toLowerCase() == 'prod' ? AppEnvironment.prod : AppEnvironment.dev;

  static const String _devApiBaseUrl = 'http://192.168.0.187:3000/api';
  static const String _prodApiBaseUrl = 'https://api.koinonia.app/api';

  static String get apiBaseUrl => String.fromEnvironment(
        'API_BASE_URL',
        defaultValue:
            environment == AppEnvironment.prod ? _prodApiBaseUrl : _devApiBaseUrl,
      );
}
