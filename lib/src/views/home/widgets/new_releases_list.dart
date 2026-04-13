import 'package:app_nghenhac/src/core/routes/app_pages.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../models/album_model.dart';

class NewReleasesList extends StatelessWidget {
  final List<AlbumModel> albums;

  const NewReleasesList({
    super.key,
    required this.albums,
  });

  @override
  Widget build(BuildContext context) {
    if (albums.isEmpty) return const SizedBox();
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: albums.length > 5 ? 5 : albums.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final album = albums.reversed.toList()[index];
          return GestureDetector(
            onTap: () {
              Get.toNamed(AppRoutes.ALBUM_DETAIL, arguments: album);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: album.imageUrl,
                    width: 140,
                    height: 140,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: Colors.grey[800]),
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.album, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 140,
                  child: Text(
                    album.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 140,
                  child: Text(
                    album.artistName,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
