import 'dart:convert';
import 'package:app_nghenhac/src/views/main_wrapper.dart';
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
      Get.offAll(() => const MainWrapper()); // Vào thẳng trang chủ
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
        final prefs = await SharedPreferences.getInstance();

        // 1. Lưu token
        if (data['token'] != null) {
          await prefs.setString('token', data['token']);
        }

        // 2. [QUAN TRỌNG] Lưu User ID
        // Kiểm tra cấu trúc response từ backend xem user id nằm ở đâu.
        // Thường là data['user']['_id'] hoặc data['user']['id']
        // Dựa vào code backend login/register thường thấy, nó sẽ trả về object user.
        if (data['user'] != null && data['user']['_id'] != null) {
          // Hoặc data['userId'] tùy backend
          await prefs.setString('userId', data['user']['_id']);
          print("Đã lưu UserId: ${data['user']['_id']}");
        } else {
          print(
            "Cảnh báo: Không tìm thấy userId trong response. Kiểm tra lại backend.",
          );
        }

        // 2. Chuyển sang màn hình chính
        Get.offAll(() => const MainWrapper());
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
          'gender': 'other',
        }),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();

        // 1. Lưu token
        // Token có thể nằm ở data['token'] hoặc data['user']['token'] tùy backend
        String? token = data['token'];
        if (token == null && data['user'] != null) {
          token = data['user']['token'];
        }
        if (token != null) await prefs.setString('token', token);

        // 2. [QUAN TRỌNG] Lưu User ID
        if (data['user'] != null && data['user']['_id'] != null) {
          await prefs.setString('userId', data['user']['_id']);
          print("Đã lưu UserId sau đăng ký: ${data['user']['_id']}");
        }

        // 2. Vào thẳng trang chủ
        Get.offAll(() => const MainWrapper());
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
    await prefs.remove('userId'); // Nhớ xóa cả userId
    Get.offAll(() => const LoginScreen());
  }
}
