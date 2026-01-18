import 'package:app_nghenhac/src/models/artist_model.dart';
import 'package:app_nghenhac/src/models/album_model.dart';
import 'package:app_nghenhac/src/models/song_model.dart';
import 'package:app_nghenhac/src/models/category_model.dart';
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

  // Hàm chuyển mã Hex (#RRGGBB) sang Color
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
    final PlayerController playerController = Get.find<PlayerController>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // 1. HEADER & SEARCH BAR
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Search",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller.textController,
                    style: const TextStyle(color: Colors.black),
                    onChanged: (value) => controller.onSearchChanged(value),
                    decoration: InputDecoration(
                      hintText: "Bài hát, Nghệ sĩ, Album...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      // Nút xóa text
                      // [CẬP NHẬT] Dùng biến .obs để Obx hoạt động đúng
                      suffixIcon: Obx(
                        () => controller.searchText.value.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  controller.textController.clear();
                                  controller.onSearchChanged(
                                    "",
                                  ); // Cập nhật cả biến obs và gọi API
                                  controller.clearResults();
                                },
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. BODY CONTENT
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF30e87a)),
                  );
                }

                // Nếu ô tìm kiếm rỗng -> Hiển thị Browse All (Categories)
                // [CẬP NHẬT] Dùng biến .obs thay vì controller.textController.text
                if (controller.searchText.value.isEmpty) {
                  return _buildBrowseAll(controller);
                }

                // Nếu có kết quả -> Hiển thị list
                return _buildSearchResults(
                  controller,
                  playerController,
                  context,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // --- GIAO DIỆN BROWSE ALL (Lưới Danh Mục) ---
  Widget _buildBrowseAll(SearchPageController controller) {
    if (controller.categories.isEmpty) {
      return const Center(
        child: Text(
          "Đang tải danh mục...",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            "Browse All",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              100,
            ), // Padding dưới để tránh miniplayer
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 cột
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.6, // Tỷ lệ rộng/cao
            ),
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              final cat = controller.categories[index];
              // Chuyển mã màu từ model sang Color
              final tileColor = _hexToColor(cat.color);

              return GestureDetector(
                onTap: () {
                  Get.to(() => CategoryDetailScreen(category: cat));
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: tileColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.hardEdge, // Cắt ảnh tràn ra ngoài
                  child: Stack(
                    children: [
                      // Tên Category
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          cat.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Ảnh Category (Xoay nghiêng ở góc phải)
                      Positioned(
                        right: -15,
                        bottom: -5,
                        child: Transform.rotate(
                          angle: 25 * 3.14159 / 180, // Xoay 25 độ
                          child: Container(
                            width: 75,
                            height: 75,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 5,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: CachedNetworkImage(
                                // --- [QUAN TRỌNG] Dùng 'image' đúng theo Model cũ của bạn ---
                                imageUrl: cat.image,
                                fit: BoxFit.cover,
                                placeholder: (_, __) =>
                                    Container(color: Colors.black26),
                                errorWidget: (_, __, ___) => const SizedBox(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- GIAO DIỆN KẾT QUẢ TÌM KIẾM ---
  Widget _buildSearchResults(
    SearchPageController controller,
    PlayerController playerController,
    BuildContext context,
  ) {
    if (controller.songResults.isEmpty &&
        controller.artistResults.isEmpty &&
        controller.albumResults.isEmpty) {
      return const Center(
        child: Text(
          "Không tìm thấy kết quả nào.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.only(
        bottom: playerController.currentSong.value != null ? 100 : 20,
      ),
      children: [
        // 1. Top Result (Artist đầu tiên)
        if (controller.artistResults.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Kết quả hàng đầu",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildArtistItem(context, controller.artistResults[0]),
        ],

        // 2. Songs
        if (controller.songResults.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              "Bài hát",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...controller.songResults.map(
            (song) => ListTile(
              leading: ClipRRect(
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
              title: Text(
                song.title,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                song.artist,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              trailing: const Icon(Icons.more_vert, color: Colors.grey),
              onTap: () => playerController.playSong(song),
            ),
          ),
        ],

        // 3. Artists (Khác top result)
        if (controller.artistResults.length > 1) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              "Nghệ sĩ",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...controller.artistResults
              .skip(1)
              .map(
                (artist) => ListTile(
                  leading: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                      artist.imageUrl,
                    ),
                    radius: 25,
                  ),
                  title: Text(
                    artist.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    "Nghệ sĩ",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ArtistDetailScreen(artist: artist),
                      ),
                    );
                  },
                ),
              ),
        ],

        // 4. Albums
        if (controller.albumResults.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              "Albums",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...controller.albumResults.map(
            (album) => ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CachedNetworkImage(
                  imageUrl: album.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) =>
                      const Icon(Icons.album, color: Colors.white),
                ),
              ),
              title: Text(
                album.title,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                "Album",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AlbumDetailScreen(album: album),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildArtistItem(BuildContext context, ArtistModel artist) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ArtistDetailScreen(artist: artist)),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2E24), // Màu nền thẻ Top Result
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: CachedNetworkImageProvider(artist.imageUrl),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artist.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Nghệ sĩ",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
