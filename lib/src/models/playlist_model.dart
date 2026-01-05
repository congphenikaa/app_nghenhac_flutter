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
    List<String> songs = [];
    if (json['songs'] != null && json['songs'] is List) {
      songs = (json['songs'] as List).map((item) {
        if (item is Map) return item['_id'].toString();
        return item.toString();
      }).toList();
    }

    String img = json['image'] ?? '';
    // Nếu rỗng, gán luôn ảnh mặc định tại đây
    if (img.isEmpty) {
      img =
          "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?q=80&w=2070&auto=format&fit=crop";
    }

    return PlaylistModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown Playlist',
      description: json['description'] ?? '',
      imageUrl: img,
      creatorId: json['creator'] ?? '',
      songIds: songs,
    );
  }
}
