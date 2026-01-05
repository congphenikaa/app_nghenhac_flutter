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

    return PlaylistModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown Playlist',
      description: json['description'] ?? '',
      imageUrl: json['image'] ?? '',
      creatorId: json['creator'] ?? '',
      songIds: songs,
    );
  }
}
