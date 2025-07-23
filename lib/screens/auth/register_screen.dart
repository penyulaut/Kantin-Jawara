// import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/enums.dart';

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
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
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
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Kantin Jawara',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text(
                  'Solusi Untuk Kantin Untirta yang sangat ramai',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _socialButton("Google", Icons.g_mobiledata),
                    _socialButton("Facebook", Icons.facebook),
                  ],
                ),

                const SizedBox(height: 24),

                _inputField("Nama", _nameController, _validateName),
                _inputField("Email", _emailController, _validateEmail, keyboardType: TextInputType.emailAddress),
                _passwordField(),
                _inputField("Konfirmasi Password", _confirmPasswordController, _validateConfirmPassword, obscure: true),

                DropdownButtonFormField<UserRole>(
                  value: _selectedRole,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: [UserRole.penjual, UserRole.pembeli]
                      .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(_getRoleDisplayName(role)),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedRole = val!),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Checkbox(
                      value: _agreed,
                      onChanged: (val) => setState(() => _agreed = val ?? false),
                    ),
                    const Flexible(
                      child: Text(
                        "Saya setuju dengan Ketentuan Layanan & Kebijakan Privasi",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _authController.isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _authController.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Register'),
                  ),
                )),

                const SizedBox(height: 12),
                Obx(() => _authController.errorMessage.isNotEmpty
                    ? Text(_authController.errorMessage,
                        style: const TextStyle(color: Colors.red))
                    : const SizedBox.shrink()),

                TextButton(
                  onPressed: () {
                    _authController.clearErrorOnNavigation();
                    Get.back();
                  },
                  child: const Text(
                    'Sudah punya akun? Masuk',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller, FormFieldValidator<String>? validator,
      {bool obscure = false, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _passwordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: _passwordController,
        obscureText: !_passwordVisible,
        validator: _validatePassword,
        decoration: InputDecoration(
          labelText: 'Password',
          suffixIcon: IconButton(
            icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
          ),
        ),
      ),
    );
  }

  Widget _socialButton(String text, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: ElevatedButton.icon(
          icon: Icon(icon, color: Colors.black),
          label: Text(text, style: const TextStyle(color: Colors.black)),
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            elevation: 2,
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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