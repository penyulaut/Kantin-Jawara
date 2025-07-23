import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screens/auth/login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/pembeli/pembeli_dashboard_screen.dart';
import 'screens/penjual/penjual_dashboard_screen.dart';
import 'screens/penjual/merchant_payment_list_screen.dart';
import 'bindings/app_binding.dart';
// import 'middleware/auth_middleware.dart'; // Temporarily disabled

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
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialBinding: AppBinding(),
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(
          name: '/login',
          page: () => const LoginScreen(),
          // middlewares: [GuestMiddleware()], // Temporarily disabled
        ),
        GetPage(
          name: '/admin',
          page: () => AdminDashboardScreen(),
          // middlewares: [AdminMiddleware()], // Temporarily disabled
        ),
        GetPage(
          name: '/pembeli',
          page: () => const PembeliDashboardScreen(),
          // middlewares: [PembeliMiddleware()], // Temporarily disabled
        ),
        GetPage(
          name: '/penjual',
          page: () => const PenjualDashboardScreen(),
          // middlewares: [PenjualMiddleware()], // Temporarily disabled
        ),
        GetPage(
          name: '/merchant-payment-methods',
          page: () => const MerchantPaymentListScreen(),
        ),
      ],
    );
  }
}
