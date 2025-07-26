import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/merchant_payment_method_controller.dart';
import '../controllers/payment_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<CartController>(CartController(), permanent: true);
    Get.put<MerchantPaymentMethodController>(
      MerchantPaymentMethodController(),
      permanent: true,
    );
    Get.put<PaymentController>(PaymentController(), permanent: true);
  }
}
