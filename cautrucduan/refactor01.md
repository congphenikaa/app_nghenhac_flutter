KẾ HOẠCH TÁI CẤU TRÚC 01: NETWORK & REPOSITORY PATTERN

Mục tiêu: Tách toàn bộ logic gọi API (HTTP) ra khỏi các ViewModels (Controllers). ViewModels chỉ nhận dữ liệu từ Repository và cập nhật State.

BƯỚC 1: TẠO API CLIENT (Core Network)

Tạo file: lib/src/core/network/api_client.dart

Tạo class ApiClient đóng gói các phương thức http.get, http.post, http.put, MultipartRequest.

Xử lý tự động nạp Token (từ SharedPreferences) vào Header của mọi request.

Xử lý try/catch và parse JSON mặc định ở đây.

BƯỚC 2: TẠO TẦNG REPOSITORY (Data Layer)

Tạo thư mục lib/src/data/repositories/ và tạo các file sau:

auth_repository.dart: Chứa API login, register, update profile, toggle like, get liked songs.

song_repository.dart: Chứa API get trending, get song by category, search song.

playlist_repository.dart: Chứa API create, update, delete, add song, remove song.

home_repository.dart: Chứa API lấy initial data (Albums, Artists, Categories, Songs).

BƯỚC 3: REFATOR VIEW_MODELS (Controllers)

Cập nhật các file trong lib/src/view_models/:

AuthController: Dùng AuthRepository.

LibraryController: Dùng PlaylistRepository.

HomeController: Dùng HomeRepository và SongRepository.

ChartController: Dùng SongRepository.

SearchPageController: Dùng SongRepository.

Yêu cầu AI: Giữ nguyên tính phản ứng (.obs, Obx) và các hiển thị Get.snackbar. Chỉ thay đổi cơ chế fetch data.