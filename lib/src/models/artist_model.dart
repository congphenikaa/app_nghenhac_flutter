class ArtistModel {
  final String id;
  final String name;
  final String imageUrl;
  final String bio;
  final int followersCount;

  ArtistModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.bio,
    required this.followersCount,
  });

  factory ArtistModel.fromJson(Map<String, dynamic> json) {
    return ArtistModel(
      // MongoDB trả về _id
      id: json['_id'] ?? '',

      // Map các trường tương ứng
      name: json['name'] ?? 'Unknown Artist',

      // Node.js bạn dùng 'image' -> Flutter map sang 'imageUrl'
      imageUrl: json['image'] ?? '',

      bio: json['bio'] ?? '',

      // Xử lý số nguyên, fallback về 0 nếu null
      followersCount: json['followersCount'] ?? 0,
    );
  }
}
