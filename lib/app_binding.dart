import 'package:app_nghenhac/src/view_models/player_controller.dart';
import 'package:get/get.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // putPermanent: true để đảm bảo controller không bao giờ bị hủy
    Get.put(PlayerController(), permanent: true);
  }
}
