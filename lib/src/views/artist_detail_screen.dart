import 'dart:convert';
import 'package:app_nghenhac/src/configs/app_urls.dart'; // Đảm bảo bạn đã có AppUrls
import 'package:app_nghenhac/src/models/artist_model.dart';
import 'package:app_nghenhac/src/models/song_model.dart'; // Import SongModel
import 'package:app_nghenhac/src/models/album_model.dart'; // Import AlbumModel (Cần tạo file này nếu chưa có)
import 'package:app_nghenhac/src/view_models/player_controller.dart';
import 'package:app_nghenhac/src/views/album_detail_screen.dart'; // Import màn hình chi tiết Album
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
  final PlayerController playerController = Get.find<PlayerController>();

  @override
  void initState() {
    super.initState();
    fetchArtistDetails();
  }

  // Gọi API lấy thông tin chi tiết (Songs, Albums)
  Future<void> fetchArtistDetails() async {
    try {
      // Giả sử đường dẫn API là: /api/artist/detail/:id
      final url = '${AppUrls.baseUrl}/api/artist/detail/${widget.artist.id}';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> songList = data['topSongs'] ?? [];
          final List<dynamic> albumList = data['albums'] ?? [];

          if (mounted) {
            setState(() {
              topSongs = songList.map((e) => SongModel.fromJson(e)).toList();
              // Lưu ý: Cần đảm bảo AlbumModel.fromJson đã được định nghĩa đúng
              albums = albumList.map((e) => AlbumModel.fromJson(e)).toList();
              isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      print("Error fetching artist detail: $e");
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

          // 2. Nội dung chi tiết (Info, Bio, Albums)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Followers
                  Text(
                    _formatFollowers(widget.artist.followersCount),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nút Play / Follow
                  Row(
                    children: [
                      FloatingActionButton(
                        onPressed: () {
                          if (topSongs.isNotEmpty) {
                            // Phát bài đầu tiên trong danh sách top songs
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
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "Follow",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.more_vert, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Bio
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
                    maxLines: 4, // Giới hạn dòng nếu bio quá dài
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 32),

                  // --- ALBUMS SECTION ---
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
                      height: 180, // Chiều cao cho list album ngang
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: albums.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final album = albums[index];
                          return GestureDetector(
                            onTap: () {
                              // Chuyển sang màn hình chi tiết Album
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
                                    imageUrl: album
                                        .imageUrl, // Đảm bảo model Album có field imageUrl
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
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    // Hiển thị năm phát hành nếu có
                                    "Album",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
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

                  // Popular Releases Title (Songs)
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

          // 3. Danh sách bài hát (SliverList)
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
