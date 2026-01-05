import 'package:app_nghenhac/src/view_models/player_controller.dart';
import 'package:app_nghenhac/src/view_models/search_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SearchPageController controller = Get.put(SearchPageController());
    final PlayerController playerController = Get.find<PlayerController>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Tiêu đề
              const Text(
                "Search",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // 2. Ô nhập liệu
              TextField(
                controller: controller.textController,
                style: const TextStyle(color: Colors.black),
                onChanged: (value) {
                  // Gọi hàm search mỗi khi gõ (có thể thêm Debounce nếu muốn tối ưu)
                  controller.searchSongs(value);
                },
                decoration: InputDecoration(
                  hintText: "What do you want to listen to?",
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 3. Kết quả tìm kiếm
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF30e87a),
                      ),
                    );
                  }

                  if (controller.textController.text.isEmpty) {
                    return const Center(
                      child: Text(
                        "Play what you love",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  if (controller.searchResults.isEmpty) {
                    return const Center(
                      child: Text(
                        "No results found",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: controller.searchResults.length,
                    // Padding dưới để tránh bị MiniPlayer che
                    padding: EdgeInsets.only(
                      bottom: playerController.currentSong.value != null
                          ? 100
                          : 20,
                    ),
                    itemBuilder: (context, index) {
                      final song = controller.searchResults[index];
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: CachedNetworkImage(
                            imageUrl: song.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => const Icon(
                              Icons.music_note,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        title: Text(
                          song.title,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          song.description,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: const Icon(
                          Icons.play_circle_outline,
                          color: Colors.white,
                        ),
                        onTap: () => playerController.playSong(song),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
