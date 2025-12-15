import 'dart:convert';
import 'package:get/get.dart';
import 'package:app_nghenhac/src/configs/app_urls.dart';
import 'package:app_nghenhac/src/models/song_model.dart';
import 'package:http/http.dart' as http;

class HomeController extends GetxController {
  var isLoading = true.obs;
  var songList = <SongModel>[].obs;

  @override
  void onInit() {
    fetchSongs();
    super.onInit();
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
}
