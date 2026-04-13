import 'package:app_nghenhac/src/bindings/main_binding.dart';
import 'package:app_nghenhac/src/view_models/auth_controller.dart';
import 'package:app_nghenhac/src/view_models/home_controller.dart';
import 'package:app_nghenhac/src/view_models/player_controller.dart';
import 'package:app_nghenhac/src/core/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

Future<void> main() async {
  // Đảm bảo Binding được khởi tạo trước
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo JustAudioBackground
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: false,
    // --- CẤU HÌNH GIAO DIỆN CHUẨN SPOTIFY THÊM VÀO ĐÂY ---
    androidNotificationIcon: 'drawable/ic_music_note',
    androidShowNotificationBadge:
        true, // Hiện logo nhỏ xíu ở góc trái trên cùng
    artDownscaleWidth:
        300, // Ép thu nhỏ ảnh bìa để Android không bị lỗi giấu ảnh
    artDownscaleHeight: 300,
  );

  runApp(const MyApp());
}

// Chuyển MyApp thành StatefulWidget để quản lý lắng nghe Link
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    initDeepLinks();
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();

    // 1. Bắt link khi App đang tắt hoàn toàn (Cold Start)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint("Lỗi lấy Initial Link: $e");
    }

    // 2. Bắt link khi App đang chạy ngầm (Background)
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        _handleDeepLink(uri);
      },
      onError: (err) {
        debugPrint("Lỗi Stream Link: $err");
      },
    );
  }

  void _handleDeepLink(Uri uri) async {
    debugPrint("Bắt được Link: $uri");

    // Kiểm tra xem link có khớp định dạng appnghenhac://song không
    if (uri.scheme == 'appnghenhac' && uri.host == 'song') {
      final songId = uri.queryParameters['id'];

      if (songId != null && songId.isNotEmpty) {
        // QUAN TRỌNG: Đợi cho đến khi SplashScreen chạy xong và các Controller đã được khởi tạo
        while (!Get.isRegistered<HomeController>() ||
            !Get.isRegistered<PlayerController>()) {
          await Future.delayed(const Duration(milliseconds: 500));
        }

        final homeController = Get.find<HomeController>();
        final playerController = Get.find<PlayerController>();

        // Tìm bài hát trong danh sách (Thực tế bạn nên gọi API Get Song By Id ở đây)
        final songIndex = homeController.songList.indexWhere(
          (s) => s.id == songId,
        );

        if (songIndex != -1) {
          final song = homeController.songList[songIndex];

          // Ra lệnh phát nhạc
          playerController.playSong(song, newQueue: homeController.songList);

          // Hiện thông báo thành công
          Get.snackbar(
            "Đang phát",
            "Đã mở bài hát từ liên kết chia sẻ!",
            colorText: Colors.black,
            backgroundColor: const Color(0xFF30e87a),
            duration: const Duration(seconds: 3),
          );
        } else {
          Get.snackbar(
            "Lỗi",
            "Không tìm thấy bài hát này trong hệ thống.",
            colorText: Colors.white,
            backgroundColor: Colors.redAccent,
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

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
      initialBinding: MainBinding(),
      initialRoute: AppRoutes.SPLASH,
      getPages: AppPages.pages,
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
    final AuthController authController = Get.put(AuthController());

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
