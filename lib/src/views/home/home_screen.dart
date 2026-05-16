import 'package:app_nghenhac/src/core/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../data/models/song_model.dart';

import '../../view_models/auth_controller.dart';
import '../../view_models/player_controller.dart';
import '../../view_models/home_controller.dart';
import '../../view_models/library_controller.dart';
import '../../view_models/chart_controller.dart';

import 'widgets/home_drawer.dart';
import 'widgets/home_header.dart';
import 'widgets/category_filter_chips.dart';
import 'widgets/quick_access_grid.dart';
import 'widgets/new_releases_list.dart';
import 'widgets/popular_artists_list.dart';
import 'widgets/top_mixes_list.dart';
import 'widgets/trending_chart_list.dart';
import 'widgets/song_list_item.dart';

class HomeScreen extends StatelessWidget {
  // 1. Tạo GlobalKey để điều khiển Drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());
    final PlayerController playerController = Get.find<PlayerController>();
    final AuthController authController = Get.put(AuthController());
    final LibraryController libraryController = Get.put(LibraryController());
    final ChartController chartController = Get.put(ChartController());

    // 2. Thay SafeArea bằng Scaffold để dùng Drawer
    return Scaffold(
      key: _scaffoldKey, // Gắn key
      backgroundColor: Colors.black,

      // 3. THÊM DRAWER VÀO ĐÂY
      drawer: HomeDrawer(authController: authController),

      // Bọc nội dung cũ trong SafeArea của Scaffold body
      body: SafeArea(
        child: Container(
          color: Colors.black,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // 4. Truyền callback mở drawer vào Header
              HomeHeader(
                authController: authController,
                onAvatarTap: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),

              const SizedBox(height: 24),
              CategoryFilterChips(controller: controller),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  if (controller.isSongLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF30e87a),
                      ),
                    );
                  }

