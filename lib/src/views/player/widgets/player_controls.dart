import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../../../view_models/player_controller.dart';
import '../../../view_models/auth_controller.dart';

class PlayerControls extends StatelessWidget {
  final VoidCallback onShowSpeedMenu;
  final VoidCallback onShowShareMenu;
  final VoidCallback onShowQueueMenu;
  final VoidCallback onShowTimerMenu;

  const PlayerControls({
    super.key,
    required this.onShowSpeedMenu,
    required this.onShowShareMenu,
    required this.onShowQueueMenu,
    required this.onShowTimerMenu,
  });

  @override
  Widget build(BuildContext context) {
    final PlayerController controller = Get.find<PlayerController>();
    final AuthController authController = Get.find<AuthController>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // THÔNG TIN BÀI HÁT
        Obx(() {
          final currentSong = controller.currentSong.value;
          final isLiked = authController.currentUser.value?.likedSongIds.contains(
            currentSong?.id,
          ) ?? false;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentSong?.title ?? "Unknown",
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
                      currentSong?.artist ?? "Unknown Artist",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? const Color(0xFF30e87a) : Colors.white,
                  size: 28,
                ),
                onPressed: () {
                  if (currentSong != null) {
                    authController.toggleLikeSong(currentSong.id);
                  }
                },
              ),
            ],
          );
        }),

        const SizedBox(height: 16),

        // PROGRESS BAR
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
            timeLabelTextStyle: const TextStyle(
              color: Colors.white70,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ĐIỀU KHIỂN PHÁT NHẠC
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
            IconButton(
              icon: const Icon(
                Icons.skip_previous,
                color: Colors.white,
                size: 36,
              ),
              onPressed: () => controller.previousSong(),
            ),
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
                    controller.isPlaying.value ? Icons.pause : Icons.play_arrow,
                    color: Colors.black,
                    size: 36,
                  ),
                  onPressed: () => controller.togglePlay(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.skip_next,
                color: Colors.white,
                size: 36,
              ),
              onPressed: () => controller.nextSong(),
            ),
            Obx(() {
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

        const SizedBox(height: 16),

        // HÀNG NÚT SPEED & CHỨC NĂNG THÊM (SHARE, QUEUE, TIMER)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
              () => GestureDetector(
                onTap: onShowSpeedMenu,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white70),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "${controller.playbackSpeed.value}x",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.share_outlined,
                    color: Colors.white70,
                    size: 22,
                  ),
                  onPressed: onShowShareMenu,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.queue_music,
                    color: Colors.white70,
                    size: 24,
                  ),
                  onPressed: onShowQueueMenu,
                ),
                Obx(
                  () => IconButton(
                    icon: Icon(
                      Icons.timer_outlined,
                      color: controller.isTimerActive.value
                          ? const Color(0xFF30e87a)
                          : Colors.white70,
                      size: 22,
                    ),
                    onPressed: onShowTimerMenu,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
