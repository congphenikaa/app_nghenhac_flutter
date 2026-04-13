import 'package:app_nghenhac/src/core/routes/app_pages.dart';
import 'package:app_nghenhac/src/view_models/auth_controller.dart';
import 'package:app_nghenhac/src/view_models/player_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final PlayerController controller = Get.find<PlayerController>();
    final AuthController authController = Get.find<AuthController>();

    return Obx(() {
      if (controller.currentSong.value == null) {
        return const SizedBox.shrink();
      }

      if (controller.isPlayerScreenOpen.value) {
        return const SizedBox.shrink();
      }

      if (controller.hideMiniPlayer.value) {
        return const SizedBox.shrink();
      }

      final song = controller.currentSong.value!;

      final isLiked =
          authController.currentUser.value?.likedSongIds.contains(song.id) ??
          false;

      return GestureDetector(
        onTap: () {
          controller.isPlayerScreenOpen.value = true;
          Get.toNamed(AppRoutes.PLAYER)?.then((value) {
            controller.isPlayerScreenOpen.value = false;
          });
        },
        child: Container(
          height: 58, // Tối ưu chiều cao thanh mảnh hơn
          margin: const EdgeInsets.only(
            left: 8,
            right: 8,
            bottom: 8,
          ), // Cách đáy một chút
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Color.lerp(
              controller.dominantColor.value,
              Colors.black,
              0.8,
            ),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // --- NỘI DUNG CHÍNH ---
              Padding(
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 4,
                ), // Ép lề cân đối
                child: Row(
                  children: [
                    // 1. Ảnh bìa
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: CachedNetworkImage(
                        imageUrl: song.imageUrl,
                        width: 42,
                        height: 42,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: Colors.grey[800]),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.music_note, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // 2. Tiêu đề & Ca sĩ
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            style: TextStyle(
                              color: isLiked
                                  ? const Color(0xFF1DB954)
                                  : Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            song.artist,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.65),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // --- KHỐI NÚT BẤM CÂN ĐỐI ---
                    // 3. Nút Thả tim
                    IconButton(
                      padding: EdgeInsets.zero,
                      // Cấp vùng bấm 44x44 chuẩn ngón tay, tự tạo khoảng cách vô hình
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked
                            ? const Color(0xFF1DB954)
                            : Colors.white70,
                        size: 24, // Nhỏ gọn
                      ),
                      onPressed: () => authController.toggleLikeSong(song.id),
                    ),

                    // 4. Nút Play/Pause
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                      icon: Icon(
                        controller.isPlaying.value
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 32, // Đồng đều với nút Next
                      ),
                      onPressed: () => controller.togglePlay(),
                    ),

                    // 5. Nút Next
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                      icon: const Icon(
                        Icons.skip_next,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: () => controller.nextSong(),
                    ),
                  ],
                ),
              ),

              // --- THANH TIẾN TRÌNH ---
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Obx(() {
                  if (controller.totalDuration.value.inSeconds == 0) {
                    return const SizedBox();
                  }

                  return LinearProgressIndicator(
                    value:
                        controller.progress.value.inSeconds /
                        (controller.totalDuration.value.inSeconds > 0
                            ? controller.totalDuration.value.inSeconds
                            : 1),
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    minHeight: 2,
                  );
                }),
              ),
            ],
          ),
        ),
      );
    });
  }
}
