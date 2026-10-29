enum AppEnvironment {
  development,
  staging,
  production,
}

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
        // By default Laragon / local Laravel server
        return 'http://127.0.0.1:8000/api';
      case AppEnvironment.staging:
        return 'https://staging-api.seafood.example/api';
      case AppEnvironment.production:
        return 'https://api.seafood.example/api';
    }
  }

  static Duration get connectTimeout => const Duration(seconds: 30);
  static Duration get receiveTimeout => const Duration(seconds: 30);
}

