import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_models/library_controller.dart';
import 'widgets/library_empty_state.dart';
import 'widgets/playlist_list_item.dart';
import 'add_edit_playlist_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LibraryController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.myPlaylists.isEmpty) {
        controller.fetchMyPlaylists();
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Thư viện của bạn",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 30),
            onPressed: () => Get.to(() => const AddEditPlaylistScreen()),
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
          return const LibraryEmptyState();
        }

        return ListView.builder(
          itemCount: controller.myPlaylists.length,
          padding: const EdgeInsets.only(bottom: 100, top: 8),
          itemBuilder: (context, index) {
            final playlist = controller.myPlaylists[index];
            return PlaylistListItem(
              playlist: playlist,
              controller: controller,
            );
          },
        );
      }),
    );
  }
}
