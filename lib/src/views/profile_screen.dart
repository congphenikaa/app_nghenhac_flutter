import 'package:app_nghenhac/src/views/edit_profile_screen.dart';
import 'package:app_nghenhac/src/views/liked_songs_screen.dart';
import 'package:app_nghenhac/src/views/saved_playlists_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../view_models/auth_controller.dart';
import '../view_models/library_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Tìm AuthController để lấy dữ liệu user
    final AuthController authController = Get.find<AuthController>();
    // Tìm hoặc tạo LibraryController để lấy số lượng playlist thực tế
    final LibraryController libraryController = Get.put(LibraryController());

    // Gọi fetchMyPlaylists ngay khi vào màn hình này để đảm bảo số liệu chính xác
    // Dùng addPostFrameCallback để tránh lỗi setState trong quá trình build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      libraryController.fetchMyPlaylists();
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
      // Dùng Obx để tự động cập nhật UI khi user hoặc library thay đổi
      body: Obx(() {
        final user = authController.currentUser.value;

        // Nếu đang tải hoặc chưa có user
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // Xử lý ảnh đại diện fallback
        final avatarUrl = (user.avatar.isNotEmpty)
            ? user.avatar
            : "https://i.pravatar.cc/150?img=11";

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // --- AVATAR ---
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: CachedNetworkImageProvider(avatarUrl),
                ),
              ),
              const SizedBox(height: 16),

              // --- TÊN & EMAIL ---
              Text(
                user.username,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                user.email,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 8),

              // Nút chỉnh sửa
              OutlinedButton(
                onPressed: () {
                  Get.to(() => const EditProfileScreen());
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Chỉnh sửa hồ sơ",
                  style: TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(height: 24),

              // --- THỐNG KÊ ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Cập nhật: Lấy số lượng từ LibraryController (Playlist thực tế đang có)
                  // Thay vì user.savedPlaylistIds.length vì nó có thể chưa sync kịp
                  _buildStatItem(
                    "${libraryController.myPlaylists.length}",
                    "Playlist",
                  ),
                  _buildStatItem(
                    "${user.followedArtistIds.length}",
                    "Following",
                  ),
                  // Tạm thời hiển thị 0 follower vì model chưa có list followerIds
                  _buildStatItem("0", "Followers"),
                ],
              ),

              const SizedBox(height: 32),

              // --- MENU ---
              _buildProfileMenuItem(
                icon: Icons.favorite,
                iconColor: Colors.white,
                bgIconColor: const Color(0xFF450af5),
                title: "Bài hát đã thích",
                // Dùng biến likedSongIds để hiển thị số lượng bài hát đã thích
                subtitle: "${user.likedSongIds.length} bài hát",
                onTap: () {
                  // Điều hướng sang màn hình LikedSongsScreen
                  Get.to(() => const LikedSongsScreen());
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.queue_music,
                iconColor: Colors.grey,
                bgIconColor: const Color(0xFF282828),
                title: "Danh sách phát",
                subtitle: "Của bạn và đã lưu",
                onTap: () {
                  Get.to(() => const SavedPlaylistsScreen());
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.settings,
                iconColor: Colors.grey,
                bgIconColor: const Color(0xFF282828),
                title: "Cài đặt",
                subtitle: "Tài khoản, Audio, Quyền riêng tư",
                onTap: () {},
              ),

              // Nút Đăng xuất
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

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required Color iconColor,
    required Color bgIconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: bgIconColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
