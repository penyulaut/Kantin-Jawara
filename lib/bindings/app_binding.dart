import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize AuthController as permanent dependency
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}
