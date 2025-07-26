// import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/enums.dart';
import '../../utils/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();

  UserRole _selectedRole = UserRole.pembeli;
  bool _agreed = false;
  bool _passwordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama wajib diisi';
    }
    if (value.length < 2) {
      return 'Nama minimal 2 karakter';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email wajib diisi';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Masukkan email yang valid';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi wajib diisi';
    }
    if (value.length < 6) {
      return 'Kata sandi minimal 6 karakter';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi kata sandi wajib diisi';
    }
    if (value != _passwordController.text) {
      return 'Kata sandi tidak cocok';
    }
    return null;
  }

  void _handleRegister() {
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus menyetujui ketentuan.')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      _authController.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole.value,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
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
                const Text(
                  'Solusi Untuk Kantin Untirta yang sangat ramai',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppTheme.mediumGray),
                ),
                const SizedBox(height: 24),

                _inputField("Nama", _nameController, _validateName),
                _inputField(
                  "Email",
                  _emailController,
                  _validateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
                _passwordField(),
                _inputField(
                  "Konfirmasi Password",
                  _confirmPasswordController,
                  _validateConfirmPassword,
                  obscure: true,
                ),

                Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.mediumGray.withOpacity(0.3),
                    ),
                  ),
                  child: DropdownButtonFormField<UserRole>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Daftar sebagai',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    items: [UserRole.penjual, UserRole.pembeli]
                        .map(
                          (role) => DropdownMenuItem(
                            value: role,
                            child: Text(_getRoleDisplayName(role)),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _selectedRole = val!),
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Checkbox(
                      value: _agreed,
                      activeColor: AppTheme.goldenPoppy,
                      checkColor: AppTheme.royalBlueDark,
                      onChanged: (val) =>
                          setState(() => _agreed = val ?? false),
                    ),
                    Flexible(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.mediumGray,
                          ),
                          children: [
                            const TextSpan(text: "Saya setuju dengan "),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: _showTermsAndConditions,
                                child: const Text(
                                  "Ketentuan Layanan & Kebijakan Privasi",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.usafaBlue,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _authController.isLoading
                          ? null
                          : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.goldenPoppy,
                        foregroundColor: AppTheme.royalBlueDark,
                        padding: const EdgeInsets.symmetric(vertical: 18),
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
                              'Register',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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

                TextButton(
                  onPressed: () {
                    _authController.clearErrorOnNavigation();
                    Get.back();
                  },
                  child: const Text(
                    'Sudah punya akun? Masuk',
                    style: TextStyle(
                      color: AppTheme.usafaBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Ketentuan Layanan & Kebijakan Privasi',
            style: TextStyle(
              color: AppTheme.royalBlueDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Ketentuan Layanan'),
                  _buildSectionContent(
                    '1. Dengan menggunakan aplikasi Kantin Jawara, Anda setuju untuk mematuhi semua ketentuan yang berlaku.\n\n'
                    '2. Anda bertanggung jawab atas keakuratan informasi yang Anda berikan saat registrasi.\n\n'
                    '3. Dilarang menggunakan aplikasi ini untuk kegiatan yang melanggar hukum atau merugikan pihak lain.\n\n'
                    '4. Kami berhak untuk menangguhkan atau menghapus akun yang melanggar ketentuan.',
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Kebijakan Privasi'),
                  _buildSectionContent(
                    '1. Kami menghargai privasi Anda dan berkomitmen untuk melindungi data personal Anda.\n\n'
                    '2. Data yang dikumpulkan meliputi nama, email, dan informasi profil lainnya.\n\n'
                    '3. Data Anda hanya akan digunakan untuk keperluan operasional aplikasi dan tidak akan dibagikan kepada pihak ketiga tanpa persetujuan Anda.\n\n'
                    '4. Anda memiliki hak untuk mengakses, mengubah, atau menghapus data personal Anda.',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Tutup',
                style: TextStyle(color: AppTheme.mediumGray),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _agreed = true);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.goldenPoppy,
                foregroundColor: AppTheme.royalBlueDark,
              ),
              child: const Text('Setuju'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.royalBlueDark,
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: const TextStyle(
        fontSize: 14,
        color: AppTheme.mediumGray,
        height: 1.4,
      ),
    );
  }

  Widget _inputField(
    String label,
    TextEditingController controller,
    FormFieldValidator<String>? validator, {
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.mediumGray.withOpacity(0.3)),
        ),
        child: TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscure,
          keyboardType: keyboardType,
          onChanged: (_) {
            if (_authController.errorMessage.isNotEmpty) {
              _authController.clearError();
            }
          },
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            labelStyle: const TextStyle(color: AppTheme.mediumGray),
          ),
        ),
      ),
    );
  }

  Widget _passwordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.mediumGray.withOpacity(0.3)),
        ),
        child: TextFormField(
          controller: _passwordController,
          obscureText: !_passwordVisible,
          validator: _validatePassword,
          decoration: InputDecoration(
            labelText: 'Password',
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            labelStyle: const TextStyle(color: AppTheme.mediumGray),
            suffixIcon: IconButton(
              icon: Icon(
                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                color: AppTheme.mediumGray,
              ),
              onPressed: () =>
                  setState(() => _passwordVisible = !_passwordVisible),
            ),
          ),
        ),
      ),
    );
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.penjual:
        return 'Penjual';
      case UserRole.pembeli:
        return 'Pembeli';
    }
  }
}
