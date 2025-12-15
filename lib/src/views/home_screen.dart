import 'package:app_nghenhac/src/view_models/auth_controller.dart';
import 'package:app_nghenhac/src/view_models/player_controller.dart';
import 'package:app_nghenhac/src/views/player_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../view_models/home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Khởi tạo Controller
    final HomeController controller = Get.put(HomeController());

    final PlayerController playerController = Get.put(PlayerController());
    final AuthController authController = Get.put(AuthController());

    return Scaffold(
      backgroundColor: Colors.black, // Nền đen chuẩn Spotify
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Chào buổi tối",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => controller.fetchSongs(),
          ),
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ), // Icon logout chuẩn
            tooltip: 'Đăng xuất', // Hiển thị chữ khi giữ chuột/tay lâu
            onPressed: () {
              Get.defaultDialog(
                title: "Đăng xuất",
                middleText: "Bạn có chắc chắn muốn đăng xuất không?",
                textConfirm: "Đồng ý",
                textCancel: "Hủy",
                confirmTextColor: Colors.white,
                onConfirm: () {
                  authController.logout(); // Chỉ gọi logout khi bấm Đồng ý
                },
              );
            },
          ),
        ],
      ),
      // Dùng Obx để lắng nghe thay đổi từ Controller
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1DB954)),
          );
        }

        if (controller.songList.isEmpty) {
          return const Center(
            child: Text(
              "Chưa có bài hát nào",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.songList.length,
          itemBuilder: (context, index) {
            final song = controller.songList[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                // Ảnh bìa
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CachedNetworkImage(
                    imageUrl: song.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: Colors.grey[800]),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
                // Tên bài hát
                title: Text(
                  song.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                // Mô tả / Ca sĩ
                subtitle: Text(
                  song.description,
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // Nút option
                trailing: const Icon(Icons.more_vert, color: Colors.grey),
                onTap: () {
                  // 1. phat nhac
                  playerController.playSong(song);

                  // 2. chuyen den player screen (truot len giong spotify)
                  Get.to(
                    () => const PlayerScreen(),
                    transition: Transition.downToUp,
                    duration: const Duration(milliseconds: 300),
                  );
                },
              ),
            );
          },
        );
      }),
    );
  }
}
