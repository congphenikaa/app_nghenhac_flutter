import 'dart:convert';
import 'package:app_nghenhac/src/data/models/artist_request_model.dart';
import 'package:app_nghenhac/src/data/repositories/artist_request_repository.dart';
import 'package:app_nghenhac/src/view_models/auth_controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ArtistRequestController extends GetxController {
  final ArtistRequestRepository _repository = ArtistRequestRepository();

  var isLoading = false.obs;
  var myRequest = Rxn<ArtistRequestModel>();

  /// Gửi đơn đề xuất
  Future<bool> submitRequest({
    required String artistName,
    required String bio,
    required String reason,
    List<String> genre = const [],
    Map<String, String> socialLinks = const {},
  }) async {
    try {
      isLoading.value = true;

      final response = await _repository.submitRequest(
        artistName: artistName,
        bio: bio,
        reason: reason,
        genre: genre,
        socialLinks: socialLinks,
      );

      if (response.statusCode == 201) {
        Get.snackbar("Thành công", "Đơn đã được gửi thành công!");
        await fetchMyRequest();
        return true;
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar("Lỗi", data['message'] ?? "Gửi đơn thất bại");
        return false;
      }
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể kết nối đến server");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Lấy đơn của user
  Future<void> fetchMyRequest() async {
    try {
      final response = await _repository.getMyRequest();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null) {
          myRequest.value = ArtistRequestModel.fromJson(data['data']);
        } else {
          myRequest.value = null;
        }
      }
    } catch (e) {
      print("Lỗi fetch request: $e");
    }
  }

  /// Hủy đơn (gọi API thật)
  Future<bool> cancelRequest() async {
    try {
      isLoading.value = true;

      final requestId = myRequest.value?.id;
      if (requestId == null) {
        Get.snackbar("Lỗi", "Không tìm thấy đơn để hủy");
        return false;
      }

      final response = await _repository.cancelRequest(requestId);

      if (response.statusCode == 200) {
        myRequest.value = null; // Xóa đơn khỏi state
        Get.snackbar("Thành công", "Đã hủy đơn đề xuất");
        return true;
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar("Lỗi", data['message'] ?? "Hủy đơn thất bại");
        return false;
      }
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể kết nối server");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Tự động refresh khi cần (có thể gọi từ ProfileScreen)
  Future<void> checkAndRefreshStatus() async {
    await fetchMyRequest();

    // Nếu đã approved thì tự động refresh user
    if (myRequest.value?.status == 'approved') {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final userId = prefs.getString('userId') ?? '';

      if (userId.isNotEmpty && token.isNotEmpty) {
        await Get.find<AuthController>().fetchUserProfile(userId, token);
      }
    }
  }
}
