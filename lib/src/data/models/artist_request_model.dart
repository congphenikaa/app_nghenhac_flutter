class ArtistRequestModel {
  final String id;
  final String userId;
  final String artistName;
  final String bio;
  final List<String> genre;
  final Map<String, String> socialLinks;
  final String reason;
  final String status; // pending, approved, rejected
  final String? adminNote;
  final DateTime createdAt;

  ArtistRequestModel({
    required this.id,
    required this.userId,
    required this.artistName,
    required this.bio,
    required this.genre,
    required this.socialLinks,
    required this.reason,
    required this.status,
    this.adminNote,
    required this.createdAt,
  });

  factory ArtistRequestModel.fromJson(Map<String, dynamic> json) {
    return ArtistRequestModel(
      id: json['_id'],
      userId: json['user'],
      artistName: json['artistName'],
      bio: json['bio'] ?? '',
      genre: List<String>.from(json['genre'] ?? []),
      socialLinks: Map<String, String>.from(json['socialLinks'] ?? {}),
      reason: json['reason'] ?? '',
      status: json['status'],
      adminNote: json['adminNote'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
