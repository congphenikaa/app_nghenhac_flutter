import 'dart:convert';
import 'package:app_nghenhac/src/configs/app_urls.dart';
import 'package:app_nghenhac/src/models/song_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class SearchPageController extends GetxController {
  var isLoading = false.obs;
  var searchResults = <SongModel>[].obs;
  final TextEditingController textController = TextEditingController();

  // Hàm gọi API tìm kiếm
  Future<void> searchSongs(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      isLoading.value = true;
      // Gọi API: /api/song/search?query=abc
      final url = '${AppUrls.searchSong}?query=$query';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> list = data['songs'] ?? [];
          searchResults.value = list.map((e) => SongModel.fromJson(e)).toList();
        }
      }
    } catch (e) {
      print("Lỗi tìm kiếm: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
