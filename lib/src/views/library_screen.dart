import 'package:app_nghenhac/src/view_models/library_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_nghenhac/src/views/playlist_detail_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LibraryController());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Your Library",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 30),
            onPressed: () => _showCreateDialog(context, controller),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF30e87a)),
          );
        }

        if (controller.myPlaylists.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.library_music, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  "You haven't created any playlists yet.",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _showCreateDialog(context, controller),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF30e87a),
                  ),
                  child: const Text(
                    "Create Playlist",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.myPlaylists.length,
          padding: const EdgeInsets.only(bottom: 100),
          itemBuilder: (context, index) {
            final playlist = controller.myPlaylists[index];
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: playlist.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: playlist.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.music_note,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey[800],
                        width: 50,
                        height: 50,
                        child: const Icon(
                          Icons.music_note,
                          color: Colors.white,
                        ),
                      ),
              ),
              title: Text(
                playlist.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                "${playlist.songIds.length} songs",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                onPressed: () {
                  Get.defaultDialog(
                    title: "Delete Playlist",
                    middleText: "Are you sure?",
                    textConfirm: "Delete",
                    textCancel: "Cancel",
                    confirmTextColor: Colors.white,
                    onConfirm: () {
                      controller.removePlaylist(playlist.id);
                      Get.back();
                    },
                  );
                },
              ),
              onTap: () {
                // Chuyển sang màn hình chi tiết Playlist
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PlaylistDetailScreen(
                      playlistId: playlist.id,
                      playlistName: playlist.name,
                      imageUrl: playlist.imageUrl,
                    ),
                  ),
                );
              },
            );
          },
        );
      }),
    );
  }

  void _showCreateDialog(BuildContext context, LibraryController controller) {
    final textController = TextEditingController();
    Get.defaultDialog(
      title: "New Playlist",
      content: TextField(
        controller: textController,
        decoration: const InputDecoration(hintText: "Enter playlist name"),
      ),
      textConfirm: "Create",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      onConfirm: () {
        if (textController.text.isNotEmpty) {
          controller.createPlaylist(textController.text);
          Get.back();
        }
      },
    );
  }
}
