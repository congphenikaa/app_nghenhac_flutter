import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../view_models/chart_controller.dart';
import '../../../view_models/player_controller.dart';
import '../../../data/models/song_model.dart';

class TrendingChartList extends StatelessWidget {
  final ChartController chartController;
  final PlayerController playerController;

  const TrendingChartList({
    super.key,
    required this.chartController,
    required this.playerController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (chartController.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF30e87a)),
        );
      }

      if (chartController.topSongsData.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Hôm nay chưa có lượt nghe nào. Hãy là người đầu tiên!",
            style: TextStyle(color: Colors.white54),
          ),
        );
      }

      final displayList = chartController.topSongsData.take(5).toList();

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: displayList.length,
        itemBuilder: (context, index) {
          final item = displayList[index];
          final int rank = item['rank'] ?? (index + 1);

          final songData = item['song'];
          final song = SongModel.fromJson(songData);
          final int playCount = song.plays;

          Color rankColor = Colors.white;
          if (rank == 1) rankColor = Colors.amber;
          if (rank == 2) rankColor = Colors.grey[400]!;
          if (rank == 3) rankColor = Colors.brown[300]!;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
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
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CachedNetworkImage(
                      imageUrl: song.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.music_note, color: Colors.white),
                    ),
                  ),
                ],
              ),
              title: Text(
                song.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${song.artist} • $playCount lượt nghe',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(
                Icons.play_circle_fill,
                color: Color(0xFF30e87a),
                size: 32,
              ),
              onTap: () {
                List<SongModel> topPlaylist = chartController.topSongsData
                    .map((e) => SongModel.fromJson(e['song']))
                    .toList();

                playerController.playSong(song, newQueue: topPlaylist);
              },
            ),
          );
        },
      );
    });
  }
}
