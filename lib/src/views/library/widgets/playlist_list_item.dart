import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_pages.dart';
import '../../../view_models/library_controller.dart';
import '../../../data/models/playlist_model.dart';
import '../add_edit_playlist_screen.dart';

class PlaylistListItem extends StatelessWidget {
  final PlaylistModel playlist;
  final LibraryController controller;

  const PlaylistListItem({
    super.key,
    required this.playlist,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: playlist.imageUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: playlist.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: Colors.grey[900]),
                  errorWidget: (_, __, ___) => Container(
                    color: Colors.grey[900],
                    width: 60,
                    height: 60,
                    child: const Icon(Icons.music_note, color: Colors.white54),
                  ),
                )
              : Container(
                  color: Colors.grey[900],
                  width: 60,
                  height: 60,
                  child: const Icon(Icons.music_note, color: Colors.white54),
                ),
        ),
        title: Text(
          playlist.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            "Playlist • ${playlist.songIds.length} bài hát",
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          color: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (value) {
            if (value == 'edit') {
              Get.to(
                () => AddEditPlaylistScreen(
                  playlistId: playlist.id,
                  initialName: playlist.name,
                  initialDesc: playlist.description,
                  initialImageUrl: playlist.imageUrl,
                ),
              )?.then((isUpdated) {
                if (isUpdated == true) {
                  controller.fetchMyPlaylists(isSilent: true);
                }
              });
            } else if (value == 'delete') {
              Get.defaultDialog(
                title: "Xóa Playlist",
                titleStyle: const TextStyle(fontWeight: FontWeight.bold),
                middleText: "Bạn có chắc chắn muốn xóa playlist này không?",
                textConfirm: "Xóa",
                textCancel: "Hủy",
                confirmTextColor: Colors.white,
                cancelTextColor: Colors.white,
                buttonColor: Colors.redAccent,
                radius: 10,
                onConfirm: () {
                  controller.removePlaylist(playlist.id);
                  Get.back();
                },
              );
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Text('Chỉnh sửa', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  SizedBox(width: 12),
                  Text('Xóa', style: TextStyle(color: Colors.redAccent)),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          Get.toNamed(AppRoutes.PLAYLIST_DETAIL, arguments: playlist);
        },
      ),
    );
  }
}
