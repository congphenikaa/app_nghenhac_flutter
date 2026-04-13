import 'package:get/get.dart';
import '../view_models/library_controller.dart';

class LibraryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LibraryController());
  }
}
