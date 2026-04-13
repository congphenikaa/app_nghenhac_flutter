import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../view_models/auth_controller.dart';

class HomeHeader extends StatelessWidget {
  final AuthController authController;
  final VoidCallback onAvatarTap;

  const HomeHeader({
    super.key,
    required this.authController,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onAvatarTap,
                child: Obx(() {
                  final user = authController.currentUser.value;
                  final avatar = (user != null && user.avatar.isNotEmpty)
                      ? user.avatar
                      : 'https://i.pravatar.cc/150?img=11';

                  return CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(avatar),
                  );
                }),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onAvatarTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Good Evening",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Obx(
                      () => Text(
                        authController.currentUser.value?.username ??
                            "Music Lover",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
