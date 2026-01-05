import 'dart:convert';
import 'package:app_nghenhac/src/models/album_model.dart';
import 'package:app_nghenhac/src/models/artist_model.dart';
import 'package:app_nghenhac/src/models/category_model.dart';
import 'package:app_nghenhac/src/models/playlist_model.dart';
import 'package:get/get.dart';
import 'package:app_nghenhac/src/configs/app_urls.dart';
import 'package:app_nghenhac/src/models/song_model.dart';
import 'package:http/http.dart' as http;

class HomeController extends GetxController {
  var isLoading = true.obs;
  var isSongLoading = false.obs; // Loading riêng cho list bài hát

  var categories = <CategoryModel>[].obs;
  var songList = <SongModel>[].obs;
  var albums = <AlbumModel>[].obs;
  var artists = <ArtistModel>[].obs;
  var playlists = <PlaylistModel>[].obs;

  var selectedCategoryIndex = 0.obs;
  @override
  void onInit() {
    fetchInitialData();
    super.onInit();
  }

  // 1. Tải dữ liệu ban đầu (Category + Tất cả bài hát)
  void fetchInitialData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        fetchCategories(),
        fetchSongs(),
        fetchAlbums(),
        fetchArtists(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  // 2. Lấy danh sách Category
  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse(AppUrls.listCategory));

      if (response.statusCode == 200) {
        // Vì là Map, nên ta decode ra Map trước
        final dynamic decodedData = json.decode(response.body);

        List<dynamic> categoryListJson = [];

        if (decodedData is List) {
          // Trường hợp 1: API trả về trực tiếp mảng [ {...}, {...} ]
          categoryListJson = decodedData;
        } else if (decodedData is Map<String, dynamic>) {
          // Trường hợp 2: API trả về object { "categories": [...] } hoặc { "data": [...] }
          // Bạn cần kiểm tra xem backend trả về key nào.
          // Thông thường là 'categories', 'data', hoặc 'list'.
          // Ở đây mình thử check các key phổ biến:
          if (decodedData.containsKey('categories')) {
            categoryListJson = decodedData['categories'];
          } else if (decodedData.containsKey('data')) {
            categoryListJson = decodedData['data'];
          } else if (decodedData.containsKey('list')) {
            // Check thêm key list nếu có
            categoryListJson = decodedData['list'];
          } else {
            print(
              "Warning: Không tìm thấy key chứa mảng category trong JSON trả về",
            );
          }
        }

        // Map dữ liệu
        var fetchedCats = categoryListJson
            .map((json) => CategoryModel.fromJson(json))
            .toList();

        // Tạo nút "All" giả lập
        var allBtn = CategoryModel(
          id: 'all',
          name: 'All',
          image: '',
          color: '#FFFFFF',
        );

        // Gán vào list: [All, ...DB Data]
        categories.assignAll([allBtn, ...fetchedCats]);
      } else {
        print("Lỗi server (Category): ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi tải Category: $e");
    }
  }

  Future<void> fetchSongs() async {
    try {
      isLoading(true);

      final response = await http.get(Uri.parse(AppUrls.listSong));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          final List<dynamic> songsJson = data['songs'];

          songList.value = songsJson
              .map((json) => SongModel.fromJson(json))
              .toList();
        } else {
          print("Lỗi từ server: ${response.statusCode}");
        }
      }
    } catch (e) {
      print("Lỗi kết nối: $e");
      Get.snackbar("Lỗi", "Không thể kết nối tới máy chủ");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchAlbums() async {
    try {
      final response = await http.get(Uri.parse(AppUrls.listAlbum));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> list = data['albums'] ?? [];
          albums.value = list.map((json) => AlbumModel.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print("Lỗi Albums: $e");
    }
  }

  Future<void> fetchArtists() async {
    try {
      final response = await http.get(Uri.parse(AppUrls.listArtist));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> list = data['artists'] ?? [];
          artists.value = list
              .map((json) => ArtistModel.fromJson(json))
              .toList();
        }
      }
    } catch (e) {
      print("Lỗi Artists: $e");
    }
  }

  Future<void> fetchSongsByCategory(String categoryId) async {
    try {
      isSongLoading.value = true;
      // Gọi API: /api/song/category/{id}
      final url = '${AppUrls.songByCategory}/$categoryId';
      print("Calling: $url");

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        // Tùy vào backend trả về, giả sử giống cấu trúc listSong
        if (data['success'] == true) {
          final List<dynamic> songsJson = data['songs'];
          songList.value = songsJson
              .map((json) => SongModel.fromJson(json))
              .toList();
        }
      } else {
        songList.clear(); // Nếu lỗi hoặc không có bài, xóa list cũ
      }
    } catch (e) {
      print("Lỗi filter song: $e");
      songList.clear();
    } finally {
      isSongLoading.value = false;
    }
  }

  // --- LOGIC CHUYỂN TAB ---
  void onCategorySelected(int index) {
    // Nếu bấm lại tab đang chọn thì không làm gì
    if (selectedCategoryIndex.value == index) return;

    selectedCategoryIndex.value = index;
    var category = categories[index];

    if (category.id == 'all') {
      // Nếu chọn All -> Load lại tất cả (Hoặc hiển thị Dashboard)
      fetchSongs();
    } else {
      // Nếu chọn mục cụ thể -> Gọi API lọc
      fetchSongsByCategory(category.id);
    }
  }
}
