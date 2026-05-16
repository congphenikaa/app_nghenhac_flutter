import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/user_model.dart';
import '../../../view_models/library_controller.dart';
import '../edit_profile_screen.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;
  final LibraryController libraryController;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.libraryController,
  });

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = (user.avatar.isNotEmpty)
        ? user.avatar
        : "https://i.pravatar.cc/150?img=11";

    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundImage: CachedNetworkImageProvider(avatarUrl),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user.username,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          user.email,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () {
            Get.to(() => const EditProfileScreen());
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            "Chỉnh sửa hồ sơ",
            style: TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(
              "${libraryController.myPlaylists.length}",
              "Playlist",
            ),
            _buildStatItem("${user.followedArtistIds.length}", "Following"),
            _buildStatItem("0", "Followers"),
          ],
        ),
      ],
    );
  }
}
