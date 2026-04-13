import 'package:app_nghenhac/src/view_models/auth_controller.dart';
import 'package:app_nghenhac/src/view_models/library_controller.dart';
import 'package:app_nghenhac/src/view_models/home_controller.dart';
import 'package:app_nghenhac/src/views/album/album_detail_screen.dart';
import 'package:app_nghenhac/src/views/artist/artist_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/share_service.dart';
import '../../view_models/player_controller.dart';
import 'widgets/player_header.dart';
import 'widgets/player_artwork.dart';
import 'widgets/player_controls.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  // --- MENU CHIA SẺ CHUẨN SPOTIFY ---
  void _showShareMenu(BuildContext context, PlayerController controller) {
    final song = controller.currentSong.value;
    if (song == null) return;

    // QUAN TRỌNG: Thay domain dưới đây bằng URL Vercel của bạn
    // Vì ta đặt file ở thư mục api, nên link sẽ có dạng /api/song
    final String linkThucTe =
        "https://web-trung-gian.vercel.app/?id=${song.id}";

    Widget buildOption(
      IconData icon,
      String label,
      Color bgColor,
      Color iconColor,
      VoidCallback onTap,
    ) {
      return GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 80,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                maxLines: 2,
              ),
            ],
          ),
        ),
      );
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(top: 24, bottom: 32),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: song.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                        ),
                        Text(
                          song.artist,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 24),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. SAO CHÉP LIÊN KẾT
                  buildOption(
                    Icons.link,
                    "Sao chép\nliên kết",
                    Colors.white24,
                    Colors.white,
                    () {
                      Get.back();
                      Clipboard.setData(ClipboardData(text: linkThucTe));
                      Get.snackbar(
                        "Đã sao chép",
                        "Đã sao chép liên kết vào khay nhớ tạm",
                        colorText: Colors.white,
                        backgroundColor: const Color(0xFF1C2E24),
                      );
                    },
                  ),
                  const SizedBox(width: 16),

                  // 2. TẠO ẢNH SHARE LÊN STORY (Chức năng cũ, sinh ra ảnh 1080x1080)
                  buildOption(
                    Icons.camera_alt_outlined,
                    "Thẻ\nbài hát",
                    const Color(0xFF30e87a),
                    Colors.black,
                    () {
                      Get.back();
                      Future.delayed(const Duration(milliseconds: 300), () {
                        ShareService.shareSongToStory(
                          context,
                          song,
                          linkThucTe,
                        );
                      });
                    },
                  ),
                  const SizedBox(width: 16),

                  // 3. CHIA SẺ LINK VÀO TIN NHẮN (Zalo, FB) -> Bọn nó sẽ tự cào thẻ Meta sinh ra ảnh Cover!
                  buildOption(
                    Icons.more_horiz,
                    "Khác",
                    Colors.white24,
                    Colors.white,
                    () {
                      Get.back();
                      Future.delayed(const Duration(milliseconds: 300), () {
                        // BỎ SHARE ẢNH ĐI, CHỈ SHARE LINK
                        Share.share(
                          linkThucTe,
                          subject: 'Nghe bài hát ${song.title}',
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MENU THÊM VÀO PLAYLIST TỪ PLAYER ---
  void _showAddToPlaylistBottomSheet(
    BuildContext context,
    dynamic song,
    LibraryController libraryController,
  ) {
    if (libraryController.myPlaylists.isEmpty) {
      libraryController.fetchMyPlaylists();
    }

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.65,
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 32),
                  const Text(
                    "Thêm vào Playlist",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.close, color: Colors.grey, size: 26),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (libraryController.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF30e87a)),
                  );
                }

                if (libraryController.myPlaylists.isEmpty) {
                  return const Center(
                    child: Text(
                      "Bạn chưa có Playlist nào.\nHãy tạo Playlist mới trong Thư viện.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: libraryController.myPlaylists.length,
                  itemBuilder: (context, index) {
                    final playlist = libraryController.myPlaylists[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: CachedNetworkImage(
                          imageUrl: playlist.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              Container(color: Colors.grey[800]),
                        ),
                      ),
                      title: Text(
                        playlist.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        "${playlist.songIds.length} bài hát",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        Get.back();
                        libraryController.addSongToPlaylist(
                          playlist.id,
                          song.id,
                        );
                        Future.delayed(const Duration(milliseconds: 300), () {
                          Get.snackbar(
                            "Thành công",
                            "Đã thêm vào Playlist ${playlist.name}",
                            backgroundColor: const Color(0xFF1C2E24),
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP,
                            duration: const Duration(seconds: 2),
                            margin: const EdgeInsets.all(12),
                            icon: const Icon(
                              Icons.check_circle,
                              color: Color(0xFF30e87a),
                            ),
                          );
                        });
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // --- MENU TÙY CHỌN (3 CHẤM) ---
  void _showPlayerOptionsMenu(
    BuildContext context,
    PlayerController playerController,
    AuthController authController,
    LibraryController libraryController,
  ) {
    final song = playerController.currentSong.value;
    if (song == null) return;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CachedNetworkImage(
                    imageUrl: song.imageUrl,
                    width: 55,
                    height: 55,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.music_note, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        song.artist,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // GẮN HÀM SHARE MENU MỚI VÀO HEADER TÙY CHỌN
                IconButton(
                  icon: const Icon(Icons.share_outlined, color: Colors.white),
                  onPressed: () {
                    Get.back(); // Đóng menu
                    _showShareMenu(context, playerController);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.grey, height: 1),
            const SizedBox(height: 10),

            Obx(() {
              bool isLiked = false;
              if (authController.currentUser.value != null) {
                isLiked = authController.currentUser.value!.likedSongIds
                    .contains(song.id);
              }
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? const Color(0xFF30e87a) : Colors.white,
                  size: 28,
                ),
                title: Text(
                  isLiked ? "Đã thích" : "Thích",
                  style: TextStyle(
                    color: isLiked ? const Color(0xFF30e87a) : Colors.white,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  authController.toggleLikeSong(song.id);
                },
              );
            }),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.playlist_add,
                color: Colors.white,
                size: 28,
              ),
              title: const Text(
                "Thêm vào Playlist",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                Get.back();
                Future.delayed(const Duration(milliseconds: 300), () {
                  _showAddToPlaylistBottomSheet(
                    context,
                    song,
                    libraryController,
                  );
                });
              },
            ),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 28,
              ),
              title: const Text(
                "Xem Nghệ sĩ",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                Get.back();
                try {
                  final homeController = Get.find<HomeController>();
                  final artistIndex = homeController.artists.indexWhere(
                    (a) => a.name.toLowerCase() == song.artist.toLowerCase(),
                  );

                  if (artistIndex != -1) {
                    Get.to(
                      () => ArtistDetailScreen(
                        artist: homeController.artists[artistIndex],
                      ),
                    );
                  } else {
                    Get.snackbar(
                      "Thông báo",
                      "Chưa có thông tin chi tiết về nghệ sĩ ${song.artist}.",
                      backgroundColor: Colors.grey[900],
                      colorText: Colors.white,
                    );
                  }
                } catch (e) {
                  Get.snackbar(
                    "Thông báo",
                    "Dữ liệu nghệ sĩ chưa sẵn sàng.",
                    backgroundColor: Colors.grey[900],
                    colorText: Colors.white,
                  );
                }
              },
            ),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.album_outlined,
                color: Colors.white,
                size: 28,
              ),
              title: const Text(
                "Xem Album",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                Get.back();
                if (song.album.isEmpty ||
                    song.album.toLowerCase() == "unknown album") {
                  Get.snackbar(
                    "Thông báo",
                    "Bài hát này là một đĩa đơn hoặc không thuộc album nào.",
                    backgroundColor: Colors.grey[900],
                    colorText: Colors.white,
                  );
                  return;
                }

                try {
                  final homeController = Get.find<HomeController>();
                  final albumIndex = homeController.albums.indexWhere(
                    (a) => a.title.toLowerCase() == song.album.toLowerCase(),
                  );

                  if (albumIndex != -1) {
                    Get.to(
                      () => AlbumDetailScreen(
                        album: homeController.albums[albumIndex],
                      ),
                    );
                  } else {
                    Get.snackbar(
                      "Thông báo",
                      "Không tìm thấy thông tin album '${song.album}' của bài hát này.",
                      backgroundColor: Colors.grey[900],
                      colorText: Colors.white,
                    );
                  }
                } catch (e) {
                  Get.snackbar(
                    "Thông báo",
                    "Dữ liệu album chưa sẵn sàng.",
                    backgroundColor: Colors.grey[900],
                    colorText: Colors.white,
                  );
                }
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // --- MENU DANH SÁCH CHỜ (QUEUE) ---
  void _showQueueBottomSheet(
    BuildContext context,
    PlayerController controller,
  ) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.65,
        padding: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              "Danh sách chờ tiếp theo",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                final upcoming = controller.upcomingSongs;
                if (upcoming.isEmpty) {
                  return const Center(
                    child: Text(
                      "Không có bài hát nào tiếp theo",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: upcoming.length,
                  itemBuilder: (context, index) {
                    final song = upcoming[index];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: CachedNetworkImage(
                          imageUrl: song.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.music_note,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        song.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        song.artist,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(
                        Icons.drag_handle,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        Get.back();
                        controller.playSong(song);
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // --- MENU HẸN GIỜ ---
  void _showSleepTimerMenu(BuildContext context, PlayerController controller) {
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
            controller.selectedSleepMinutes.value = minutes;
            Future.delayed(const Duration(milliseconds: 250), () {
              if (Get.isBottomSheetOpen == true) Get.back();
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
                  controller.selectedSleepMinutes.value = -1;
                  Future.delayed(const Duration(milliseconds: 250), () {
                    if (Get.isBottomSheetOpen == true) Get.back();
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

  // --- MENU TỐC ĐỘ PHÁT ---
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
                    controller.playbackSpeed.value = speed;
                    Future.delayed(const Duration(milliseconds: 250), () {
                      if (Get.isBottomSheetOpen == true) Get.back();
                      controller.changeSpeed(speed);
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
    final LibraryController libraryController = Get.find<LibraryController>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(
        () => AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                controller.dominantColor.value.withOpacity(0.8),
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
                  PlayerHeader(
                    onShowOptions: () => _showPlayerOptionsMenu(
                      context,
                      controller,
                      authController,
                      libraryController,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ), // Thay Spacer() bằng khoảng cách tĩnh
                  const Expanded(
                    child: Center(
                      child:
                          PlayerArtwork(), // Artwork sẽ tự thu nhỏ/phóng to vừa khoảng trống
                    ),
                  ),
                  const SizedBox(height: 30),
                  PlayerControls(
                    onShowSpeedMenu: () => _showSpeedMenu(context, controller),
                    onShowShareMenu: () => _showShareMenu(context, controller),
                    onShowQueueMenu: () =>
                        _showQueueBottomSheet(context, controller),
                    onShowTimerMenu: () =>
                        _showSleepTimerMenu(context, controller),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
