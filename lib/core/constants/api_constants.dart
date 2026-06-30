/// ═══════════════════════════════════════════════════════════════════
///  API CONSTANTS — Laravel + ngrok / emulator
///
///  ERROR "route not found"? Cek bagian ENDPOINT di bawah.
///  Sesuaikan dengan isi routes/api.php di project Laravel kamu.
/// ═══════════════════════════════════════════════════════════════════

class ApiConstants {
  ApiConstants._();

  // ── BASE URL ───────────────────────────────────────────────────────
  // Ganti URL ngrok setiap kali restart
  static const String ngrokBaseUrl =
      'https://a1b2-103-xx-xx-xx.ngrok-free.app';

  // Android emulator → localhost komputer (tidak perlu ngrok)
  static const String emulatorBaseUrl = 'http://10.0.2.2:8000';

  // Device fisik di jaringan yang sama — ganti IP sesuai komputer kamu
  static const String localBaseUrl = 'http://192.168.1.100:8000';

  // ▼▼▼ PILIH SALAH SATU: ▼▼▼
  static String get baseUrl => emulatorBaseUrl;
  // static String get baseUrl => ngrokBaseUrl;
  // static String get baseUrl => localBaseUrl;
  // ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲

  static String get apiUrl => '$baseUrl/api';

  // ── ENDPOINTS ──────────────────────────────────────────────────────
  // Sesuaikan dengan routes/api.php di project Laravel kamu.
  //
  // Dari api.php yang dikirim:
  //   Route::post('/auth/register', ...)  → '/auth/register'
  //   Route::post('/auth/login', ...)     → '/auth/login'
  //   Route::post('/auth/logout', ...)    → '/auth/logout'
  //   Route::get('/auth/profile', ...)    → '/auth/profile'
  //
  // Jika Laravel kamu pakai prefix berbeda, misal:
  //   Route::post('/login', ...)  → ganti jadi '/login'

  // Auth
  static const String register = '/auth/register';
  static const String login    = '/auth/login';
  static const String logout   = '/auth/logout';
  static const String profile  = '/auth/profile';

  // Events
  static const String events = '/events';
  static String eventDetail(dynamic id) => '/events/$id';

  // Transactions
  static const String transactions  = '/transactions';
  static const String checkout      = '/transactions/checkout';
  static const String webhook       = '/transactions/webhook';
  static String transactionDetail(dynamic id)     => '/transactions/$id';
  static String transactionPay(dynamic id)        => '/transactions/$id/pay';
  static String transactionStatus(dynamic id)     => '/transactions/$id/check-status';

  // ── TIMEOUTS ────────────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout    = Duration(seconds: 20);
}
