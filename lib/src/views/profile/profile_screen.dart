import 'package:app_nghenhac/src/view_models/artist_request_controller.dart';
import 'package:app_nghenhac/src/views/profile/widgets/ArtistRequestStatusScreen.dart';
import 'package:app_nghenhac/src/views/profile/widgets/artist_request_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../library/library_screen.dart';
import '../library/liked_songs_screen.dart';
import '../../view_models/auth_controller.dart';
import '../../view_models/library_controller.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_menu_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final LibraryController libraryController = Get.put(LibraryController());
    final ArtistRequestController requestController =
        Get.find<ArtistRequestController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      libraryController.fetchMyPlaylists();
      requestController.checkAndRefreshStatus();
    });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Obx(() {
        final user = authController.currentUser.value;

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              ProfileHeader(user: user, libraryController: libraryController),
              const SizedBox(height: 32),
              ProfileMenuItem(
                icon: Icons.favorite,
                iconColor: Colors.white,
                bgIconColor: const Color(0xFF450af5),
                title: "Bài hát đã thích",
                subtitle: "${user.likedSongIds.length} bài hát",
                onTap: () {
                  Get.to(() => const LikedSongsScreen());
                },
              ),
              ProfileMenuItem(
                icon: Icons.queue_music,
                iconColor: Colors.grey,
                bgIconColor: const Color(0xFF282828),
                title: "Danh sách phát",
                subtitle: "Của bạn và đã lưu",
                onTap: () {
                  Get.to(() => const LibraryScreen());
                },
              ),

              Obx(() {
                final user = authController.currentUser.value;
                final request = requestController.myRequest.value;

                // Nếu đã là Artist thì không hiển thị nút đề xuất
                if (user != null && user.role == 'artist') {
                  return const SizedBox.shrink(); // Ẩn nút
                }

                if (request != null && request.status == 'pending') {
                  return ProfileMenuItem(
                    icon: Icons.hourglass_top,
                    iconColor: Colors.orange,
                    bgIconColor: Colors.orange.withOpacity(0.2),
                    title: "Đơn đang chờ duyệt",
                    subtitle:
                        "Đã gửi ngày ${request.createdAt.day}/${request.createdAt.month}",
                    onTap: () =>
                        Get.to(() => const ArtistRequestStatusScreen()),
                  );
                }

                return ProfileMenuItem(
                  icon: Icons.verified_user,
                  iconColor: Colors.white,
                  bgIconColor: const Color(0xFF1DB954),
                  title: "Đề xuất trở thành Artist",
                  subtitle: "Gửi đơn để trở thành nghệ sĩ",
                  onTap: () => Get.to(() => const ArtistRequestFormScreen()),
                );
              }),

              ProfileMenuItem(
                icon: Icons.settings,
                iconColor: Colors.grey,
                bgIconColor: const Color(0xFF282828),
                title: "Cài đặt",
                subtitle: "Tài khoản, Audio, Quyền riêng tư",
                onTap: () {},
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: InkWell(
                  onTap: () => authController.logout(),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.logout,
                            color: Colors.grey,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          "Đăng xuất",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
