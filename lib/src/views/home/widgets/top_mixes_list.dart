import 'package:app_nghenhac/src/core/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/album_model.dart';

class TopMixesList extends StatelessWidget {
  final List<AlbumModel> albums;

  const TopMixesList({super.key, required this.albums});

  @override
  Widget build(BuildContext context) {
    if (albums.isEmpty) return const SizedBox();

    final gradients = [
      [Colors.indigo, Colors.purple],
      [Colors.orange, Colors.red],
      [Colors.teal, Colors.blue],
      [Colors.pink, Colors.deepPurple],
    ];

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: albums.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final album = albums[index];
          final colors = gradients[index % gradients.length];

          return GestureDetector(
            onTap: () {
              Get.toNamed(AppRoutes.ALBUM_DETAIL, arguments: album);
            },
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          album.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            height: 1.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 4,
                          width: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFF30e87a),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
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
