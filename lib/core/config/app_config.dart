/// Application Configuration
class AppConfig {
  // API Configuration
  static const String apiBaseUrl = 'https://paver-thrower-surrogate.ngrok-free.dev';
  static const String apiTimeout = '30'; // seconds

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Pagination
  static const int defaultPageSize = 10;

  // Environment
  static const bool isProduction = false;
  static const String appName = 'Event Ticketing';
  static const String appVersion = '1.0.0';
}