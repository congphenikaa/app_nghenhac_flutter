class AppUrls {
  // Chọn 1 trong các dòng dưới tùy môi trường bạn chạy
  //   Nếu dùng Android Emulator: Dùng http://10.0.2.2:5000

  // Nếu dùng iOS Simulator: Dùng http://localhost:5000

  // Nếu dùng Điện thoại thật: Phải dùng IP LAN của máy tính (ví dụ: http://192.168.1.15:5000).
  static const String baseUrl = 'http://localhost:5000';
  // static const String baseUrl = 'http://localhost:5000';

  static const String login = '$baseUrl/api/auth/login';
  static const String register = '$baseUrl/api/auth/register';
  static const String listSong = '$baseUrl/api/song/list';
}
