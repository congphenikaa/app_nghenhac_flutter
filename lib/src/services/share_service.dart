import 'dart:io';
import 'package:app_nghenhac/src/data/models/song_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'image_color_service.dart';

class ShareService {
  static Future<void> shareSongToStory(
    BuildContext context,
    SongModel song,
    String linkUrl,
  ) async {
    // Show a loading dialog
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Color(0xFF30e87a))),
      barrierDismissible: false,
    );

    try {
      if (context.mounted) {
        await precacheImage(CachedNetworkImageProvider(song.imageUrl), context);
      }

      final dominantColor = await ImageColorService.getDominantColor(
        song.imageUrl,
      );
      final screenshotController = ScreenshotController();

      final Widget shareWidget = MediaQuery(
        data: const MediaQueryData(),
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            width: 1080,
            height: 1080,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [dominantColor, const Color(0xFF121212)],
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                width: 1080,
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 80),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Color(0xFF30e87a),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.music_note,
                              color: Colors.black,
                              size: 40,
                            ),
                          ),
                          const SizedBox(width: 20),
                          const Text(
                            "My Music",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                    Container(
                      width: 550,
                      height: 550,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.7),
                            blurRadius: 60,
                            offset: const Offset(0, 30),
                          ),
                        ],
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(song.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 80),
                      child: Column(
                        children: [
                          Text(
                            song.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 45,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            song.artist,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 30,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      final bytes = await screenshotController.captureFromWidget(
        shareWidget,
        delay: const Duration(milliseconds: 150),
        context: context,
      );

      final directory = await getTemporaryDirectory();
      final imagePath = await File(
        '${directory.path}/share_${song.id}.png',
      ).create();
      await imagePath.writeAsBytes(bytes);

      if (Get.isDialogOpen == true) Get.back();

      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text:
            '🎵 Mình đang nghe "${song.title}" của ${song.artist}!\n🔗 Nghe ngay tại: $linkUrl',
      );
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      Get.snackbar(
        "Lỗi",
        "Không thể chia sẻ bài hát: $e",
        colorText: Colors.white,
      );
    }
  }
}
