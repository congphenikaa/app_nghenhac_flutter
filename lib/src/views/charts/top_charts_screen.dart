import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/song_model.dart';
import '../../view_models/chart_controller.dart';
import '../../view_models/player_controller.dart';
import 'widgets/chart_header.dart';
import 'widgets/chart_song_item.dart';

class TopChartsScreen extends StatelessWidget {
  final ChartController chartController;
  final PlayerController playerController;

  const TopChartsScreen({
    super.key,
    required this.chartController,
    required this.playerController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        color: const Color(0xFF30e87a),
        backgroundColor: Colors.grey[900],
        onRefresh: () async {
          await chartController.fetchTrendingTop();
        },
        child: CustomScrollView(
          slivers: [
            ChartHeader(
              chartController: chartController,
              playerController: playerController,
            ),
            ChartPlayButton(
              chartController: chartController,
              playerController: playerController,
            ),
            Obx(() {
              if (chartController.isLoading.value) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF30e87a)),
                  ),
                );
              }

              final displayList = chartController.topSongsData
                  .take(20)
                  .toList();
              final topPlaylist = displayList
                  .map((e) => SongModel.fromJson(e['song']))
                  .toList();

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return ChartSongItem(
                    index: index,
                    itemData: displayList[index],
                    topPlaylist: topPlaylist,
                    playerController: playerController,
                  );
                }, childCount: displayList.length),
              );
            }),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
