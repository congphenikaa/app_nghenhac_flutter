import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../view_models/player_controller.dart';
import 'player_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final PlayerController controller = Get.find<PlayerController>();

    return Obx(() {
      if (controller.currentSong.value == null) {
        return const SizedBox.shrink();
      }

      if (controller.isPlayerScreenOpen.value) {
        return const SizedBox.shrink();
      }

      final song = controller.currentSong.value!;

      return GestureDetector(
        onTap: () {
          controller.isPlayerScreenOpen.value = true;
          Get.to(
            () => const PlayerScreen(),
            transition: Transition.downToUp,
            duration: const Duration(milliseconds: 300),
          )?.then((value) {
            controller.isPlayerScreenOpen.value = false;
          });
        },
        child: Container(
          height: 70,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          // Bỏ padding ở đây để Progress Bar có thể tràn viền
          // padding: const EdgeInsets.symmetric(horizontal: 12),

          // Thêm thuộc tính này để cắt các phần thừa (Progress Bar) theo bo góc
          clipBehavior: Clip.hardEdge,

          decoration: BoxDecoration(
            color: const Color(0xFF1C2E24),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),

          // Dùng Stack để xếp chồng Progress Bar lên đáy
          child: Stack(
            alignment: Alignment.bottomCenter, // Căn đáy
            children: [
              // 1. Nội dung chính (Row) - Cần bọc Padding ở đây
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    // Ảnh nhỏ
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: CachedNetworkImage(
                        imageUrl: song.imageUrl,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: Colors.grey[800]),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.music_note),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Tên bài hát
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            song.description,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Nút Play/Pause
                    IconButton(
                      icon: Obx(
                        () => Icon(
                          controller.isPlaying.value
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_fill,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      onPressed: () => controller.togglePlay(),
                    ),
                  ],
                ),
              ),

              // 2. Thanh tiến trình (Code bạn thêm vào)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Obx(() {
                  // Tránh chia cho 0
                  if (controller.totalDuration.value.inSeconds == 0)
                    return const SizedBox();

                  return LinearProgressIndicator(
                    value:
                        controller.progress.value.inSeconds /
                        (controller.totalDuration.value.inSeconds > 0
                            ? controller.totalDuration.value.inSeconds
                            : 1),
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.green,
                    ), // Hoặc Color(0xFF30e87a)
                    minHeight: 3, // Tăng nhẹ độ dày để dễ nhìn hơn
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
