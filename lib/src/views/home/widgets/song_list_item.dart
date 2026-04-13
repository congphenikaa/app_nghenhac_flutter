import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/song_model.dart';
import '../../../view_models/player_controller.dart';
import '../../../view_models/home_controller.dart';

class SongListItem extends StatelessWidget {
  final SongModel song;
  final PlayerController playerController;
  final VoidCallback onTapMore;

  const SongListItem({
    super.key,
    required this.song,
    required this.playerController,
    required this.onTapMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: CachedNetworkImage(
            imageUrl: song.imageUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: Colors.grey[800]),
            errorWidget: (_, __, ___) =>
                const Icon(Icons.music_note, color: Colors.white),
          ),
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
          song.description.isNotEmpty ? song.description : song.artist,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          onPressed: onTapMore,
        ),
        onTap: () => playerController.playSong(
          song,
          newQueue: Get.find<HomeController>().songList,
        ),
      ),
    );
  }
}
