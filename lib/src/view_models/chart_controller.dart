import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/constants/app_urls.dart';
import '../data/repositories/song_repository.dart';

class ChartController extends GetxController {
  final SongRepository _songRepository = SongRepository();
  var isLoading = true.obs;
  var topSongsData = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTrendingTop();
  }

  Future<void> fetchTrendingTop() async {
    try {
      isLoading(true);
      final response = await _songRepository.fetchTrendingTop();

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          topSongsData.value = List<Map<String, dynamic>>.from(data['data']);
        }
      }
    } catch (e) {
      print("Lỗi fetch bảng xếp hạng: $e");
    } finally {
      isLoading(false);
    }
  }
}
