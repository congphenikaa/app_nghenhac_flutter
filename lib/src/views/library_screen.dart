import 'package:app_nghenhac/src/view_models/library_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_nghenhac/src/views/playlist_detail_screen.dart';
import 'add_edit_playlist_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LibraryController());

    // Đảm bảo dữ liệu được load khi vào màn hình này
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

        // TRẠNG THÁI TRỐNG (EMPTY STATE)
        if (controller.myPlaylists.isEmpty) {
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

        // DANH SÁCH PLAYLIST
        return ListView.builder(
          itemCount: controller.myPlaylists.length,
          padding: const EdgeInsets.only(bottom: 100, top: 8),
          itemBuilder: (context, index) {
            final playlist = controller.myPlaylists[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(6), // Bo góc ảnh mượt hơn
                  child: playlist.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: playlist.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: Colors.grey[900]),
                          errorWidget: (_, __, ___) => Container(
                            color: Colors.grey[900],
                            width: 60,
                            height: 60,
                            child: const Icon(
                              Icons.music_note,
                              color: Colors.white54,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[900],
                          width: 60,
                          height: 60,
                          child: const Icon(
                            Icons.music_note,
                            color: Colors.white54,
                          ),
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
                // --- THAY THẾ NÚT XÓA BẰNG MENU TÙY CHỌN (SỬA / XÓA) ---
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  color: Colors.grey[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      // Chuyển sang màn hình Sửa với dữ liệu có sẵn
                      Get.to(
                        () => AddEditPlaylistScreen(
                          playlistId: playlist.id,
                          initialName: playlist.name,
                          initialDesc: playlist.description,
                          initialImageUrl: playlist.imageUrl,
                        ),
                      )?.then((isUpdated) {
                        // Nếu user bấm lưu thành công, tải lại danh sách ngầm
                        if (isUpdated == true) {
                          controller.fetchMyPlaylists(isSilent: true);
                        }
                      });
                    } else if (value == 'delete') {
                      Get.defaultDialog(
                        title: "Xóa Playlist",
                        titleStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        middleText:
                            "Bạn có chắc chắn muốn xóa playlist này không?",
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
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.white, size: 20),
                              SizedBox(width: 12),
                              Text(
                                'Chỉnh sửa',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Xóa',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ],
                          ),
                        ),
                      ],
                ),
                onTap: () {
                  // Chuyển sang màn hình chi tiết Playlist
                  Get.to(
                    () => PlaylistDetailScreen(
                      playlistId: playlist.id,
                      playlistName: playlist.name,
                      imageUrl: playlist.imageUrl,
                    ),
                  );
                },
              ),
            );
          },
        );
      }),
    );
  }
}
