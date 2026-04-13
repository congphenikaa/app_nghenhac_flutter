import 'package:get/get.dart';
import '../view_models/home_controller.dart';
import '../view_models/chart_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => ChartController());
  }
}
