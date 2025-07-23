import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/merchant_payment_method_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize AuthController as permanent dependency
    Get.put<AuthController>(AuthController(), permanent: true);
    // Initialize CartController as permanent dependency
    Get.put<CartController>(CartController(), permanent: true);
    // Initialize MerchantPaymentMethodController as permanent dependency
    Get.put<MerchantPaymentMethodController>(
      MerchantPaymentMethodController(),
      permanent: true,
    );
  }
}