                  if (controller.selectedCategoryIndex.value == 0) {
                    return _buildDashboardBody(
                      controller,
                      playerController,
                      libraryController,
                      context,
                      authController,
                      chartController,
                    );
                  } else {
                    return _buildSongListOnly(
                      controller,
                      playerController,
                      libraryController,
                      context,
                      authController,
                    );
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- DASHBOARD BODY (GIỮ NGUYÊN) ---
  Widget _buildDashboardBody(
    HomeController controller,
    PlayerController playerController,
    LibraryController libraryController,
    BuildContext context,
    AuthController authController,
    ChartController chartController,
  ) {
    return RefreshIndicator(
      color: const Color(0xFF30e87a),
      backgroundColor: Colors.grey[900],
      onRefresh: () async {
        // Khi vuốt làm mới, cập nhật lại bảng xếp hạng
        await chartController.fetchTrendingTop();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          bottom: playerController.currentSong.value != null ? 100 : 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            QuickAccessGrid(
              songs: controller.songList,
              playerController: playerController,
            ),

            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "Bảng xếp hạng",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Dùng GetX để chuyển sang màn hình mới
                      Get.toNamed(
                        AppRoutes.TOP_CHARTS,
                        arguments: {
                          'chartController': chartController,
                          'playerController': playerController,
                        },
                      );
                    },
                    child: const Text(
                      "Xem tất cả",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            TrendingChartList(
              chartController: chartController,
              playerController: playerController,
            ),

            const SizedBox(height: 32),
            _buildSectionTitle("New Releases"),
            NewReleasesList(albums: controller.albums),

            const SizedBox(height: 32),
            _buildSectionTitle("Popular Artists"),
            PopularArtistsList(artists: controller.artists),

            const SizedBox(height: 32),
            _buildSectionTitle("Your Top Mixes"),
            TopMixesList(albums: controller.albums),

            const SizedBox(height: 32),
            _buildSectionTitle("Tracks For You"),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.songList.length,
              itemBuilder: (context, index) => SongListItem(
                song: controller.songList[index],
                playerController: playerController,
                onTapMore: () => _showSongOptionsBottomSheet(
                  context,
                  controller.songList[index],
                  playerController,
                  libraryController,
                  authController,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // --- SONG LIST ONLY (GIỮ NGUYÊN) ---
  Widget _buildSongListOnly(
    HomeController controller,
    PlayerController playerController,
    LibraryController libraryController,
    BuildContext context,
    AuthController authController,
  ) {
    if (controller.songList.isEmpty) {
      return const Center(
        child: Text(
          "Không có bài hát nào thuộc mục này",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.only(
        bottom: playerController.currentSong.value != null ? 100 : 20,
        left: 16,
        right: 16,
      ),
      itemCount: controller.songList.length,
      itemBuilder: (context, index) => SongListItem(
        song: controller.songList[index],
        playerController: playerController,
        onTapMore: () => _showSongOptionsBottomSheet(
          context,
          controller.songList[index],
          playerController,
          libraryController,
          authController,
        ),
      ),
    );
  }

  // --- SHOW ADD TO PLAYLIST BOTTOM SHEET (GIỮ NGUYÊN) ---
  void _showAddToPlaylistBottomSheet(
    BuildContext context,
    dynamic song,
    LibraryController libraryController,
  ) {
    final playerController = Get.find<PlayerController>();
    if (libraryController.myPlaylists.isEmpty) {
      libraryController.fetchMyPlaylists();
    }

    playerController.hideMiniPlayer.value = true;

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.6,
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
                  const SizedBox(width: 32), // Spacer để căn giữa Text
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
                    constraints:
                        const BoxConstraints(), // Giảm padding thừa của IconButton
                    icon: const Icon(Icons.close, color: Colors.grey, size: 26),
                    onPressed: () => Get.back(), // Nhấn X để đóng ngay lập tức
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (libraryController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
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
                        // 1. LẬP TỨC ĐÓNG BOTTOM SHEET
                        Get.back();

                        // 2. GỌI API THÊM VÀO PLAYLIST
                        libraryController.addSongToPlaylist(
                          playlist.id,
                          song.id,
                        );

                        // 3. Sử dụng Future.delayed ngắn để BottomSheet cũ đóng xong
                        // mới mở Snackbar, tránh lỗi chèn route của GetX làm mất biến trạng thái
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
    ).whenComplete(() {
      // Dùng whenComplete thay vì then để ĐẢM BẢO đoạn này luôn được chạy
      playerController.hideMiniPlayer.value = false;
    });
    ;
  }

  // --- SHOW SONG OPTIONS BOTTOM SHEET (MỚI) ---
  void _showSongOptionsBottomSheet(
    BuildContext context,
    SongModel song,
    PlayerController playerController,
    LibraryController libraryController,
    AuthController authController,
  ) {
    // ẨN MINIPLAYER
    playerController.hideMiniPlayer.value = true;

    // Biến cờ này giúp nhận biết khi ta mở một BottomSheet KHÁC từ bên trong
    bool isTransitioning = false;
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
            // HEADER: Ảnh và Tên bài hát
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CachedNetworkImage(
                    imageUrl: song.imageUrl,
                    width: 50,
                    height: 50,
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.grey, height: 1),
            const SizedBox(height: 10),

            // OPTION 1: PHÁT NHẠC
            ListTile(
              leading: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 28,
              ),
              title: const Text(
                "Phát nhạc",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Get.back(); // Đóng bottom sheet
                playerController.playSong(song);
              },
            ),

            // OPTION 2: LIKE / UNLIKE (Sử dụng Obx để cập nhật icon)
            Obx(() {
              // Kiểm tra xem bài hát có trong danh sách likedSongs của user không
              // Giả sử likedSongs lưu List<String> id
              bool isLiked = false;
              if (authController.currentUser.value != null) {
                isLiked = authController.currentUser.value!.likedSongIds
                    .contains(song.id);
              }

              return ListTile(
                leading: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? const Color(0xFF30e87a) : Colors.white,
                  size: 28,
                ),
                title: Text(
                  isLiked ? "Đã thích" : "Thích",
                  style: TextStyle(
                    color: isLiked ? const Color(0xFF30e87a) : Colors.white,
                  ),
                ),
                onTap: () {
                  authController.toggleLikeSong(song.id);
                  // Không đóng bottom sheet để user thấy hiệu ứng like
                },
              );
            }),

            // OPTION 3: THÊM VÀO PLAYLIST
            ListTile(
              leading: const Icon(
                Icons.playlist_add,
                color: Colors.white,
                size: 28,
              ),
              title: const Text(
                "Thêm vào Playlist",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                isTransitioning = true;
                Get.back(); // Đóng menu option trước
                // Mở menu playlist cũ của bạn
                // Đợi 300ms cho menu Option đóng xong mới mở menu Thêm Playlist
                Future.delayed(const Duration(milliseconds: 300), () {
                  _showAddToPlaylistBottomSheet(
                    context,
                    song,
                    libraryController,
                  );
                });
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    ).whenComplete(() {
      // Dùng whenComplete, và CHỈ đổi lại false nếu không phải đang chuyển qua BottomSheet khác
      // Nếu không có check này thì lúc chuyển giao 2 cái BottomSheet cái MiniPlayer sẽ bị nhấp nháy
      if (!isTransitioning) {
        playerController.hideMiniPlayer.value = false;
      }
    });
  }
}
