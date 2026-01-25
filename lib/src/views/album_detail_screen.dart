import 'dart:convert';
import 'package:app_nghenhac/src/configs/app_urls.dart';
import 'package:app_nghenhac/src/models/song_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/album_model.dart';
import '../view_models/player_controller.dart';

class AlbumDetailScreen extends StatefulWidget {
  final AlbumModel album;

  const AlbumDetailScreen({super.key, required this.album});

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  var songs = <SongModel>[];
  var isLoading = true;
  final PlayerController playerController = Get.find<PlayerController>();

  @override
  void initState() {
    super.initState();
    fetchSongsByAlbum();
  }

  // Gọi API lấy bài hát của Album này
  void fetchSongsByAlbum() async {
    try {
      final url = '${AppUrls.songByAlbum}/${widget.album.id}';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> list = data['songs'] ?? [];
          setState(() {
            // Gán tên artist từ thông tin Album vào bài hát để hiển thị đúng tên
            songs = list.map((e) {
              final song = SongModel.fromJson(e);
              // Gán đè tên artist từ widget.album.artistName
              // Vì bài hát trong album này chắc chắn thuộc về artist của album
              song.artist = widget.album.artistName;
              return song;
            }).toList();
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Lỗi tải bài hát album: $e");
      if (mounted) setState(() => isLoading = false);
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
                widget.album.title,
                style: const TextStyle(fontSize: 16),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.album.imageUrl,
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
                          Colors.black.withOpacity(0.9),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Album by ${widget.album.artistName}",
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  // Nút Play All
                  ElevatedButton(
                    onPressed: songs.isNotEmpty
                        ? () => playerController.playSong(songs[0])
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF30e87a),
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.black,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Danh sách bài hát thật
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF30e87a)),
                );
              }
              if (songs.isEmpty) {
                return const Center(
                  child: Text(
                    "No songs in this album",
                    style: TextStyle(color: Colors.grey),
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
                ),
                subtitle: Text(
                  song.description.isNotEmpty ? song.description : song.artist,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                trailing: const Icon(Icons.more_vert, color: Colors.grey),
                onTap: () => playerController.playSong(song),
              );
            }, childCount: isLoading ? 1 : (songs.isEmpty ? 1 : songs.length)),
          ),
          // Padding đáy để tránh MiniPlayer
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
