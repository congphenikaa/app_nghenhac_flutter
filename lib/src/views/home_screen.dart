import 'package:app_nghenhac/src/view_models/auth_controller.dart';
import 'package:app_nghenhac/src/view_models/player_controller.dart';
import 'package:app_nghenhac/src/views/album_detail_screen.dart';
import 'package:app_nghenhac/src/views/artist_detail_screen.dart';
import 'package:app_nghenhac/src/views/profile_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../view_models/home_controller.dart';
import '../view_models/library_controller.dart';
import '../models/album_model.dart';
import '../models/artist_model.dart';

// --- CLASS MOCK DATA (GIỮ NGUYÊN) ---
class HomeMockPlaylist {
  final int id;
  final String name;
  final String imageUrl;

  HomeMockPlaylist({
    required this.id,
    required this.name,
    required this.imageUrl,
  });
}

// Danh sách Mock Data (GIỮ NGUYÊN)
final List<HomeMockPlaylist> kMockPlaylists = [
  HomeMockPlaylist(
    id: 1,
    name: "Liked Songs",
    imageUrl:
        "https://images.unsplash.com/photo-1493225255756-d9584f8606e9?w=300&q=80",
  ),
  HomeMockPlaylist(
    id: 2,
    name: "On Repeat",
    imageUrl:
        "https://images.unsplash.com/photo-1493225255756-d9584f8606e9?w=300&q=80",
  ),
  HomeMockPlaylist(
    id: 3,
    name: "Daily Mix 1",
    imageUrl:
        "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=300&q=80",
  ),
  HomeMockPlaylist(
    id: 4,
    name: "Discover Weekly",
    imageUrl:
        "https://images.unsplash.com/photo-1493225255756-d9584f8606e9?w=300&q=80",
  ),
  HomeMockPlaylist(
    id: 5,
    name: "Release Radar",
    imageUrl:
        "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=300&q=80",
  ),
  HomeMockPlaylist(
    id: 6,
    name: "Rock Classics",
    imageUrl:
        "https://images.unsplash.com/photo-1498038432885-c6f3f1b912ee?w=300&q=80",
  ),
];

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

    // 2. Thay SafeArea bằng Scaffold để dùng Drawer
    return Scaffold(
      key: _scaffoldKey, // Gắn key
      backgroundColor: Colors.black,

      // 3. THÊM DRAWER VÀO ĐÂY
      drawer: _buildDrawer(context, authController),

      // Bọc nội dung cũ trong SafeArea của Scaffold body
      body: SafeArea(
        child: Container(
          color: Colors.black,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // 4. Truyền callback mở drawer vào Header
              _buildHeader(authController, () {
                _scaffoldKey.currentState?.openDrawer();
              }),

              const SizedBox(height: 24),
              _buildFilterChips(controller),
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
                    );
                  } else {
                    return _buildSongListOnly(
                      controller,
                      playerController,
                      libraryController,
                      context,
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

  // --- DRAWER WIDGET (MỚI) ---
  Widget _buildDrawer(BuildContext context, AuthController authController) {
    return Drawer(
      backgroundColor: const Color(0xFF121212),
      child: Obx(() {
        // Lấy dữ liệu user thật
        final user = authController.currentUser.value;
        final username = user?.username ?? "Khách";
        final email = user?.email ?? "Đăng nhập để đồng bộ";
        // Fallback ảnh nếu không có avatar
        final avatar = (user != null && user.avatar.isNotEmpty)
            ? user.avatar
            : "https://i.pravatar.cc/150?img=11";

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF1C2E24), // Màu xanh rêu đậm spotify
              ),
              accountName: Text(
                username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              accountEmail: Text(
                email,
                style: const TextStyle(color: Colors.white70),
              ),
              currentAccountPicture: GestureDetector(
                onTap: () {
                  Get.back(); // Đóng drawer
                  Get.to(() => const ProfileScreen()); // Chuyển sang Profile
                },
                child: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(avatar),
                ),
              ),
            ),

            // Các mục Menu
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title: const Text("Hồ sơ", style: TextStyle(color: Colors.white)),
              onTap: () {
                Get.back();
                Get.to(() => const ProfileScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.white),
              title: const Text(
                "Mới phát gần đây",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                // TODO: Chức năng lịch sử
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text(
                "Cài đặt",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                // TODO: Chức năng cài đặt
                Get.back();
              },
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(color: Colors.grey, thickness: 0.5),
            ),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                "Đăng xuất",
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () => authController.logout(),
            ),
          ],
        );
      }),
    );
  }

  // --- HEADER (CẬP NHẬT) ---
  // Thêm tham số onAvatarTap và dùng Obx hiển thị dữ liệu thật
  Widget _buildHeader(AuthController authController, VoidCallback onAvatarTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Bọc GestureDetector để mở Drawer khi bấm Avatar
              GestureDetector(
                onTap: onAvatarTap,
                child: Obx(() {
                  final user = authController.currentUser.value;
                  final avatar = (user != null && user.avatar.isNotEmpty)
                      ? user.avatar
                      : 'https://i.pravatar.cc/150?img=11';

                  return CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(avatar),
                  );
                }),
              ),
              const SizedBox(width: 12),

              // Bấm vào tên cũng mở Drawer cho tiện
              GestureDetector(
                onTap: onAvatarTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Good Evening",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14, // Giảm size chữ greeting
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    // Tên người dùng thật
                    Obx(
                      () => Text(
                        authController.currentUser.value?.username ??
                            "Music Lover",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18, // Tăng size tên
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.white,
            ), // Đổi sang icon chuông cho hợp lý
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // --- FILTER CHIPS (GIỮ NGUYÊN) ---
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

  // --- DASHBOARD BODY (GIỮ NGUYÊN) ---
  Widget _buildDashboardBody(
    HomeController controller,
    PlayerController playerController,
    LibraryController libraryController,
    BuildContext context,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: playerController.currentSong.value != null ? 100 : 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickAccessGrid(kMockPlaylists),

          const SizedBox(height: 32),
          _buildSectionTitle("New Releases"),
          _buildNewReleasesList(controller.albums),

          const SizedBox(height: 32),
          _buildSectionTitle("Popular Artists"),
          _buildPopularArtists(controller.artists),

          const SizedBox(height: 32),
          _buildSectionTitle("Your Top Mixes"),
          _buildTopMixes(kMockPlaylists),

          const SizedBox(height: 32),
          _buildSectionTitle("Tracks For You"),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: controller.songList.length,
            itemBuilder: (context, index) => _buildSongItem(
              context,
              controller.songList[index],
              playerController,
              libraryController,
            ),
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

  // 1. Quick Access Grid (GIỮ NGUYÊN)
  Widget _buildQuickAccessGrid(List<HomeMockPlaylist> playlists) {
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

  // 2. New Releases (GIỮ NGUYÊN)
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

  // 3. Popular Artists (GIỮ NGUYÊN)
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
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ArtistDetailScreen(artist: artist),
                ),
              );
            },
            child: Column(
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

  // 4. Top Mixes (GIỮ NGUYÊN)
  Widget _buildTopMixes(List<HomeMockPlaylist> playlists) {
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

  // --- SONG LIST ONLY (GIỮ NGUYÊN) ---
  Widget _buildSongListOnly(
    HomeController controller,
    PlayerController playerController,
    LibraryController libraryController,
    BuildContext context,
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
      itemBuilder: (context, index) => _buildSongItem(
        context,
        controller.songList[index],
        playerController,
        libraryController,
      ),
    );
  }

  // --- SHOW ADD TO PLAYLIST BOTTOM SHEET (GIỮ NGUYÊN) ---
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
        padding: const EdgeInsets.all(16),
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
            const Text(
              "Thêm vào Playlist",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
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
                        libraryController.addSongToPlaylist(
                          playlist.id,
                          song.id,
                        );
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

  Widget _buildSongItem(
    BuildContext context,
    dynamic song,
    PlayerController playerController,
    LibraryController libraryController,
  ) {
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
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          onPressed: () =>
              _showAddToPlaylistBottomSheet(context, song, libraryController),
        ),
        onTap: () => playerController.playSong(song),
      ),
    );
  }
}
