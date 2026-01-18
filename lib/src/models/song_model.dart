class SongModel {
  String id;
  String title;
  String description;
  String album;
  String artist;
  String audioUrl;
  String imageUrl;
  int duration;
  int plays;

  SongModel({
    required this.id,
    required this.title,
    required this.description,
    required this.album,
    required this.artist,
    required this.audioUrl,
    required this.imageUrl,
    required this.duration,
    required this.plays,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? "Không tên",
      description: json['description'] ?? '',

      // --- XỬ LÝ ALBUM ---
      album: (json['album'] is Map)
          ? (json['album']['title'] ?? json['album']['name'] ?? "Album")
          : (json['album']?.toString() ?? "Single"),

      // --- XỬ LÝ ARTIST ---
      artist: (json['artist'] is Map)
          ? (json['artist']['name'] ??
                json['artist']['title'] ??
                "Unknown Artist")
          : (json['artist']?.toString() ?? "Unknown Artist"),

      audioUrl: json['audioUrl'] ?? '',
      imageUrl: json['imageUrl'] ?? '',

      // --- XỬ LÝ DURATION ---
      duration: json['duration'] is int
          ? json['duration']
          : int.tryParse(json['duration'].toString()) ?? 0,

      // --- XỬ LÝ PLAYS ---
      plays: json['plays'] is int
          ? json['plays']
          : int.tryParse(json['plays'].toString()) ?? 0,
    );
  }
}
