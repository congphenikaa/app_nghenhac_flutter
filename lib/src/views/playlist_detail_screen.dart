import 'dart:convert';
import 'package:app_nghenhac/src/configs/app_urls.dart';
import 'package:app_nghenhac/src/models/song_model.dart';
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
          setState(() {
            songs = list.map((e) => SongModel.fromJson(e)).toList();
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Lỗi tải playlist: $e");
      setState(() => isLoading = false);
    }
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
              if (isLoading)
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF30e87a)),
                );
              if (songs.isEmpty)
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "No songs added yet",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );

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
                ),
                subtitle: Text(
                  song.description,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                trailing: const Icon(Icons.more_vert, color: Colors.grey),
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
