import 'package:app_nghenhac/app_binding.dart';
import 'package:app_nghenhac/src/view_models/auth_controller.dart';
import 'package:app_nghenhac/src/views/MiniPlayer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Spotify Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF1DB954),
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),
      initialBinding: AppBinding(),
      home: const SplashScreen(), // Chạy Splash trước
      builder: (context, child) {
        return Scaffold(
          // child chính là màn hình hiện tại (Home, Settings, Player, v.v.)
          // Chúng ta dùng Stack để đặt MiniPlayer đè lên child
          body: Stack(
            children: [
              // Lớp 1: Màn hình ứng dụng
              // Cần bao bọc trong một Widget để xử lý padding dưới đáy
              // (tránh bị MiniPlayer che mất nội dung cuối list)
              Positioned.fill(child: child ?? const SizedBox()),

              // Lớp 2: Mini Player
              const Positioned(
                bottom: 75,
                left: 0,
                right: 0,
                // MiniPlayer sẽ tự ẩn hiện nhờ logic Obx bên trong nó
                child: MiniPlayer(),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Màn hình chờ đơn giản
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Gọi AuthController để check login ngay khi màn hình này hiện lên
    final AuthController authController = Get.put(AuthController());

    // Check sau 2 giây cho có hiệu ứng chờ
    Future.delayed(const Duration(seconds: 2), () {
      authController.checkLoginStatus();
    });

    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Icon(Icons.music_note, size: 100, color: Color(0xFF1DB954)),
      ),
    );
  }
}
