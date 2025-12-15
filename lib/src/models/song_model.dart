class SongModel {
  String id;
  String title;
  String description;
  String album;
  String audioUrl;
  String imageUrl;
  int duration;

  SongModel({
    required this.id,
    required this.title,
    required this.description,
    required this.album,
    required this.audioUrl,
    required this.imageUrl,
    required this.duration,
  });

  // Ham chuyen doi tu JSON cua nodejs traa ve objec cho dart
  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['_id'],
      title: json['title'] ?? "Khong ten",
      description: json['description'] ?? '',
      album: json['album'] ?? "Single",
      audioUrl: json['audioUrl'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      duration: json['duration'] is int
          ? json['duration']
          : int.tryParse(json['duration'].toString()) ?? 0,
    );
  }
}
