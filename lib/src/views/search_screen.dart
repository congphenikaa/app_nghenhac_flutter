import 'package:app_nghenhac/src/models/artist_model.dart';
import 'package:app_nghenhac/src/models/song_model.dart';
import 'package:app_nghenhac/src/models/album_model.dart';
import 'package:app_nghenhac/src/view_models/player_controller.dart';
import 'package:app_nghenhac/src/view_models/search_controller.dart';
import 'package:app_nghenhac/src/views/category_detail_screen.dart';
import 'package:app_nghenhac/src/views/artist_detail_screen.dart';
import 'package:app_nghenhac/src/views/album_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  // Hàm chuyển đổi mã Hex giữ nguyên
  Color _hexToColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final SearchPageController controller = Get.put(SearchPageController());
    final PlayerController playerController = Get.find();

    return Scaffold(
      backgroundColor: Colors.black, // Nền đen chuẩn Spotify
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER & SEARCH BAR
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              color: Colors.black, // Giữ header cố định nền đen
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tìm kiếm",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller.textController,
                    onChanged: (val) => controller.onSearchChanged(val),
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Bạn muốn nghe gì?',
                      hintStyle: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey[800],
                        size: 28,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          4,
                        ), // Bo góc nhẹ giống Spotify mới
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: Obx(
                        () => controller.searchText.value.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  controller.textController.clear();
                                  controller.onSearchChanged("");
                                },
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. NỘI DUNG CHÍNH
            Expanded(
              child: Obx(() {
                // A. Loading
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  );
                }

                // B. Category (Browse All) - Giao diện mặc định
                if (controller.searchText.value.isEmpty) {
                  return _buildCategoryGrid(controller);
                }

                // C. Không tìm thấy
                if (controller.songResults.isEmpty &&
                    controller.artistResults.isEmpty &&
                    controller.albumResults.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          color: Colors.grey,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Không tìm thấy kết quả nào cho '${controller.searchText.value}'",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                }

                // D. Danh sách kết quả (Kết hợp trong ListView để scroll mượt)
                return ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  children: [
                    // --- Phần Bài hát ---
                    if (controller.songResults.isNotEmpty) ...[
                      _buildSectionTitle("Bài hát"),
                      ...controller.songResults.map(
                        (song) => _buildSongItem(song, playerController),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // --- Phần Nghệ sĩ ---
                    if (controller.artistResults.isNotEmpty) ...[
                      _buildSectionTitle("Nghệ sĩ"),
                      ...controller.artistResults.map(
                        (artist) => _buildArtistItem(artist),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // --- Phần Album ---
                    if (controller.albumResults.isNotEmpty) ...[
                      _buildSectionTitle("Album"),
                      ...controller.albumResults.map(
                        (album) => _buildAlbumItem(album),
                      ),
                      const SizedBox(height: 20),
                    ],

                    const SizedBox(height: 80), // Padding cho MiniPlayer
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER: Title Section ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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

  // --- WIDGET: Bài hát (ListTile sạch sẽ) ---
  Widget _buildSongItem(SongModel song, PlayerController playerController) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CachedNetworkImage(
          imageUrl: song.imageUrl,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) =>
              Container(color: Colors.grey[800]),
        ),
      ),
      title: Text(
        song.title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        "Bài hát • ${song.artist}",
        style: TextStyle(color: Colors.grey[400], fontSize: 13),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert, color: Colors.grey),
        onPressed: () {}, // Thêm chức năng more sau
      ),
      onTap: () {
        playerController.playSong(song);
      },
    );
  }

  // --- WIDGET: Nghệ sĩ (Avatar Tròn) ---
  Widget _buildArtistItem(ArtistModel artist) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey[800],
        backgroundImage: CachedNetworkImageProvider(artist.imageUrl),
      ),
      title: Text(
        artist.name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        "Nghệ sĩ",
        style: TextStyle(color: Colors.grey[400], fontSize: 13),
      ),
      onTap: () => Get.to(() => ArtistDetailScreen(artist: artist)),
    );
  }

  // --- WIDGET: Album (Ảnh Vuông) ---
  Widget _buildAlbumItem(AlbumModel album) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CachedNetworkImage(
          imageUrl: album.imageUrl,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) =>
              Container(color: Colors.grey[800]),
        ),
      ),
      title: Text(
        album.title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        "Album • ${album.artistName}",
        style: TextStyle(color: Colors.grey[400], fontSize: 13),
      ),
      onTap: () => Get.to(() => AlbumDetailScreen(album: album)),
    );
  }

  // --- WIDGET: Grid Categories (Style thẻ Spotify) ---
  Widget _buildCategoryGrid(SearchPageController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            "Duyệt tìm tất cả",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6, // Tỉ lệ thẻ ngang
            ),
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              final cat = controller.categories[index];
              final color = _hexToColor(cat.color);

              return GestureDetector(
                onTap: () {
                  Get.to(() => CategoryDetailScreen(category: cat));
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    4,
                  ), // Spotify bo góc rất nhẹ (4px)
                  child: Container(
                    color: color,
                    child: Stack(
                      children: [
                        // Chữ nằm góc Trái - Trên
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            cat.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                          ),
                        ),
                        // Ảnh xoay nghiêng nằm góc Phải - Dưới
                        Positioned(
                          right: -15,
                          bottom: -5,
                          child: RotationTransition(
                            turns: const AlwaysStoppedAnimation(25 / 360),
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.black12, // Shadow giả
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(cat.image),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(2, 4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
