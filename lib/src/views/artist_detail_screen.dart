import 'dart:convert';
import 'package:app_nghenhac/src/configs/app_urls.dart';
import 'package:app_nghenhac/src/models/artist_model.dart';
import 'package:app_nghenhac/src/models/song_model.dart';
import 'package:app_nghenhac/src/models/album_model.dart';
import 'package:app_nghenhac/src/view_models/auth_controller.dart';
import 'package:app_nghenhac/src/view_models/player_controller.dart';
import 'package:app_nghenhac/src/views/album_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ArtistDetailScreen extends StatefulWidget {
  final ArtistModel artist;

  const ArtistDetailScreen({super.key, required this.artist});

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen> {
  // Dữ liệu
  List<SongModel> topSongs = [];
  List<AlbumModel> albums = [];
  bool isLoading = true;

  // Sử dụng RxInt để quản lý số lượng follow (Reactive)
  final RxInt followersCount = 0.obs;

  final PlayerController playerController = Get.find<PlayerController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    // Khởi tạo giá trị ban đầu từ widget truyền vào
    followersCount.value = widget.artist.followersCount;
    fetchArtistDetails();
  }

  // Gọi API lấy thông tin chi tiết (Songs, Albums)
  Future<void> fetchArtistDetails() async {
    try {
      final url = '${AppUrls.baseUrl}/api/artist/detail/${widget.artist.id}';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> songList = data['topSongs'] ?? [];
          final List<dynamic> albumList = data['albums'] ?? [];

          // Cập nhật số lượng follow mới nhất từ server nếu có
          if (data['artist'] != null &&
              data['artist']['followersCount'] != null) {
            followersCount.value = data['artist']['followersCount'];
          }

          if (mounted) {
            setState(() {
              // --- FIX LỖI HIỂN THỊ ID THAY VÌ TÊN ---
              // Vì ta đang ở trang của Artist này, ta biết chắc chắn tên của họ.
              // Ta sẽ gán đè tên Artist vào các bài hát và album lấy về.

              topSongs = songList.map((e) {
                final song = SongModel.fromJson(e);
                song.artist =
                    widget.artist.name; // Gán tên thật thay vì dùng ID từ API
                return song;
              }).toList();

              albums = albumList.map((e) {
                final album = AlbumModel.fromJson(e);
                // Tạo bản sao AlbumModel nhưng thay thế artistName bằng tên thật
                return AlbumModel(
                  id: album.id,
                  title: album.title,
                  description: album.description,
                  imageUrl: album.imageUrl,
                  artistName: widget.artist.name, // Gán tên thật
                );
              }).toList();

              isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  String _formatFollowers(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M Followers';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K Followers';
    }
    return '$count Followers';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // 1. Ảnh bìa Artist
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.black54,
                child: Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.artist.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              centerTitle: true,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.artist.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: Colors.grey[900]),
                    errorWidget: (_, __, ___) =>
                        Container(color: Colors.grey[900]),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.8),
                          Colors.black,
                        ],
                        stops: const [0.0, 0.4, 0.8, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Nội dung chi tiết
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Followers (Sử dụng Obx để cập nhật số lượng)
                  Obx(
                    () => Text(
                      _formatFollowers(followersCount.value),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nút Play / Follow
                  Row(
                    children: [
                      FloatingActionButton(
                        onPressed: () {
                          if (topSongs.isNotEmpty) {
                            playerController.playSong(topSongs[0]);
                          } else {
                            Get.snackbar(
                              "Thông báo",
                              "Nghệ sĩ chưa có bài hát nào",
                            );
                          }
                        },
                        backgroundColor: const Color(0xFF30e87a),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.black,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Nút Follow
                      Obx(() {
                        // Kiểm tra trạng thái follow từ AuthController
                        final isFollowing =
                            authController.currentUser.value?.followedArtistIds
                                .contains(widget.artist.id) ??
                            false;

                        return OutlinedButton(
                          onPressed: () {
                            // 1. Cập nhật UI số lượng ngay lập tức (Optimistic Update)
                            if (isFollowing) {
                              if (followersCount.value > 0) {
                                followersCount.value--;
                              }
                            } else {
                              followersCount.value++;
                            }

                            // 2. Gọi hàm logic trong AuthController
                            authController.toggleFollowArtist(widget.artist.id);
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            side: BorderSide(
                              color: isFollowing
                                  ? const Color(0xFF30e87a)
                                  : Colors.white,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            isFollowing ? "Following" : "Follow",
                            style: TextStyle(
                              color: isFollowing
                                  ? const Color(0xFF30e87a)
                                  : Colors.white,
                              fontWeight: isFollowing
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      }),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.more_vert, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Biography
                  const Text(
                    "Biography",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.artist.bio.isNotEmpty
                        ? widget.artist.bio
                        : "Nghệ sĩ này chưa có tiểu sử.",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 32),

                  // Albums Section
                  if (albums.isNotEmpty) ...[
                    const Text(
                      "Popular Albums",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: albums.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final album = albums[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AlbumDetailScreen(album: album),
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
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) =>
                                        Container(color: Colors.grey[800]),
                                    errorWidget: (_, __, ___) => Container(
                                      color: Colors.grey[800],
                                      child: const Icon(
                                        Icons.album,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    album.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
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
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Popular Songs Title
                  if (topSongs.isNotEmpty)
                    const Text(
                      "Popular Songs",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // 3. Danh sách bài hát
          isLoading
              ? const SliverToBoxAdapter(
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF30e87a)),
                  ),
                )
              : topSongs.isEmpty
              ? const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Chưa có bài hát nào.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final song = topSongs[index];
                    return ListTile(
                      leading: Text(
                        "${index + 1}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
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
                        "${song.plays} lượt nghe",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      trailing: const Icon(Icons.more_vert, color: Colors.grey),
                      onTap: () => playerController.playSong(song),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    );
                  }, childCount: topSongs.length),
                ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
