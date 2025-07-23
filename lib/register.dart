import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController(); // ✅ Tambahan
  String selectedRole = 'Pilih Role';
  bool loading = false;
  bool agreed = false;
  bool passwordVisible = false;

  Future<void> register() async {
    if (!agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anda harus menyetujui ketentuan.')));
      return;
    }

    if (passCtrl.text != confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi password tidak cocok')),
      );
      return;
    }

    setState(() => loading = true);
    final resp = await http.post(
      Uri.parse('https://semenjana.biz.id/kaja/api/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': nameCtrl.text,
        'email': emailCtrl.text,
        'password': passCtrl.text,
        'password_confirmation': confirmPassCtrl.text, // ✅ Tambahan
        'role': selectedRole,
      }),
    );
    setState(() => loading = false);
    if (resp.statusCode == 201) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Registrasi berhasil')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal daftar: ${resp.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
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

                // Login Sosial
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    socialButton("Google", Icons.g_mobiledata),
                    socialButton("Facebook", Icons.facebook),
                  ],
                ),

                const SizedBox(height: 24),

                // Form Fields
                inputField("Nama", nameCtrl),
                inputField("Email", emailCtrl),
                passwordField(),
                inputField("Konfirmasi Password", confirmPassCtrl), // ✅ Tambahan

                // Dropdown Role
                DropdownButtonFormField<String>(
                  value: selectedRole == 'Pilih Role' ? null : selectedRole,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: ['Penjual', 'Pembeli']
                      .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(role),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        selectedRole = val;
                      });
                    }
                  },
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Checkbox(
                      value: agreed,
                      onChanged: (val) {
                        setState(() => agreed = val ?? false);
                      },
                    ),
                    const Flexible(
                        child: Text(
                            "Saya setuju dengan Ketentuan Layanan & Kebijakan Privasi",
                            style: TextStyle(fontSize: 12))),
                  ],
                ),

                const SizedBox(height: 12),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 25),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: loading
                        ? const CircularProgressIndicator()
                        : const Text('Register'),
                  ),
                ),

                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
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

  Widget inputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        obscureText: label.toLowerCase().contains("password"),
      ),
    );
  }

  Widget passwordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: passCtrl,
        obscureText: !passwordVisible,
        decoration: InputDecoration(
          labelText: 'Password',
          suffixIcon: IconButton(
            icon: Icon(
                passwordVisible ? Icons.visibility : Icons.visibility_off),
            onPressed: () =>
                setState(() => passwordVisible = !passwordVisible),
          ),
        ),
      ),
    );
  }

  Widget socialButton(String text, IconData icon) {
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
}
