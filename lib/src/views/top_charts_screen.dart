import 'package:app_nghenhac/src/models/song_model.dart';
import 'package:app_nghenhac/src/view_models/chart_controller.dart';
import 'package:app_nghenhac/src/view_models/player_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
// Nhớ import các Controller và Model của bạn vào đây

class TopChartsScreen extends StatelessWidget {
  final ChartController chartController;
  final PlayerController playerController;

  const TopChartsScreen({
    Key? key,
    required this.chartController,
    required this.playerController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Màu nền đen đặc trưng
      body: CustomScrollView(
        slivers: [
          // 1. Phần Header cuộn có Gradient giống Spotify
          SliverAppBar(
            expandedHeight: 280.0,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                "Top 20 Thịnh Hành",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF30e87a).withOpacity(0.6), // Xanh Spotify
                      Colors.black,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: const Center(
                  // Có thể thay Icon này bằng một ảnh cover thật đẹp sau này
                  child: Icon(
                    Icons.bar_chart_rounded,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // 2. Nút Play "to đùng" nổi bật
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    backgroundColor: const Color(0xFF30e87a),
                    shape: const CircleBorder(),
                    onPressed: () {
                      // Bấm vào đây sẽ phát ngay bài Top 1 và nhét cả 20 bài vào hàng chờ
                      List<SongModel> topPlaylist = chartController.topSongsData
                          .take(20)
                          .map((e) => SongModel.fromJson(e['song']))
                          .toList();
                      if (topPlaylist.isNotEmpty) {
                        playerController.playSong(
                          topPlaylist[0],
                          newQueue: topPlaylist,
                        );
                      }
                    },
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.black,
                      size: 36,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Danh sách Top 20 bài hát
          Obx(() {
            if (chartController.isLoading.value) {
              return const SliverToBoxAdapter(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF30e87a)),
                ),
              );
            }

            // Lấy ra 20 bài
            final displayList = chartController.topSongsData.take(20).toList();

            return SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = displayList[index];
                final int rank = item['rank'] ?? (index + 1);
                final song = SongModel.fromJson(item['song']);
                final int playCount = song.plays;

                Color rankColor = Colors.white;
                if (rank == 1) rankColor = Colors.amber;
                if (rank == 2) rankColor = Colors.grey[400]!;
                if (rank == 3) rankColor = Colors.brown[300]!;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 30,
                        child: Text(
                          '$rank',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: rankColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: CachedNetworkImage(
                          imageUrl: song.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                  title: Text(
                    song.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${song.artist} • $playCount lượt',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  trailing: const Icon(
                    Icons.more_vert,
                    color: Colors.grey,
                  ), // Menu 3 chấm chuẩn Spotify
                  onTap: () {
                    List<SongModel> topPlaylist = chartController.topSongsData
                        .take(20)
                        .map((e) => SongModel.fromJson(e['song']))
                        .toList();
                    playerController.playSong(song, newQueue: topPlaylist);
                  },
                );
              }, childCount: displayList.length),
            );
          }),

          // Khoảng trống dưới cùng để cuộn không bị vướng thanh MiniPlayer
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
