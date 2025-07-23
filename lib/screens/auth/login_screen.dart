import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();
  bool obscurePassword = true;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Widget socialButton(String text, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextButton.icon(
          onPressed: () {},
          icon: Icon(icon, color: icon == Icons.facebook ? Colors.blue : null),
          label: Text(text),
        ),
      ),
    );
  }

  Widget inputField({
    required String hint,
    required TextEditingController controller,
    IconData? icon,
    bool obscure = false,
    VoidCallback? toggleObscure,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        onChanged: (_) {
          if (_authController.errorMessage.isNotEmpty) {
            _authController.clearError();
          }
        },
        decoration: InputDecoration(
          hintText: hint,
          border: const OutlineInputBorder(),
          suffixIcon: toggleObscure != null
              ? IconButton(
                  icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: toggleObscure,
                )
              : Icon(icon),
        ),
      ),
    );
  }

  void _handleLogin() {
    if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password wajib diisi')),
      );
      return;
    }

    _authController.login(
      email: emailCtrl.text.trim(),
      password: passCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Selamat Datang',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 4),
              const Text(
                'Silahkan Login dengan Akun Anda',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // Social Login
              Row(
                children: [
                  socialButton('Google', Icons.g_mobiledata),
                  socialButton('Facebook', Icons.facebook),
                ],
              ),

              const SizedBox(height: 24),

              // Email & Password Fields
              inputField(hint: 'Email', controller: emailCtrl),
              inputField(
                hint: 'Password',
                controller: passCtrl,
                icon: Icons.visibility_off,
                obscure: obscurePassword,
                toggleObscure: () {
                  setState(() => obscurePassword = !obscurePassword);
                },
              ),

              const SizedBox(height: 20),

              // Login Button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _authController.isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 25),
                      backgroundColor: const Color(0xFFFFC107),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 6,
                      shadowColor: Colors.grey.shade300,
                    ),
                    child: _authController.isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Login',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  _authController.clearErrorOnNavigation();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                child: Text(
                  'Belum Memiliki Akun? Ayo Daftar',
                  style: TextStyle(fontSize: 14, color: Colors.blue),
                ),
              ),

              const SizedBox(height: 16),

              // Error message
              Obx(() => _authController.errorMessage.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _authController.errorMessage,
                        style: TextStyle(color: Colors.red[800]),
                      ),
                    )
                  : const SizedBox.shrink()),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
