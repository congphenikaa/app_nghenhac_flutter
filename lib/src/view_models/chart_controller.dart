import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../configs/app_urls.dart';

class ChartController extends GetxController {
  var isLoading = true.obs;
  var topSongsData = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Đổi tên hàm
    fetchTrendingTop();
  }

  Future<void> fetchTrendingTop() async {
    try {
      isLoading(true);
      // Gọi đúng biến AppUrls.topTrending
      final response = await http.get(Uri.parse(AppUrls.topTrending));

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
