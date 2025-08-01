import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sarpo_uz/user/ui/user_home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

// TOKEN SAQLASH VA LOGIN
Future<bool> loginUser(String login, String password) async {
  final url = Uri.parse('http://192.168.100.119:3030/users/login');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'login': login, 'password': password}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['message'] == 'success') {
      final token = data['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      return true;
    }
  }
  return false;
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController numberController;
  late TextEditingController passwordController;
  bool isPasswordVisible = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    numberController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    numberController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void handleLogin() async {
    setState(() {
      isLoading = true;
    });

    final success = await loginUser(
      numberController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() {
      isLoading = false;
    });

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tizimga muvaffaqiyatli kirildi')),
      );
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const UserHomePage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login yoki parol noto‘g‘ri')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo yoki ilova nomi
              const Icon(Icons.lock_outline, size: 80, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'Sarpo Uz Tizimiga Kirish',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              // Telefon raqami
              TextField(
                controller: numberController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Telefon raqami',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Parol
              TextField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Parol',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () =>
                        setState(() => isPasswordVisible = !isPasswordVisible),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Login tugmasi
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          'Kirish',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
