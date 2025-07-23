import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'register.dart';
// import 'products_list.dart';
import 'maps.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;
  bool obscurePassword = true;

  Future<void> login() async {
    setState(() => loading = true);
    final resp = await http.post(
      Uri.parse('https://semenjana.biz.id/kaja/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': emailCtrl.text, 'password': passCtrl.text}),
    );
    setState(() => loading = false);
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      final token = data['token'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      Navigator.pushReplacement(
        context,
        // MaterialPageRoute(builder: (_) => const ProductsListScreen()),
        MaterialPageRoute(builder: (_) => const MapsPage()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: ${resp.body}')));
    }
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
        decoration: InputDecoration(
          hintText: hint,
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : login,
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
                  child: loading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Login',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),

              const SizedBox(height: 12),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Lupa Password',
                  style: TextStyle(color: Colors.blue),
                ),
              ),

              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  // TODO: Arahkan ke halaman register
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                child: Text(
                  'Belum Memiliki Akun? Ayo Daftar',
                  style: TextStyle(fontSize: 14, color: Colors.blue),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
