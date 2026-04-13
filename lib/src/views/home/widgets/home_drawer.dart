import 'package:app_nghenhac/src/core/routes/app_pages.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../view_models/auth_controller.dart';

class HomeDrawer extends StatelessWidget {
  final AuthController authController;

  const HomeDrawer({super.key, required this.authController});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF121212),
      child: Obx(() {
        final user = authController.currentUser.value;
        final username = user?.username ?? "Khách";
        final email = user?.email ?? "Đăng nhập để đồng bộ";
        final avatar = (user != null && user.avatar.isNotEmpty)
            ? user.avatar
            : "https://i.pravatar.cc/150?img=11";

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF1C2E24),
              ),
              accountName: Text(
                username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              accountEmail: Text(
                email,
                style: const TextStyle(color: Colors.white70),
              ),
              currentAccountPicture: GestureDetector(
                onTap: () {
                  Get.back();
                  Get.toNamed(AppRoutes.PROFILE);
                },
                child: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(avatar),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title: const Text("Hồ sơ", style: TextStyle(color: Colors.white)),
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.PROFILE);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.white),
              title: const Text(
                "Mới phát gần đây",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text(
                "Cài đặt",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Get.back();
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(color: Colors.grey, thickness: 0.5),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                "Đăng xuất",
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () => authController.logout(),
            ),
          ],
        );
      }),
    );
  }
}
