import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart'; // jika mau pakai Google Fonts
import '../controllers/auth_controller.dart';
import '../utils/navigation_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    final AuthController authController = Get.find<AuthController>();
    final isLoggedIn = await authController.checkInitialAuthStatus();
    await Future.delayed(const Duration(seconds: 2));

    if (isLoggedIn && authController.currentUser != null) {
      NavigationHelper.navigateToDashboard();
    } else {
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF8E1), // Kuning muda di atas
              Color(0xFFFFD54F), // Kuning medium
              Color(0xFFFFA000), // Kuning tua di bawah
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Kantin',
                style: GoogleFonts.dancingScript(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Jawara',
                style: GoogleFonts.dancingScript(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 50),

              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
