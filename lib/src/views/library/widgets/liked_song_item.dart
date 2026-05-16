import 'package:flutter/material.dart';
import '../../../data/models/song_model.dart';
import '../../../view_models/player_controller.dart';
import '../../../view_models/auth_controller.dart';

class LikedSongItem extends StatelessWidget {
  final int index;
  final SongModel song;
  final List<SongModel> currentQueue;
  final PlayerController playerController;
  final AuthController authController;
  final VoidCallback onUnlike;

  const LikedSongItem({
    super.key,
    required this.index,
    required this.song,
    required this.currentQueue,
    required this.playerController,
    required this.authController,
    required this.onUnlike,
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
        song.artist,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.favorite, color: Color(0xFF30e87a)),
        onPressed: () {
          authController.toggleLikeSong(song.id);
          onUnlike();
        },
      ),
      onTap: () => playerController.playSong(song, newQueue: currentQueue),
    );
  }
}
