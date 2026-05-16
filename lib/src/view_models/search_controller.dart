import 'dart:async';
import 'dart:convert';
import 'package:app_nghenhac/src/data/models/song_model.dart';
import 'package:app_nghenhac/src/data/models/artist_model.dart';
import 'package:app_nghenhac/src/data/models/album_model.dart';
import 'package:app_nghenhac/src/data/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/repositories/home_repository.dart';
import '../data/repositories/song_repository.dart';

class SearchPageController extends GetxController {
  final HomeRepository _homeRepository = HomeRepository();
  final SongRepository _songRepository = SongRepository();
  // Trạng thái UI
  var isLoading = false.obs;

  // Thêm biến RxString để theo dõi text thay đổi cho UI (Obx)
  var searchText = "".obs;

  final TextEditingController textController = TextEditingController();

  // Dữ liệu tìm kiếm
  var songResults = <SongModel>[].obs;
  var artistResults = <ArtistModel>[].obs;
  var albumResults = <AlbumModel>[].obs;

  // Dữ liệu Categories cho màn hình "Browse All"
  var categories = <CategoryModel>[].obs;

  // Debounce để tránh gọi API quá nhiều khi gõ
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    fetchCategories(); // Load category khi vào màn hình
  }

  // Hàm load danh sách Category (Browse All)
  Future<void> fetchCategories() async {
    try {
      final response = await _homeRepository.fetchCategories();
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> list = data['categories'] ?? [];
          categories.value = list
              .map((e) => CategoryModel.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      print("Lỗi tải categories: $e");
    }
  }

  // Hàm xử lý khi user gõ phím
  void onSearchChanged(String query) {
    searchText.value = query;

    // 1. Hủy lệnh tìm kiếm cũ nếu đang đếm ngược
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // 2. Nếu ô tìm kiếm rỗng -> Xóa kết quả
    if (query.trim().isEmpty) {
      clearResults();
      return;
    }

    // 3. Bắt đầu đếm ngược 500ms. Nếu sau 500ms không gõ thêm gì thì mới gọi API
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchGlobal(query);
    });
  }

  // Gọi API tìm kiếm
  Future<void> searchGlobal(String query) async {
    try {
      isLoading.value = true;

      // QUAN TRỌNG: Mã hóa tiếng Việt để không lỗi URL (Ví dụ: "Sơn Tùng" -> "S%C6%A1n...")
      final response = await _songRepository.searchGlobal(query);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Parse và gán dữ liệu vào List Obx
          songResults.value = (data['songs'] as List)
              .map((e) => SongModel.fromJson(e))
              .toList();
          artistResults.value = (data['artists'] as List)
              .map((e) => ArtistModel.fromJson(e))
              .toList();
          albumResults.value = (data['albums'] as List)
              .map((e) => AlbumModel.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      print("Lỗi tìm kiếm: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void clearResults() {
    songResults.clear();
    artistResults.clear();
    albumResults.clear();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    textController.dispose();
    super.onClose();
  }
}
