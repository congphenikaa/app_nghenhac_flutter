import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../view_models/player_controller.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Tìm Controller đã được tạo (sẽ được put từ Home)
    final PlayerController controller = Get.find<PlayerController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          onPressed: () => Get.back(), // Quay lại Home
        ),
        title: const Text(
          "Đang phát",
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Spacer(),

            // 1. ẢNH BÌA
            Obx(
              () => Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(
                      controller.currentSong.value?.imageUrl ?? "",
                    ),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // 2. THÔNG TIN BÀI HÁT
            Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.currentSong.value?.title ?? "Unknown",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    controller.currentSong.value?.description ??
                        "Unknown Artist",
                    style: TextStyle(color: Colors.grey[400], fontSize: 18),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3. THANH TRƯỢT (PROGRESS BAR)
            Obx(
              () => ProgressBar(
                progress: controller.progress.value,
                total: controller.totalDuration.value,
                buffered: controller.buffered.value,
                onSeek: (duration) {
                  controller.seek(duration);
                },
                baseBarColor: Colors.grey[600],
                progressBarColor: Colors.white,
                bufferedBarColor: Colors.grey[400],
                thumbColor: Colors.white,
                timeLabelTextStyle: const TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 20),

            // 4. CÁC NÚT ĐIỀU KHIỂN
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const IconButton(
                  icon: Icon(Icons.shuffle, color: Colors.grey),
                  onPressed: null,
                ),
                const IconButton(
                  icon: Icon(
                    Icons.skip_previous,
                    color: Colors.white,
                    size: 40,
                  ),
                  onPressed: null,
                ),

                // Nút Play/Pause chính
                Obx(
                  () => IconButton(
                    icon: Icon(
                      controller.isPlaying.value
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_fill,
                      color: Colors.white,
                      size: 80,
                    ),
                    onPressed: () => controller.togglePlay(),
                  ),
                ),

                const IconButton(
                  icon: Icon(Icons.skip_next, color: Colors.white, size: 40),
                  onPressed: null,
                ),
                const IconButton(
                  icon: Icon(Icons.repeat, color: Colors.grey),
                  onPressed: null,
                ),
              ],
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
