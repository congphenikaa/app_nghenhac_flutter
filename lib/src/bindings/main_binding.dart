import 'package:get/get.dart';
import '../view_models/player_controller.dart';
import '../view_models/auth_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
    Get.put(PlayerController(), permanent: true);
  }
}
