import 'package:app_nghenhac/src/view_models/auth_controller.dart';
import 'package:app_nghenhac/src/view_models/player_controller.dart';
import 'package:app_nghenhac/src/views/album_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../view_models/home_controller.dart';
import '../models/album_model.dart';
import '../models/artist_model.dart';

class PlaylistModel {
  final int id;
  final String name;
  final String imageUrl;

  PlaylistModel({required this.id, required this.name, required this.imageUrl});
}

final List<PlaylistModel> kMockPlaylists = [
  PlaylistModel(
    id: 1,
    name: "Liked Songs",
    imageUrl:
        "https://images.unsplash.com/photo-1493225255756-d9584f8606e9?w=300&q=80",
  ),
  PlaylistModel(
    id: 2,
    name: "On Repeat",
    imageUrl:
        "https://images.unsplash.com/photo-1493225255756-d9584f8606e9?w=300&q=80",
  ),
  PlaylistModel(
    id: 3,
    name: "Daily Mix 1",
    imageUrl:
        "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=300&q=80",
  ),
  PlaylistModel(
    id: 4,
    name: "Discover Weekly",
    imageUrl:
        "https://images.unsplash.com/photo-1493225255756-d9584f8606e9?w=300&q=80",
  ),
  PlaylistModel(
    id: 5,
    name: "Release Radar",
    imageUrl:
        "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=300&q=80",
  ),
  PlaylistModel(
    id: 6,
    name: "Rock Classics",
    imageUrl:
        "https://images.unsplash.com/photo-1498038432885-c6f3f1b912ee?w=300&q=80",
  ),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Put Controller (Chỉ put nếu chưa có, dùng Get.put sẽ tự kiểm tra)
    final HomeController controller = Get.put(HomeController());
    final PlayerController playerController = Get.find<PlayerController>();
    final AuthController authController = Get.put(AuthController());

    // --- SỬA ĐỔI QUAN TRỌNG: BỎ SCAFFOLD ---
    // Chỉ trả về SafeArea chứa nội dung.
    // Khung app (Scaffold) đã được MainWrapper lo.
    return SafeArea(
      child: Container(
        color: Colors.black, // Đảm bảo nền đen đồng nhất
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Header
            _buildHeader(authController),

            const SizedBox(height: 24),

            // Filter Chips
            _buildFilterChips(controller),

            const SizedBox(height: 16),

            // Body (Dashboard hoặc List)
            Expanded(
              child: Obx(() {
                if (controller.isSongLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF30e87a)),
                  );
                }

                if (controller.selectedCategoryIndex.value == 0) {
                  return _buildDashboardBody(controller, playerController);
                } else {
                  return _buildSongListOnly(controller, playerController);
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  // --- HEADER ---
  Widget _buildHeader(AuthController authController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey,
                // Thay thế bằng ảnh đại diện thực tế nếu có
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?img=11',
                ),
              ),
              SizedBox(width: 12),
              Text(
                "Good Evening",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
    );
  }

  // --- FILTER CHIPS ---
  Widget _buildFilterChips(HomeController controller) {
    return SizedBox(
      height: 40,
      child: Obx(() {
        if (controller.categories.isEmpty) return const SizedBox();
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: controller.categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final cat = controller.categories[index];
            return Obx(() {
              final isSelected =
                  controller.selectedCategoryIndex.value == index;
              return GestureDetector(
                onTap: () => controller.onCategorySelected(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF1C2E24)
                        : Colors.white10,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    cat.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            });
          },
        );
      }),
    );
  }

  // --- DASHBOARD BODY ---
  Widget _buildDashboardBody(
    HomeController controller,
    PlayerController playerController,
  ) {
    return SingleChildScrollView(
      // Padding dưới để nội dung không bị che bởi MiniPlayer
      // Lưu ý: MainWrapper đã có BottomNav, padding này chỉ để tránh MiniPlayer khi nó hiện lên
      padding: EdgeInsets.only(
        bottom: playerController.currentSong.value != null ? 100 : 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. QUICK ACCESS
          _buildQuickAccessGrid(kMockPlaylists),

          const SizedBox(height: 32),

          // 2. NEW RELEASES
          _buildSectionTitle("New Releases"),
          _buildNewReleasesList(controller.albums),

          const SizedBox(height: 32),

          // 3. POPULAR ARTISTS
          _buildSectionTitle("Popular Artists"),
          _buildPopularArtists(controller.artists),

          const SizedBox(height: 32),

          // 4. TOP MIXES
          _buildSectionTitle("Your Top Mixes"),
          _buildTopMixes(kMockPlaylists),

          const SizedBox(height: 32),

          // 5. TRACKS FOR YOU
          _buildSectionTitle("Tracks For You"),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: controller.songList.length,
            itemBuilder: (context, index) =>
                _buildSongItem(controller.songList[index], playerController),
          ),
        ],
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

  // 1. Quick Access Grid
  Widget _buildQuickAccessGrid(List<PlaylistModel> playlists) {
    if (playlists.isEmpty) return const SizedBox();
    final displayList = playlists.take(6).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: displayList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          final item = displayList[index];
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1C2E24),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    width: 55,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      color: Colors.grey[800],
                      child: const Icon(Icons.music_note, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 2. New Releases (Albums)
  Widget _buildNewReleasesList(List<AlbumModel> albums) {
    if (albums.isEmpty) return const SizedBox();
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: albums.length > 5 ? 5 : albums.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final album = albums.reversed.toList()[index];
          return GestureDetector(
            onTap: () {
              // --- SỬA ĐỔI QUAN TRỌNG ---
              // Dùng Navigator.of(context).push thay vì Get.to
              // Để đẩy màn hình vào Navigator con của tab Home
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AlbumDetailScreen(album: album),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: album.imageUrl,
                    width: 140,
                    height: 140,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: Colors.grey[800]),
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.album, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 140,
                  child: Text(
                    album.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 140,
                  child: Text(
                    album.artistName,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 3. Popular Artists
  Widget _buildPopularArtists(List<ArtistModel> artists) {
    if (artists.isEmpty) return const SizedBox();
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: artists.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final artist = artists[index];
          return Column(
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(artist.imageUrl),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 5,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 110,
                child: Text(
                  artist.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // 4. Top Mixes
  Widget _buildTopMixes(List<PlaylistModel> playlists) {
    if (playlists.isEmpty) return const SizedBox();
    final displayList = playlists.toList();
    final gradients = [
      [Colors.indigo, Colors.purple],
      [Colors.orange, Colors.red],
      [Colors.teal, Colors.blue],
      [Colors.pink, Colors.deepPurple],
    ];

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: displayList.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final playlist = displayList[index];
          final colors = gradients[index % gradients.length];

          return Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playlist.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          height: 1.1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 4,
                        width: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFF30e87a),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- SONG LIST ONLY ---
  Widget _buildSongListOnly(
    HomeController controller,
    PlayerController playerController,
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
      itemBuilder: (context, index) =>
          _buildSongItem(controller.songList[index], playerController),
    );
  }

  Widget _buildSongItem(dynamic song, PlayerController playerController) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: CachedNetworkImage(
            imageUrl: song.imageUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: Colors.grey[800]),
            errorWidget: (_, __, ___) =>
                const Icon(Icons.music_note, color: Colors.white),
          ),
        ),
        title: Text(
          song.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          song.description,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.more_vert, color: Colors.grey),
        onTap: () => playerController.playSong(song),
      ),
    );
  }
}
