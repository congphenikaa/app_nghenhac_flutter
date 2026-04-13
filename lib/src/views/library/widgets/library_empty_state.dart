import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../add_edit_playlist_screen.dart';

class LibraryEmptyState extends StatelessWidget {
  const LibraryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.library_music,
            size: 80,
            color: Colors.white24,
          ),
          const SizedBox(height: 16),
          const Text(
            "Bạn chưa tạo danh sách phát nào.",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.to(() => const AddEditPlaylistScreen()),
            // Wait, AddEditPlaylistScreen doesn't have a route. It wasn't in refactor04.md. 
            // I should use the standard Get.to(() => const AddEditPlaylistScreen()) but import it, 
            // or I can define AppRoutes.ADD_EDIT_PLAYLIST. Let's use Get.to for now if route doesn't exist, but we should adhere to Get.toNamed when possible.
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              "Tạo Playlist mới",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
