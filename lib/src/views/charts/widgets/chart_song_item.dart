import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/song_model.dart';
import '../../../view_models/player_controller.dart';

class ChartSongItem extends StatelessWidget {
  final int index;
  final dynamic itemData;
  final List<SongModel> topPlaylist;
  final PlayerController playerController;

  const ChartSongItem({
    super.key,
    required this.index,
    required this.itemData,
    required this.topPlaylist,
    required this.playerController,
  });

  @override
  Widget build(BuildContext context) {
    final int rank = itemData['rank'] ?? (index + 1);
    final song = SongModel.fromJson(itemData['song']);
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
      ),
      onTap: () {
        playerController.playSong(song, newQueue: topPlaylist);
      },
    );
  }
}
