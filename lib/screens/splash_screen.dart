import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

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
    // AuthController sudah di-initialize via AppBinding
    final AuthController authController = Get.find<AuthController>();

    // Wait for auth status check to complete
    final isLoggedIn = await authController.checkInitialAuthStatus();

    // Add small delay for splash effect
    await Future.delayed(const Duration(seconds: 2));

    // Navigate based on auth status
    if (isLoggedIn && authController.currentUser != null) {
      // User sudah login, langsung ke home
      print('User already logged in: ${authController.currentUser?.name}');
      Get.offAllNamed('/home');
    } else {
      // User belum login, ke login screen
      print('User not logged in, redirecting to login');
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo or App Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.restaurant, size: 60, color: Colors.blue),
            ),
            const SizedBox(height: 30),

            // App Name
            const Text(
              'Kantin Jawara',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),

            // Tagline
            const Text(
              'Makanan Enak, Mudah Dipesan',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 50),

            // Loading Indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 20),

            // Loading Text
            const Text(
              'Checking authentication...',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
