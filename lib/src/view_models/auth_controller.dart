import 'dart:convert';
import 'package:app_nghenhac/src/views/home_screen.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../configs/app_urls.dart';
import '../views/auth/login_screen.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;

  // Kiểm tra xem user đã đăng nhập chưa khi mở app
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      Get.offAll(() => const HomeScreen()); // Vào thẳng trang chủ
    } else {
      Get.offAll(() => const LoginScreen()); // Về trang đăng nhập
    }
  }

  // Hàm Đăng Nhập
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;

      final response = await http.post(
        Uri.parse(AppUrls.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        // 1. Lưu token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);

        // 2. Chuyển sang màn hình chính (Xóa hết lịch sử back)
        Get.offAll(() => const HomeScreen());
        Get.snackbar("Thành công", "Chào mừng quay trở lại!");
      } else {
        Get.snackbar("Lỗi", data['message'] ?? "Đăng nhập thất bại");
      }
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể kết nối server");
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Hàm Đăng Ký
  Future<void> register(String name, String email, String password) async {
    try {
      isLoading.value = true;

      final response = await http.post(
        Uri.parse(AppUrls.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': name,
          'email': email,
          'password': password,
          'gender': 'other', // Tạm thời set mặc định để backend không báo lỗi
        }),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        // 1. Lưu token (Backend trả về token ngay sau khi đk thành công)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['user']['token']);

        // 2. Vào thẳng trang chủ
        Get.offAll(() => const HomeScreen());
        Get.snackbar("Thành công", "Tạo tài khoản thành công!");
      } else {
        Get.snackbar(
          "Đăng ký thất bại",
          data['message'] ?? "Lỗi không xác định",
        );
      }
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể kết nối server");
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Hàm Đăng Xuất
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Get.offAll(() => const LoginScreen());
  }
}
