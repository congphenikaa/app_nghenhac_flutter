import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageColorService {
  static Future<Color> getDominantColor(String imageUrl) async {
    if (imageUrl.isEmpty) return const Color(0xFF121212);
    try {
      final PaletteGenerator generator =
          await PaletteGenerator.fromImageProvider(
        CachedNetworkImageProvider(imageUrl),
      );
      return generator.dominantColor?.color ?? const Color(0xFF121212);
    } catch (e) {
      return const Color(0xFF121212);
    }
  }
}
