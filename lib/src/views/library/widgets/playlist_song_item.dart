import 'package:flutter/material.dart';
import '../../../models/song_model.dart';
import '../../../view_models/player_controller.dart';

class PlaylistSongItem extends StatelessWidget {
  final int index;
  final SongModel song;
  final List<SongModel> currentQueue;
  final PlayerController playerController;
  final VoidCallback onOptionsTap;

  const PlaylistSongItem({
    super.key,
    required this.index,
    required this.song,
    required this.currentQueue,
    required this.playerController,
    required this.onOptionsTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(
        "${index + 1}",
        style: const TextStyle(color: Colors.white, fontSize: 16),
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
        song.description,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert, color: Colors.grey),
        onPressed: onOptionsTap,
      ),
      onTap: () => playerController.playSong(song, newQueue: currentQueue),
    );
  }
}
