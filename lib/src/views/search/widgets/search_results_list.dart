import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/routes/app_pages.dart';
import '../../../models/artist_model.dart';
import '../../../models/song_model.dart';
import '../../../models/album_model.dart';
import '../../../view_models/player_controller.dart';
import '../../../view_models/search_controller.dart';

class SearchResultsList extends StatelessWidget {
  final SearchPageController controller;
  final PlayerController playerController;

  const SearchResultsList({
    super.key,
    required this.controller,
    required this.playerController,
  });

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSongItem(SongModel song) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CachedNetworkImage(
          imageUrl: song.imageUrl,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) =>
              Container(color: Colors.grey[800]),
        ),
      ),
      title: Text(
        song.title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        "Bài hát • ${song.artist}",
        style: TextStyle(color: Colors.grey[400], fontSize: 13),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert, color: Colors.grey),
        onPressed: () {},
      ),
      onTap: () {
        playerController.playSong(song);
      },
    );
  }

  Widget _buildArtistItem(ArtistModel artist) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey[800],
        backgroundImage: CachedNetworkImageProvider(artist.imageUrl),
      ),
      title: Text(
        artist.name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        "Nghệ sĩ",
        style: TextStyle(color: Colors.grey[400], fontSize: 13),
      ),
      onTap: () => Get.toNamed(AppRoutes.ARTIST_DETAIL, arguments: artist),
    );
  }

  Widget _buildAlbumItem(AlbumModel album) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CachedNetworkImage(
          imageUrl: album.imageUrl,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) =>
              Container(color: Colors.grey[800]),
        ),
      ),
      title: Text(
        album.title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        "Album • ${album.artistName}",
        style: TextStyle(color: Colors.grey[400], fontSize: 13),
      ),
      onTap: () => Get.toNamed(AppRoutes.ALBUM_DETAIL, arguments: album),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (controller.songResults.isEmpty &&
        controller.artistResults.isEmpty &&
        controller.albumResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              color: Colors.grey,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              "Không tìm thấy kết quả nào cho '${controller.searchText.value}'",
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      children: [
        if (controller.songResults.isNotEmpty) ...[
          _buildSectionTitle("Bài hát"),
          ...controller.songResults.map((song) => _buildSongItem(song)),
          const SizedBox(height: 20),
        ],
        if (controller.artistResults.isNotEmpty) ...[
          _buildSectionTitle("Nghệ sĩ"),
          ...controller.artistResults.map((artist) => _buildArtistItem(artist)),
          const SizedBox(height: 20),
        ],
        if (controller.albumResults.isNotEmpty) ...[
          _buildSectionTitle("Album"),
          ...controller.albumResults.map((album) => _buildAlbumItem(album)),
          const SizedBox(height: 20),
        ],
        const SizedBox(height: 80),
      ],
    );
  }
}
