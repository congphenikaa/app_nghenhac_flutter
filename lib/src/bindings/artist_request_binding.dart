import 'package:app_nghenhac/src/view_models/artist_request_controller.dart';
import 'package:get/get.dart';

class ArtistRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ArtistRequestController());
  }
}
