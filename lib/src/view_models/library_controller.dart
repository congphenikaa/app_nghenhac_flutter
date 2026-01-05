import 'dart:convert';
import 'package:app_nghenhac/src/configs/app_urls.dart';
import 'package:app_nghenhac/src/models/playlist_model.dart';
import 'package:flutter/material.dart';
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

  // Helper để lấy userId từ SharedPreferences
  Future<String?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<void> fetchMyPlaylists() async {
    try {
      isLoading.value = true;

      final userId = await _getCurrentUserId();

      if (userId == null) {
        print("Chưa tìm thấy UserID, không thể tải playlist");
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

  Future<void> createPlaylist(String name) async {
    try {
      final userId = await _getCurrentUserId();

      if (userId == null) {
        Get.snackbar("Lỗi", "Vui lòng đăng nhập lại để thực hiện");
        return;
      }

      final response = await http.post(
        Uri.parse(AppUrls.playlistCreate),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'desc': 'Playlist cá nhân',
          'userId': userId,
        }),
      );

      final data = json.decode(response.body);
      if (data['success'] == true) {
        Get.snackbar("Thành công", "Đã tạo playlist mới");
        fetchMyPlaylists(); // Refresh list ngay lập tức
      } else {
        Get.snackbar("Lỗi", "Không thể tạo playlist: ${data['message']}");
      }
    } catch (e) {
      Get.snackbar("Lỗi", "Lỗi kết nối mạng");
      print(e);
    }
  }

  Future<void> removePlaylist(String playlistId) async {
    try {
      final response = await http.post(
        Uri.parse(AppUrls.playlistRemove),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'playlistId': playlistId}),
      );
      if (json.decode(response.body)['success'] == true) {
        myPlaylists.removeWhere((p) => p.id == playlistId);
        Get.snackbar("Đã xóa", "Đã xóa playlist thành công");
      }
    } catch (e) {
      print(e);
      Get.snackbar("Lỗi", "Không thể xóa playlist");
    }
  }
}
