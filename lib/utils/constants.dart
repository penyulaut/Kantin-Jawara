class Constants {
  // API Base URL - Laravel API
  static const String baseUrl =
      'https://semenjana.biz.id/kaja/api'; // Ganti dengan IP/domain Laravel Anda

  // API Endpoints
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';
  static const String logoutEndpoint = '/logout';
  static const String profileEndpoint = '/profile';

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';

  // App Info
  static const String appName = 'Kantin Jawara';
  static const String appVersion = '1.0.0';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
}
