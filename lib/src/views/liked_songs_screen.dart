import 'dart:convert';
import 'package:app_nghenhac/src/configs/app_urls.dart';
import 'package:app_nghenhac/src/models/song_model.dart';
import 'package:app_nghenhac/src/view_models/auth_controller.dart';
import 'package:app_nghenhac/src/view_models/player_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LikedSongsScreen extends StatefulWidget {
  const LikedSongsScreen({super.key});

  @override
  State<LikedSongsScreen> createState() => _LikedSongsScreenState();
}

class _LikedSongsScreenState extends State<LikedSongsScreen> {
  List<SongModel> likedSongs = [];
  bool isLoading = true;
  final AuthController authController = Get.find<AuthController>();
  final PlayerController playerController = Get.find<PlayerController>();

  @override
  void initState() {
    super.initState();
    fetchLikedSongs();
  }

  // Hàm lấy danh sách bài hát đã thích (TỐI ƯU HÓA)
  // Gọi API riêng: GET /api/user/liked-songs
  Future<void> fetchLikedSongs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token'); // Lấy token xác thực

      if (token == null) {
        if (mounted) setState(() => isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse(AppUrls.likedSongs), // API mới
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> songsJson = data['songs'] ?? [];

          if (mounted) {
            setState(() {
              // Parse trực tiếp danh sách bài hát từ backend
              likedSongs = songsJson.map((e) => SongModel.fromJson(e)).toList();
              isLoading = false;
            });
          }
        }
      } else {
        print("Lỗi server: ${response.statusCode}");
        if (mounted) setState(() => isLoading = false);
      }
    } catch (e) {
      print("Lỗi tải bài hát đã thích: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // --- HEADER ---
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                "Bài hát đã thích",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF450af5), // Màu tím đặc trưng
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.favorite, size: 64, color: Colors.white),
                      const SizedBox(height: 16),
                      // Hiển thị số lượng từ list đã fetch hoặc từ AuthController
                      Obx(
                        () => Text(
                          "${authController.currentUser.value?.likedSongIds.length ?? likedSongs.length} bài hát",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // --- PLAY BUTTON ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: FloatingActionButton(
                  onPressed: () {
                    if (likedSongs.isNotEmpty) {
                      playerController.playSong(likedSongs[0]);
                    }
                  },
                  backgroundColor: const Color(0xFF30e87a),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.black,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),

          // --- LIST SONGS ---
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF30e87a)),
                  );
                }
                if (likedSongs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Text(
                        "Chưa có bài hát yêu thích nào",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                final song = likedSongs[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CachedNetworkImage(
                      imageUrl: song.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: Colors.grey[800]),
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.music_note, color: Colors.white),
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
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Color(0xFF30e87a)),
                    onPressed: () {
                      // 1. Gọi API bỏ thích
                      authController.toggleLikeSong(song.id);

                      // 2. Xóa khỏi danh sách hiển thị ngay lập tức (Optimistic Update)
                      setState(() {
                        likedSongs.removeAt(index);
                      });
                    },
                  ),
                  onTap: () => playerController.playSong(song),
                );
              },
              childCount: isLoading
                  ? 1
                  : (likedSongs.isEmpty ? 1 : likedSongs.length),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
