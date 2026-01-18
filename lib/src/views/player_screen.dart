import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart'; // Import để dùng LoopMode enum
import '../view_models/player_controller.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PlayerController controller = Get.find<PlayerController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Column(
          children: [
            const Text(
              "ĐANG PHÁT TỪ PLAYLIST",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
            // Obx ở đây là đúng vì currentSong có thể thay đổi (dù bạn đang hardcode text "Danh sách phát")
            // Tuy nhiên, nếu muốn hiển thị tên playlist động, bạn cần biến controller.playlistName.value
            // Hiện tại tôi giữ nguyên Text tĩnh và bỏ Obx để tránh lỗi "Improper use" nếu không có biến động.
            const Text(
              "Danh sách phát",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Spacer(),

            // 1. ẢNH BÌA (Obx đúng vì lắng nghe currentSong.value)
            Obx(
              () => Container(
                height: 320,
                width: 320,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(
                      controller.currentSong.value?.imageUrl ?? "",
                    ),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 2. THÔNG TIN BÀI HÁT (Obx đúng vì lắng nghe currentSong.value)
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.currentSong.value?.title ?? "Unknown",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.currentSong.value?.artist ??
                              "Unknown Artist",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      // TODO: Add to favorites
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3. PROGRESS BAR (Obx đúng vì lắng nghe progress.value, totalDuration.value...)
            Obx(
              () => ProgressBar(
                progress: controller.progress.value,
                total: controller.totalDuration.value,
                buffered: controller.buffered.value,
                onSeek: controller.seek,
                baseBarColor: Colors.white24,
                progressBarColor: Colors.white,
                bufferedBarColor: Colors.white38,
                thumbColor: Colors.white,
                barHeight: 4.0,
                thumbRadius: 6.0,
                timeLabelTextStyle: const TextStyle(color: Colors.white70),
              ),
            ),

            const SizedBox(height: 20),

            // 4. CÁC NÚT ĐIỀU KHIỂN CHÍNH
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Nút Shuffle (Obx đúng vì lắng nghe isShuffleMode.value)
                Obx(
                  () => IconButton(
                    icon: Icon(
                      Icons.shuffle,
                      color: controller.isShuffleMode.value
                          ? const Color(0xFF30e87a)
                          : Colors.white70,
                      size: 28,
                    ),
                    onPressed: () => controller.toggleShuffle(),
                  ),
                ),

                // Nút Previous (KHÔNG CẦN Obx vì icon/color tĩnh)
                IconButton(
                  icon: const Icon(
                    Icons.skip_previous,
                    color: Colors.white,
                    size: 36,
                  ),
                  onPressed: () => controller.previousSong(),
                ),

                // Nút Play/Pause (Obx đúng vì lắng nghe isPlaying.value)
                Obx(
                  () => Container(
                    height: 64,
                    width: 64,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        controller.isPlaying.value
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.black,
                        size: 36,
                      ),
                      onPressed: () => controller.togglePlay(),
                    ),
                  ),
                ),

                // Nút Next (KHÔNG CẦN Obx vì icon/color tĩnh)
                IconButton(
                  icon: const Icon(
                    Icons.skip_next,
                    color: Colors.white,
                    size: 36,
                  ),
                  onPressed: () => controller.nextSong(),
                ),

                // Nút Repeat (Obx đúng vì lắng nghe loopMode.value)
                Obx(() {
                  // Khởi tạo giá trị mặc định để tránh lỗi null
                  IconData icon = Icons.repeat;
                  Color color = Colors.white70;

                  switch (controller.loopMode.value) {
                    case LoopMode.off:
                      icon = Icons.repeat;
                      color = Colors.white70;
                      break;
                    case LoopMode.all:
                      icon = Icons.repeat;
                      color = const Color(0xFF30e87a);
                      break;
                    case LoopMode.one:
                      icon = Icons.repeat_one;
                      color = const Color(0xFF30e87a);
                      break;
                  }
                  return IconButton(
                    icon: Icon(icon, color: color, size: 28),
                    onPressed: () => controller.cycleLoopMode(),
                  );
                }),
              ],
            ),

            const Spacer(),

            // Bottom devices/list button (Tĩnh, không cần Obx)
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.speaker_group_outlined,
                  color: Colors.white70,
                  size: 20,
                ),
                Icon(Icons.playlist_play, color: Colors.white70, size: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
