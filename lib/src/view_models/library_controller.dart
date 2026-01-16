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

  // Lấy danh sách Playlist
  Future<void> fetchMyPlaylists() async {
    try {
      isLoading.value = true;
      final userId = await _getCurrentUserId();

      if (userId == null) {
        isLoading.value = false;
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
          myPlaylists.value = list
              .map((json) => PlaylistModel.fromJson(json))
              .toList();
        }
      }
    } catch (e) {
      print("Lỗi tải thư viện: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Tạo Playlist mới (QUAN TRỌNG: Đã sửa để gửi Multipart)
  Future<void> createPlaylist(String name, {File? imageFile}) async {
    try {
      final userId = await _getCurrentUserId();

      if (userId == null) {
        Get.snackbar("Lỗi", "Vui lòng đăng nhập lại");
        return;
      }

      // Tạo MultipartRequest
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(AppUrls.playlistCreate),
      );

      // Thêm các fields văn bản
      request.fields['name'] = name;
      request.fields['desc'] = 'Playlist cá nhân';
      request.fields['userId'] = userId;

      // Thêm file ảnh (nếu user có chọn)
      if (imageFile != null) {
        var multipartFile = await http.MultipartFile.fromPath(
          'image', // Key này phải khớp với upload.single('image') ở Backend
          imageFile.path,
        );
        request.files.add(multipartFile);
      }
      // Nếu imageFile == null, Backend sẽ tự động lấy ảnh mặc định upload lên Cloudinary

      // Gửi request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        Get.snackbar("Thành công", "Đã tạo playlist mới");
        Get.back(); // Đóng dialog
        fetchMyPlaylists(); // Refresh danh sách ngay lập tức
      } else {
        Get.snackbar("Lỗi", "Không thể tạo playlist: ${data['message']}");
      }
    } catch (e) {
      Get.snackbar("Lỗi", "Lỗi kết nối mạng: $e");
      print(e);
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
