import 'package:app_nghenhac/src/core/routes/app_pages.dart';
import 'package:app_nghenhac/src/view_models/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../view_models/artist_request_controller.dart';

class ArtistRequestStatusScreen extends StatelessWidget {
  const ArtistRequestStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ArtistRequestController requestController =
        Get.find<ArtistRequestController>();
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Trạng thái đơn đề xuất"),
      ),
      body: Obx(() {
        final request = requestController.myRequest.value;

        if (request == null) {
          return const Center(
            child: Text(
              "Không tìm thấy đơn đề xuất",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thông tin cơ bản
              _buildSectionTitle("Thông tin đơn"),
              _buildInfoRow("Tên nghệ sĩ", request.artistName),
              _buildInfoRow("Giới thiệu", request.bio),
              _buildInfoRow("Lý do", request.reason),
              const SizedBox(height: 24),

              // Trạng thái
              _buildSectionTitle("Trạng thái"),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D2E24),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange),
                    const SizedBox(width: 12),
                    Text(
                      request.status.toUpperCase(),
                      style: TextStyle(
                        color: request.status == 'approved'
                            ? Colors.greenAccent
                            : request.status == 'rejected'
                            ? Colors.redAccent
                            : Colors.orange,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              if (request.adminNote != null &&
                  request.adminNote!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSectionTitle("Ghi chú từ Admin"),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    request.adminNote!,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // Nút Refresh khi đã được duyệt
              if (request.status == 'approved')
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final token = prefs.getString('token') ?? '';

                      await authController.fetchUserProfile(
                        authController.currentUser.value?.id ?? '',
                        token, // ← Truyền thêm token
                      );

                      Get.offAllNamed(AppRoutes.MAIN);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF30e87a),
                      foregroundColor: Colors.black,
                    ),
                    child: const Text(
                      "Làm mới hồ sơ & vào Studio",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

              if (request.status == 'pending')
                Column(
                  children: [
                    const Center(
                      child: Text(
                        "Đơn của bạn đang được xem xét.\nVui lòng chờ thông báo từ Admin.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton(
                      onPressed: () async {
                        final confirm = await Get.dialog<bool>(
                          AlertDialog(
                            title: const Text("Xác nhận hủy đơn"),
                            content: const Text(
                              "Bạn có chắc chắn muốn hủy đơn này không?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(result: false),
                                child: const Text("Không"),
                              ),
                              TextButton(
                                onPressed: () => Get.back(result: true),
                                child: const Text("Có, hủy đơn"),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          final success = await requestController
                              .cancelRequest();
                          if (success) {
                            Get.back(); // Quay lại ProfileScreen
                          }
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text(
                        "Hủy đơn",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            value.isNotEmpty ? value : "—",
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
