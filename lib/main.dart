import 'package:app_nghenhac/app_binding.dart';
import 'package:app_nghenhac/src/view_models/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';

Future<void> main() async {
  // Đảm bảo Binding được khởi tạo trước
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo JustAudioBackground
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

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
      home: const SplashScreen(),

      builder: (context, child) {
        return MediaQuery(
          // Đảm bảo text scale không phá vỡ giao diện
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child ?? const SizedBox(),
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
