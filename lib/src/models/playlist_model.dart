class PlaylistModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String creatorId;
  final List<String> songIds;

  PlaylistModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.creatorId,
    required this.songIds,
  });

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    // 1. Xử lý songs (List of IDs or Objects)
    List<String> songs = [];
    if (json['songs'] != null && json['songs'] is List) {
      songs = (json['songs'] as List).map((item) {
        if (item is Map) return item['_id'].toString();
        return item.toString();
      }).toList();
    }

    // 2. Xử lý creator (Tránh lỗi Crash)
    // Backend getUserPlaylists trả về ID (String)
    // Backend getPlaylistById trả về Object (Map)
    String creatorId = '';
    if (json['creator'] != null) {
      if (json['creator'] is Map) {
        creatorId = json['creator']['_id'].toString();
      } else {
        creatorId = json['creator'].toString();
      }
    }

    // 3. Xử lý image
    // Backend bây giờ đảm bảo luôn có ảnh (từ Cloudinary hoặc mặc định upload lên Cloudinary)
    String img = json['image'] ?? '';

    return PlaylistModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown Playlist',
      description: json['description'] ?? '',
      imageUrl: img,
      creatorId: creatorId,
      songIds: songs,
    );
  }
}
