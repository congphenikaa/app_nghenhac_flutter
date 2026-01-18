import 'dart:convert';
import 'package:app_nghenhac/src/configs/app_urls.dart';
import 'package:app_nghenhac/src/models/category_model.dart';
import 'package:app_nghenhac/src/models/song_model.dart';
import 'package:app_nghenhac/src/view_models/player_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CategoryDetailScreen extends StatefulWidget {
  final CategoryModel category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  // Chỉ lấy PlayerController để phát nhạc (cái này dùng chung được)
  final PlayerController _playerController = Get.find<PlayerController>();

  // --- QUẢN LÝ TRẠNG THÁI RIÊNG CỦA MÀN HÌNH NÀY ---
  // Dùng RxList và RxBool cục bộ, không phụ thuộc vào HomeController nữa
  final RxList<SongModel> _localSongList = <SongModel>[].obs;
  final RxBool _isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    // Gọi hàm lấy dữ liệu ngay khi vào màn
    _fetchSongsForThisCategory();
  }

  Future<void> _fetchSongsForThisCategory() async {
    try {
      _isLoading.value = true;

      // Giả sử đường dẫn API của bạn
      final url = '${AppUrls.songByCategory}/${widget.category.id}';
      print("Đang lấy nhạc từ: $url");

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        // Kiểm tra cấu trúc JSON trả về (sửa lại theo đúng backend của bạn)
        if (data['success'] == true || data['songs'] != null) {
          final List<dynamic> songsJson = data['songs'];
          _localSongList.value = songsJson
              .map((json) => SongModel.fromJson(json))
              .toList();
        }
      }
    } catch (e) {
      print("Lỗi lấy nhạc: $e");
    } finally {
      // Dù thành công hay thất bại cũng tắt loading
      _isLoading.value = false;
    }
  }

  Color _hexToColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _hexToColor(widget.category.color);

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // 1. App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: bgColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.category.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [bgColor, Colors.black],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      bottom: -20,
                      child: Transform.rotate(
                        angle: 15 * 3.14 / 180,
                        child: Opacity(
                          opacity: 0.4,
                          child: CachedNetworkImage(
                            imageUrl: widget.category.image,
                            width: 250,
                            height: 250,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) =>
                                const SizedBox(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Danh sách bài hát (Lắng nghe biến cục bộ _localSongList)
          Obx(() {
            if (_isLoading.value) {
              return const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF30e87a)),
                ),
              );
            }

            if (_localSongList.isEmpty) {
              return const SliverFillRemaining(
                child: Center(
                  child: Text(
                    "Chưa có bài hát nào",
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final song = _localSongList[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CachedNetworkImage(
                      imageUrl: song.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: Colors.grey[900]),
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.music_note, color: Colors.white),
                    ),
                  ),
                  title: Text(
                    song.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    song.artist,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.play_circle_fill,
                      color: Color(0xFF30e87a),
                    ),
                    onPressed: () => _playerController.playSong(song),
                  ),
                  onTap: () => _playerController.playSong(song),
                );
              }, childCount: _localSongList.length),
            );
          }),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
