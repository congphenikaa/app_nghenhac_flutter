import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../view_models/player_controller.dart';
import '../../../models/song_model.dart';

class QuickAccessGrid extends StatelessWidget {
  final List<SongModel> songs;
  final PlayerController playerController;

  const QuickAccessGrid({
    super.key,
    required this.songs,
    required this.playerController,
  });

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) return const SizedBox();
    final displayList = songs.take(6).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: displayList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          final song = displayList[index];
          return GestureDetector(
            onTap: () => playerController.playSong(song, newQueue: songs),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1C2E24),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: song.imageUrl,
                      width: 55,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.music_note,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        song.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
