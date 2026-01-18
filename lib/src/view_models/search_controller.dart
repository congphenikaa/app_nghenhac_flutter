import 'dart:async';
import 'dart:convert';
import 'package:app_nghenhac/src/configs/app_urls.dart';
import 'package:app_nghenhac/src/models/song_model.dart';
import 'package:app_nghenhac/src/models/artist_model.dart';
import 'package:app_nghenhac/src/models/album_model.dart';
import 'package:app_nghenhac/src/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class SearchPageController extends GetxController {
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

    // Lắng nghe text controller để cập nhật biến searchText
    textController.addListener(() {
      searchText.value = textController.text;
    });
  }

  @override
  void onClose() {
    _debounce?.cancel();
    textController.dispose();
    super.onClose();
  }

  // Hàm load danh sách Category (Browse All)
  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse(AppUrls.listCategory));
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
    // Cập nhật biến Rx ngay lập tức để UI (nút X) phản hồi
    searchText.value = query;

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchGlobal(query);
    });
  }

  // Gọi API tìm kiếm
  Future<void> searchGlobal(String query) async {
    if (query.isEmpty) {
      clearResults();
      return;
    }

    try {
      isLoading.value = true;
      final url = '${AppUrls.searchSong}?query=$query';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          // Parse Songs
          final List<dynamic> sList = data['songs'] ?? [];
          songResults.value = sList.map((e) => SongModel.fromJson(e)).toList();

          // Parse Artists
          final List<dynamic> aList = data['artists'] ?? [];
          artistResults.value = aList
              .map((e) => ArtistModel.fromJson(e))
              .toList();

          // Parse Albums
          final List<dynamic> alList = data['albums'] ?? [];
          albumResults.value = alList
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
}
