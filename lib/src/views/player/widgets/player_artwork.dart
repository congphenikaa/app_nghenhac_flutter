import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../view_models/player_controller.dart';

class PlayerArtwork extends StatelessWidget {
  const PlayerArtwork({super.key});

  @override
  Widget build(BuildContext context) {
    final PlayerController controller = Get.find<PlayerController>();

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! > 0) {
            controller.previousSong();
          } else if (details.primaryVelocity! < 0) {
            controller.nextSong();
          }
        }
      },
      child: Obx(
        () => Container(
          height: 320,
          width: 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: CachedNetworkImageProvider(
                controller.currentSong.value?.imageUrl ?? "",
              ),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
