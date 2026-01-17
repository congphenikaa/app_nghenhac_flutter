import 'dart:convert';
import 'dart:io';
import 'package:app_nghenhac/src/configs/app_urls.dart';
import 'package:app_nghenhac/src/models/playlist_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LibraryController extends GetxController {
  var myPlaylists = <PlaylistModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyPlaylists();
  }

  Future<String?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // isSilent = true: Cập nhật dữ liệu ngầm, không hiện loading (Dùng khi add song)
  // isSilent = false: Hiện loading (Dùng khi mới vào màn hình)
  Future<void> fetchMyPlaylists({bool isSilent = false}) async {
    try {
      if (!isSilent) isLoading.value = true;

      final userId = await _getCurrentUserId();

      if (userId == null) {
        if (!isSilent) isLoading.value = false;
        return;
      }

      final response = await http.post(
        Uri.parse(AppUrls.playlistUserList),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> list = data['playlists'] ?? [];
          // Khi gán value mới, Obx ở UI sẽ tự động rebuild và cập nhật số lượng
          myPlaylists.value = list
              .map((json) => PlaylistModel.fromJson(json))
              .toList();
        }
      }
    } catch (e) {
      print("Lỗi tải thư viện: $e");
    } finally {
      if (!isSilent) isLoading.value = false;
    }
  }

  // Tạo Playlist mới
  Future<void> createPlaylist(String name, {File? imageFile}) async {
    try {
      final userId = await _getCurrentUserId();

      if (userId == null) {
        Get.snackbar("Lỗi", "Vui lòng đăng nhập lại");
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(AppUrls.playlistCreate),
      );

      request.fields['name'] = name;
      request.fields['desc'] = 'Playlist cá nhân';
      request.fields['userId'] = userId;

      if (imageFile != null) {
        var multipartFile = await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        );
        request.files.add(multipartFile);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        Get.snackbar("Thành công", "Đã tạo playlist mới");
        Get.back();
        fetchMyPlaylists(); // Refresh danh sách
      } else {
        Get.snackbar("Lỗi", "Không thể tạo playlist: ${data['message']}");
      }
    } catch (e) {
      Get.snackbar("Lỗi", "Lỗi kết nối mạng: $e");
      print(e);
    }
  }

  // Thêm bài hát vào Playlist
  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    try {
      final response = await http.post(
        Uri.parse(AppUrls.playlistAddSong),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'playlistId': playlistId, 'songId': songId}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        Get.back(); // Đóng BottomSheet
        Get.snackbar("Thành công", "Đã thêm vào playlist");

        fetchMyPlaylists(isSilent: true);
      } else {
        Get.snackbar("Thông báo", data['message'] ?? "Lỗi khi thêm bài hát");
      }
    } catch (e) {
      print(e);
      Get.snackbar("Lỗi", "Lỗi kết nối mạng");
    }
  }

  //Xóa bài hát khỏi Playlist
  Future<bool> removeSongFromPlaylist(String playlistId, String songId) async {
    try {
      final response = await http.post(
        Uri.parse(AppUrls.playlistRemoveSong),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'playlistId': playlistId, 'songId': songId}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Sau khi xóa xong, cập nhật lại list playlist bên ngoài để giảm số lượng bài hát
        fetchMyPlaylists(isSilent: true);
        return true;
      } else {
        Get.snackbar("Lỗi", data['message'] ?? "Không thể xóa bài hát");
        return false;
      }
    } catch (e) {
      print("Lỗi xóa bài hát: $e");
      Get.snackbar("Lỗi", "Không thể kết nối đến máy chủ");
      return false;
    }
  }

  // Xóa Playlist
  Future<void> removePlaylist(String playlistId) async {
    try {
      final response = await http.post(
        Uri.parse(AppUrls.playlistRemove),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'playlistId': playlistId}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Xóa cục bộ để phản hồi nhanh
        myPlaylists.removeWhere((p) => p.id == playlistId);
        Get.snackbar("Đã xóa", "Đã xóa playlist thành công");
      } else {
        Get.snackbar("Lỗi", "Không thể xóa playlist");
      }
    } catch (e) {
      print(e);
      Get.snackbar("Lỗi", "Lỗi kết nối khi xóa");
    }
  }
}
