class AlbumModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String artistName; // Tên nghệ sĩ

  AlbumModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.artistName,
  });

  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    // Xử lý an toàn: backend có thể trả về object Artist (đã populate) hoặc chỉ là ID string
    String artist = "Unknown Artist";
    if (json['artist'] != null) {
      if (json['artist'] is Map) {
        artist = json['artist']['name'] ?? "Unknown";
      } else if (json['artist'] is String) {
        artist = "Artist ID: ${json['artist']}"; // Fallback nếu chưa populate
      }
    }

    return AlbumModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? 'Unknown Album',
      description: json['description'] ?? '',
      imageUrl: json['image'] ?? '',
      artistName: artist,
    );
  }
}
