enum AppEnvironment { development, staging, production }

class EnvConfig {
  static AppEnvironment _environment = AppEnvironment.development;

  static void init({AppEnvironment environment = AppEnvironment.development}) {
    _environment = environment;
  }

  static AppEnvironment get environment => _environment;

  static bool get isDevelopment => _environment == AppEnvironment.development;
  static bool get isStaging => _environment == AppEnvironment.staging;
  static bool get isProduction => _environment == AppEnvironment.production;

  static String get appName {
    switch (_environment) {
      case AppEnvironment.development:
        return 'Seafood POS (Dev)';
      case AppEnvironment.staging:
        return 'Seafood POS (Staging)';
      case AppEnvironment.production:
        return 'Seafood POS';
    }
  }

  static String get baseUrl {
    switch (_environment) {
      case AppEnvironment.development:
        // Laragon default subdirectory routing
        return 'http://192.168.1.200/seafood-system/public/api';
      case AppEnvironment.staging:
        return 'https://staging-api.seafood.example/api';
      case AppEnvironment.production:
        return 'https://seafood-pos.duckdns.org/api';
    }
  }

  static Duration get connectTimeout => const Duration(seconds: 30);
  static Duration get receiveTimeout => const Duration(seconds: 30);

  // Pusher Realtime Configuration
  static String get pusherAppKey => '738c8d688cc19f12cdeb';
  static String get pusherCluster => 'ap1';
  static String get pusherKdsChannel {
    switch (_environment) {
      case AppEnvironment.development:
        return 'pos-seafood-kds-development';
      case AppEnvironment.staging:
        return 'pos-seafood-kds-staging';
      case AppEnvironment.production:
        return 'pos-seafood-kds-production';
    }
  }
}
