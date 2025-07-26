import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screens/auth/login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/pembeli/pembeli_dashboard_screen.dart';
import 'screens/penjual/penjual_dashboard_screen.dart';
import 'screens/penjual/merchant_payment_list_screen.dart';
import 'screens/shared/chat_screen.dart';
import 'screens/pembeli/payment_proof_screen.dart';
import 'screens/shared/payment_proof_viewer_screen.dart';
import 'bindings/app_binding.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Kantin Jawara',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialBinding: AppBinding(),
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/admin', page: () => AdminDashboardScreen()),
        GetPage(name: '/pembeli', page: () => const PembeliDashboardScreen()),
        GetPage(name: '/penjual', page: () => const PenjualDashboardScreen()),
        GetPage(
          name: '/merchant-payment-methods',
          page: () => const MerchantPaymentListScreen(),
        ),
        GetPage(
          name: '/chat',
          page: () =>
              ChatScreen(transactionId: Get.arguments?['transactionId'] ?? 0),
        ),
        GetPage(
          name: '/payment-proof',
          page: () => PaymentProofScreen(
            transaction: Get.arguments?['transaction'],
            paymentMethod: Get.arguments?['paymentMethod'],
            merchantPaymentMethod: Get.arguments?['merchantPaymentMethod'],
          ),
        ),
        GetPage(
          name: '/payment-proof-viewer',
          page: () => PaymentProofViewerScreen(
            transaction: Get.arguments?['transaction'],
            userRole: Get.arguments?['userRole'] ?? 'buyer',
          ),
        ),
      ],
    );
  }
}
