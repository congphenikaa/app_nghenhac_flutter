import 'dart:convert';
import 'package:app_nghenhac/src/configs/app_urls.dart';
import 'package:app_nghenhac/src/models/song_model.dart';
import 'package:app_nghenhac/src/view_models/library_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../view_models/player_controller.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final String playlistId;
  final String playlistName;
  final String imageUrl;

  const PlaylistDetailScreen({
    super.key,
    required this.playlistId,
    required this.playlistName,
    required this.imageUrl,
  });

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  var songs = <SongModel>[];
  var isLoading = true;
  final PlayerController playerController = Get.find<PlayerController>();
  // Tìm LibraryController để gọi hàm xóa
  final LibraryController libraryController = Get.find<LibraryController>();

  @override
  void initState() {
    super.initState();
    fetchPlaylistDetails();
  }

  // Gọi API lấy chi tiết playlist
  void fetchPlaylistDetails() async {
    try {
      final url = '${AppUrls.playlistDetail}/${widget.playlistId}';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final playlistData = data['playlist'];
          final List<dynamic> list = playlistData['songs'] ?? [];
          if (mounted) {
            setState(() {
              songs = list.map((e) => SongModel.fromJson(e)).toList();
              isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      print("Lỗi tải playlist: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Hàm xử lý xóa bài hát
  void _removeSong(String songId) async {
    // Gọi hàm xóa trong controller
    bool success = await libraryController.removeSongFromPlaylist(
      widget.playlistId,
      songId,
    );

    if (success) {
      // Nếu thành công, cập nhật UI ngay lập tức
      setState(() {
        songs.removeWhere((s) => s.id == songId);
      });
      Get.snackbar("Thành công", "Đã xóa bài hát khỏi playlist");
    }
  }

  // Hiển thị BottomSheet tùy chọn
  void _showOptions(BuildContext context, SongModel song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CachedNetworkImage(
                    imageUrl: song.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: Colors.grey[800]),
                  ),
                ),
                title: Text(
                  song.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  song.description,
                  style: const TextStyle(color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Divider(color: Colors.grey),
              ListTile(
                leading: const Icon(
                  Icons.remove_circle_outline,
                  color: Colors.red,
                ),
                title: const Text(
                  "Xóa khỏi Playlist này",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context); // Đóng modal
                  _removeSong(song.id); // Gọi hàm xóa
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.playlistName,
                style: const TextStyle(fontSize: 16),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  widget.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: widget.imageUrl,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.grey[900],
                          child: const Icon(
                            Icons.music_note,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.9),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF30e87a)),
                );
              }
              if (songs.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Chưa có bài hát nào",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              final song = songs[index];
              return ListTile(
                leading: Text(
                  "${index + 1}",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
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
                  song.description,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onPressed: () => _showOptions(context, song),
                ),
                onTap: () => playerController.playSong(song),
              );
            }, childCount: isLoading ? 1 : (songs.isEmpty ? 1 : songs.length)),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
