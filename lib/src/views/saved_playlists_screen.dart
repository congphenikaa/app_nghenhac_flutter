import 'package:app_nghenhac/src/views/playlist_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../view_models/library_controller.dart';

class SavedPlaylistsScreen extends StatefulWidget {
  const SavedPlaylistsScreen({super.key});

  @override
  State<SavedPlaylistsScreen> createState() => _SavedPlaylistsScreenState();
}

class _SavedPlaylistsScreenState extends State<SavedPlaylistsScreen> {
  // Dùng Get.put để đảm bảo controller tồn tại
  final LibraryController libraryController = Get.put(LibraryController());

  @override
  void initState() {
    super.initState();
    // Đợi frame dựng xong rồi mới fetch dữ liệu để tránh lỗi setState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      libraryController.fetchMyPlaylists();
    });
  }

  // --- HÀM TẠO PLAYLIST (Được thêm vào theo yêu cầu) ---
  void _showCreateDialog(BuildContext context) {
    final textController = TextEditingController();
    Get.defaultDialog(
      title: "Tạo Playlist Mới",
      titleStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      radius: 10,
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Nhập tên playlist"),
        ),
      ),
      textConfirm: "Tạo",
      textCancel: "Hủy",
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.white,
      onConfirm: () {
        if (textController.text.trim().isNotEmpty) {
          libraryController.createPlaylist(textController.text.trim());
          Get.back(); // Đóng dialog sau khi tạo
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Danh sách phát",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          // Nút thêm (+) gọi hàm hiển thị dialog
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              _showCreateDialog(context);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (libraryController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF30e87a)),
          );
        }

        if (libraryController.myPlaylists.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.music_note, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  "Bạn chưa có danh sách phát nào",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Hãy tạo playlist mới hoặc lưu từ thư viện",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                // Nút tạo playlist khi danh sách trống
                ElevatedButton(
                  onPressed: () {
                    _showCreateDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Tạo Playlist"),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: libraryController.myPlaylists.length,
          itemBuilder: (context, index) {
            final playlist = libraryController.myPlaylists[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  Get.to(
                    () => PlaylistDetailScreen(
                      playlistId: playlist.id,
                      playlistName: playlist.name,
                      imageUrl: playlist.imageUrl,
                    ),
                  );
                },
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CachedNetworkImage(
                    imageUrl: playlist.imageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: Colors.grey[800]),
                    errorWidget: (_, __, ___) => Container(
                      color: Colors.grey[800],
                      child: const Icon(Icons.music_note, color: Colors.white),
                    ),
                  ),
                ),
                title: Text(
                  playlist.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  "Playlist • ${playlist.songIds.length} bài hát",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              ),
            );
          },
        );
      }),
    );
  }
}
