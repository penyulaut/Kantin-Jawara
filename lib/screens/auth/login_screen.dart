import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/app_theme.dart';
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
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.mediumGray.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.mediumGray.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextButton.icon(
          onPressed: () {},
          icon: Icon(icon, color: AppTheme.royalBlueDark),
          label: Text(
            text,
            style: const TextStyle(color: AppTheme.royalBlueDark),
          ),
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
      backgroundColor: AppTheme.lightGray,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Image.asset(
                  '/image/logokantinjawara.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                  color: Colors.transparent,
                  colorBlendMode: BlendMode.multiply,
                ),
              ),

              const Text(
                'Selamat Datang di Kantin Jawara',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: AppTheme.royalBlueDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Silahkan Login dengan Akun Anda',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppTheme.mediumGray),
              ),
              const SizedBox(height: 24),

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

              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _authController.isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: AppTheme.goldenPoppy,
                      foregroundColor: AppTheme.royalBlueDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      shadowColor: AppTheme.goldenPoppy.withOpacity(0.4),
                    ),
                    child: _authController.isLoading
                        ? const CircularProgressIndicator(
                            color: AppTheme.royalBlueDark,
                          )
                        : const Text(
                            'Login',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  _authController.clearErrorOnNavigation();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Belum Memiliki Akun? Ayo Daftar',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.usafaBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Obx(
                () => _authController.errorMessage.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.red.withOpacity(0.1),
                          border: Border.all(
                            color: AppTheme.red.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _authController.errorMessage,
                          style: const TextStyle(color: AppTheme.red),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
