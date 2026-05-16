import 'dart:convert';
import 'package:app_nghenhac/src/core/constants/app_urls.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../data/models/category_model.dart';

class CategoryController extends GetxController {
  var isLoading = false.obs;
  var categories = <CategoryModel>[].obs;

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final response = await http.get(Uri.parse(AppUrls.listCategory));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          categories.value = (data['categories'] as List)
              .map((e) => CategoryModel.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      print("Lỗi tải category: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
