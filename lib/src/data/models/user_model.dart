class UserModel {
  final String id;
  final String username;
  final String email;
  final String avatar;
  final String role;
  final String gender;

  // Đổi tên biến thêm hậu tố "Ids" để code dễ hiểu hơn: đây là list ID
  final List<String> likedSongIds;
  final List<String> followedArtistIds;
  final List<String> savedPlaylistIds;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.avatar,
    required this.role,
    required this.gender,
    required this.likedSongIds,
    required this.followedArtistIds,
    required this.savedPlaylistIds,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Hàm phụ để xử lý danh sách an toàn (Giống logic trong PlaylistModel của bạn)
    List<String> parseIdList(dynamic data) {
      if (data == null || data is! List) return [];
      return data.map((item) {
        // Nếu item là Map (đã populate), lấy _id
        if (item is Map) return item['_id'].toString();
        // Nếu item là String (chưa populate), lấy trực tiếp
        return item.toString();
      }).toList();
    }

    return UserModel(
      id: json['_id'] ?? '',
      username: json['username'] ?? 'User',
      email: json['email'] ?? '',

      // Xử lý ảnh: Backend có thể trả về null
      avatar: (json['avatar'] != null && json['avatar'].toString().isNotEmpty)
          ? json['avatar']
          : '',

      role: json['role'] ?? 'user',
      gender: json['gender'] ?? 'other',

      // Sử dụng hàm phụ để parse list
      likedSongIds: parseIdList(json['likedSongs']),
      followedArtistIds: parseIdList(json['followedArtists']),
      savedPlaylistIds: parseIdList(json['savedPlaylists']),
    );
  }
}
