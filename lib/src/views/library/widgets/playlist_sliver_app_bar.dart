import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../add_edit_playlist_screen.dart';
import '../../../view_models/library_controller.dart';

class PlaylistSliverAppBar extends StatelessWidget {
  final String playlistId;
  final String currentName;
  final String currentDesc;
  final String currentImageUrl;
  final VoidCallback onDetailsUpdated;
  final LibraryController libraryController;

  const PlaylistSliverAppBar({
    super.key,
    required this.playlistId,
    required this.currentName,
    required this.currentDesc,
    required this.currentImageUrl,
    required this.onDetailsUpdated,
    required this.libraryController,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.black,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white),
          onPressed: () {
            Get.to(
              () => AddEditPlaylistScreen(
                playlistId: playlistId,
                initialName: currentName,
                initialDesc: currentDesc,
                initialImageUrl: currentImageUrl,
              ),
            )?.then((isUpdated) {
              if (isUpdated == true) {
                onDetailsUpdated();
                libraryController.fetchMyPlaylists(isSilent: true);
              }
            });
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(currentName, style: const TextStyle(fontSize: 16)),
        background: Stack(
          fit: StackFit.expand,
          children: [
            currentImageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: currentImageUrl,
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
    );
  }
}
