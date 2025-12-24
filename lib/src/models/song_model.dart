class SongModel {
  String id;
  String title;
  String description;
  String album;
  String artist;
  String audioUrl;
  String imageUrl;
  int duration;

  SongModel({
    required this.id,
    required this.title,
    required this.description,
    required this.album,
    required this.artist,
    required this.audioUrl,
    required this.imageUrl,
    required this.duration,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? "Không tên",
      description: json['description'] ?? '',

      // --- XỬ LÝ ALBUM ---
      // Kiểm tra nếu album là một Object (Map) thì lấy tên, nếu không thì lấy chuỗi hoặc mặc định
      album: (json['album'] is Map)
          ? (json['album']['title'] ?? json['album']['name'] ?? "Album")
          : (json['album']?.toString() ?? "Single"),

      // --- XỬ LÝ ARTIST ---
      // Backend có populate artist, nên cũng phải check Map tương tự
      artist: (json['artist'] is Map)
          ? (json['artist']['name'] ??
                json['artist']['title'] ??
                "Unknown Artist")
          : (json['artist']?.toString() ?? "Unknown Artist"),

      audioUrl: json['audioUrl'] ?? '',
      imageUrl: json['imageUrl'] ?? '',

      duration: json['duration'] is int
          ? json['duration']
          : int.tryParse(json['duration'].toString()) ?? 0,
    );
  }
}
