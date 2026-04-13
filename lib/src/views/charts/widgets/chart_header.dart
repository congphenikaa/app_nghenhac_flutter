import 'package:flutter/material.dart';
import '../../../models/song_model.dart';
import '../../../view_models/chart_controller.dart';
import '../../../view_models/player_controller.dart';

class ChartHeader extends StatelessWidget {
  final ChartController chartController;
  final PlayerController playerController;

  const ChartHeader({
    super.key,
    required this.chartController,
    required this.playerController,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
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
                const Color(0xFF30e87a).withOpacity(0.6),
                Colors.black,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.bar_chart_rounded,
              size: 100,
              color: Colors.white,
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0), // Play button will overlap
        child: Container(),
      ),
    );
  }
}

class ChartPlayButton extends StatelessWidget {
  final ChartController chartController;
  final PlayerController playerController;

  const ChartPlayButton({
    super.key,
    required this.chartController,
    required this.playerController,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
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
    );
  }
}
