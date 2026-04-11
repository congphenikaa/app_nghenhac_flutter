import 'package:app_nghenhac/src/view_models/auth_controller.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../view_models/player_controller.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  // MENU HẸN GIỜ
  void _showSleepTimerMenu(BuildContext context, PlayerController controller) {
    // Hàm phụ giúp tạo các tuỳ chọn Hẹn Giờ để tái sử dụng code và dùng Obx
    Widget buildOption(String title, int minutes, IconData icon) {
      return Obx(() {
        final isSelected = controller.selectedSleepMinutes.value == minutes;
        return ListTile(
          leading: Icon(
            icon,
            color: isSelected ? const Color(0xFF30e87a) : Colors.white,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isSelected ? const Color(0xFF30e87a) : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          trailing: isSelected
              ? const Icon(Icons.check, color: const Color(0xFF30e87a))
              : null,
          onTap: () {
            // 1. Cập nhật UI ngay lập tức để hiện dấu check màu xanh
            controller.selectedSleepMinutes.value = minutes;

            // 2. Thêm delay 250ms để user kịp thấy hiệu ứng
            Future.delayed(const Duration(milliseconds: 250), () {
              // 3. ĐÓNG BOTTOM SHEET TRƯỚC
              if (Get.isBottomSheetOpen == true) Get.back();

              // 4. GỌI LOGIC TỪ CONTROLLER SAU CÙNG (Để Snackbar không đè lên Get.back)
              controller.setSleepTimer(minutes);
            });
          },
        );
      });
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Hẹn giờ tắt nhạc",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            buildOption("Hết bài hát hiện tại", 0, Icons.music_off),
            buildOption("15 Phút", 15, Icons.access_time),
            buildOption("30 Phút", 30, Icons.access_time),
            buildOption("1 Giờ", 60, Icons.access_time),
            // Luôn hiển thị nút tắt hẹn giờ
            Obx(() {
              final isOff = controller.selectedSleepMinutes.value == -1;
              return ListTile(
                leading: const Icon(Icons.timer_off, color: Colors.redAccent),
                title: const Text(
                  "Tắt hẹn giờ",
                  style: TextStyle(color: Colors.redAccent),
                ),
                trailing: isOff
                    ? const Icon(Icons.check, color: Colors.redAccent)
                    : null,
                onTap: () {
                  // 1. Cập nhật UI ngay
                  controller.selectedSleepMinutes.value = -1;

                  // 2. Chờ 250ms
                  Future.delayed(const Duration(milliseconds: 250), () {
                    // 3. Đóng Menu trước
                    if (Get.isBottomSheetOpen == true) Get.back();

                    // 4. Hủy giờ và hiển thị thông báo
                    controller.cancelSleepTimer();
                    Get.snackbar(
                      "Hẹn giờ",
                      "Đã tắt bộ đếm giờ",
                      colorText: Colors.white,
                      backgroundColor: const Color(0xFF1C2E24),
                    );
                  });
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  // MENU TỐC ĐỘ PHÁT
  void _showSpeedMenu(BuildContext context, PlayerController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Tốc độ phát",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...[0.75, 1.0, 1.25, 1.5, 2.0].map(
              (speed) => Obx(
                () => ListTile(
                  title: Text(
                    "${speed}x",
                    style: TextStyle(
                      color: controller.playbackSpeed.value == speed
                          ? const Color(0xFF30e87a)
                          : Colors.white,
                      fontWeight: controller.playbackSpeed.value == speed
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: controller.playbackSpeed.value == speed
                      ? const Icon(Icons.check, color: Color(0xFF30e87a))
                      : null,
                  onTap: () {
                    controller.playbackSpeed.value =
                        speed; // Đổi màu ngay lập tức
                    Future.delayed(const Duration(milliseconds: 250), () {
                      if (Get.isBottomSheetOpen == true) Get.back();
                      controller.changeSpeed(
                        speed,
                      ); // Cập nhật tốc độ audio sau
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final PlayerController controller = Get.find<PlayerController>();
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.black,
      // TÍNH NĂNG 1: DYNAMIC BACKGROUND
      body: Obx(
        () => AnimatedContainer(
          duration: const Duration(milliseconds: 800), // Hiệu ứng chuyển màu
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                controller.dominantColor.value.withOpacity(0.8), // Màu nền động
                Colors.black,
                Colors.black,
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // HÀNG APP BAR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                        ),
                        onPressed: () => Get.back(),
                      ),
                      const Column(
                        children: [
                          Text(
                            "ĐANG PHÁT",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            "Danh sách phát",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onPressed: () {}, // Sẽ làm ở Nhóm 2 - Menu tùy chọn
                      ),
                    ],
                  ),

                  const Spacer(),

                  // TÍNH NĂNG 3: VUỐT CHUYỂN BÀI
                  GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity != null) {
                        if (details.primaryVelocity! > 0) {
                          controller.previousSong(); // Vuốt sang phải
                        } else if (details.primaryVelocity! < 0) {
                          controller.nextSong(); // Vuốt sang trái
                        }
                      }
                    },
                    child: Obx(
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
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // THÔNG TIN BÀI HÁT
                  Obx(() {
                    final currentSong = controller.currentSong.value;
                    final isLiked =
                        authController.currentUser.value?.likedSongIds.contains(
                          currentSong?.id,
                        ) ??
                        false;

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
                            color: isLiked
                                ? const Color(0xFF30e87a)
                                : Colors.white,
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

                  const SizedBox(height: 20),

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

                  const SizedBox(height: 20),

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

                  const Spacer(),

                  // TÍNH NĂNG 2 VÀ 4: HÀNG NÚT SPEED & TIMER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(
                        () => GestureDetector(
                          onTap: () => _showSpeedMenu(context, controller),
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
                            onPressed:
                                () {}, // Dành cho tính năng Share ở Nhóm 2
                          ),
                          Obx(
                            () => IconButton(
                              // Nếu đang có Timer, icon đổi sang Xanh Spotify
                              icon: Icon(
                                Icons.timer_outlined,
                                color: controller.isTimerActive.value
                                    ? const Color(0xFF30e87a)
                                    : Colors.white70,
                                size: 22,
                              ),
                              onPressed: () =>
                                  _showSleepTimerMenu(context, controller),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
