import 'dart:convert';
import 'package:app_nghenhac/src/core/constants/app_urls.dart';
import 'package:app_nghenhac/src/models/song_model.dart';
import 'package:app_nghenhac/src/view_models/library_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../view_models/player_controller.dart';
import 'widgets/playlist_sliver_app_bar.dart';
import 'widgets/playlist_song_item.dart';

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

  String _currentName = "";
  String _currentDesc = "";
  String _currentImageUrl = "";

  final PlayerController playerController = Get.find<PlayerController>();
  final LibraryController libraryController = Get.find<LibraryController>();

  @override
  void initState() {
    super.initState();
    _currentName = widget.playlistName;
    _currentImageUrl = widget.imageUrl;
    fetchPlaylistDetails();
  }

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
              _currentName = playlistData['name'] ?? _currentName;
              _currentDesc = playlistData['description'] ?? "";
              _currentImageUrl = playlistData['image'] ?? _currentImageUrl;

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

  void _removeSong(String songId) async {
    bool success = await libraryController.removeSongFromPlaylist(
      widget.playlistId,
      songId,
    );

    if (success) {
      setState(() {
        songs.removeWhere((s) => s.id == songId);
      });
      Get.snackbar(
        "Thành công",
        "Đã xóa bài hát khỏi playlist",
        backgroundColor: const Color(0xFF1C2E24),
        colorText: Colors.white,
      );
    }
  }

  void _showOptions(SongModel song) {
    playerController.hideMiniPlayer.value = true;
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(bottom: 10),
        child: SafeArea(
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
                  Get.back();
                  _removeSong(song.id);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
    ).whenComplete(() {
      playerController.hideMiniPlayer.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          PlaylistSliverAppBar(
            playlistId: widget.playlistId,
            currentName: _currentName,
            currentDesc: _currentDesc,
            currentImageUrl: _currentImageUrl,
            onDetailsUpdated: fetchPlaylistDetails,
            libraryController: libraryController,
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
              return PlaylistSongItem(
                index: index,
                song: song,
                currentQueue: songs,
                playerController: playerController,
                onOptionsTap: () => _showOptions(song),
              );
            }, childCount: isLoading ? 1 : (songs.isEmpty ? 1 : songs.length)),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
