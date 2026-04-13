import 'package:get/get.dart';
import '../../views/auth/login_screen.dart';
import '../../views/auth/register_screen.dart';
import '../../views/main/main_wrapper.dart';
import '../../views/profile/profile_screen.dart';
import '../../views/album/album_detail_screen.dart';
import '../../views/artist/artist_detail_screen.dart';
import '../../views/library/playlist_detail_screen.dart';
import '../../views/charts/top_charts_screen.dart';
import '../../views/player/player_screen.dart';
import '../../views/category/category_detail_screen.dart';
import '../../bindings/home_binding.dart';
import '../../bindings/library_binding.dart';
import '../../bindings/search_binding.dart';
import '../../../../main.dart'; 

part 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.REGISTER,
      page: () => const RegisterScreen(),
    ),
    GetPage(
      name: AppRoutes.MAIN,
      page: () => const MainWrapper(),
      bindings: [
        HomeBinding(),
        LibraryBinding(),
        SearchBinding(),
      ],
    ),
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => const ProfileScreen(),
    ),
    GetPage(
      name: AppRoutes.ALBUM_DETAIL,
      page: () => AlbumDetailScreen(album: Get.arguments),
    ),
    GetPage(
      name: AppRoutes.ARTIST_DETAIL,
      page: () => ArtistDetailScreen(artist: Get.arguments),
    ),
    GetPage(
      name: AppRoutes.PLAYLIST_DETAIL,
      page: () => PlaylistDetailScreen(
        playlistId: Get.arguments.id,
        playlistName: Get.arguments.name,
        imageUrl: Get.arguments.imageUrl,
      ),
    ),
    GetPage(
      name: AppRoutes.TOP_CHARTS,
      page: () => TopChartsScreen(
        chartController: Get.arguments['chartController'],
        playerController: Get.arguments['playerController']
      ),
    ),
    GetPage(
      name: AppRoutes.PLAYER,
      page: () => const PlayerScreen(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.CATEGORY_DETAIL,
      page: () => CategoryDetailScreen(category: Get.arguments),
    ),
  ];
}
