class AppUrls {
  // Chọn 1 trong các dòng dưới tùy môi trường bạn chạy
  //   Nếu dùng Android Emulator: Dùng http://10.0.2.2:5000

  // Nếu dùng iOS Simulator: Dùng http://localhost:5000

  // Nếu dùng Điện thoại thật: Phải dùng IP LAN của máy tính (ví dụ: http://10.60.129.45:5000). dùng câu lệnh ipcofig để xem ipv4
  static const String baseUrl = 'http://10.0.2.2:5000';
  // static const String baseUrl = 'http://10.0.2.2:5000' 'https://backend-flutter-ten.vercel.app';

  static const String login = '$baseUrl/api/auth/login';
  static const String register = '$baseUrl/api/auth/register';

  static const String userDetail = '$baseUrl/api/user/detail';
  static const String updateProfile = '$baseUrl/api/user/update';

  static const String toggleLike = '$baseUrl/api/user/toggle-like';
  static const String toggleFollow = '$baseUrl/api/user/toggle-follow';
  static const String likedSongs = '$baseUrl/api/user/liked-songs';

  static const String listSong = '$baseUrl/api/song/list';
  static const String listCategory = '$baseUrl/api/category/list';

  static const String songByCategory = '$baseUrl/api/song/category';

  static const String songByAlbum = '$baseUrl/api/song/album';
  static const String searchSong = '$baseUrl/api/song/search';

  static const String listAlbum = '$baseUrl/api/album/list';
  static const String listArtist = '$baseUrl/api/artist/list';

  static const String playlistCreate = '$baseUrl/api/playlist/create';
  static const String playlistUserList = '$baseUrl/api/playlist/user-list';
  static const String playlistAddSong = '$baseUrl/api/playlist/add-song';
  static const String playlistRemove = '$baseUrl/api/playlist/remove';
  static const String playlistDetail = '$baseUrl/api/playlist/detail';

  static const String playlistRemoveSong = '$baseUrl/api/playlist/remove-song';
}
