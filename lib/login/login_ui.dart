import 'package:flutter/material.dart';
import 'package:sarpo_uz/login/service.dart';
import 'package:sarpo_uz/user/ui/user_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;

  void handleLogin() async {
    setState(() {
      isLoading = true;
    });

    final success = await loginUser(
      _loginController.text,
      _passwordController.text,
    );

    setState(() {
      isLoading = false;
    });

    if (success) {
      // Navigate to home page or show success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login muvaffaqiyatli")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserHomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login yoki parol noto'g'ri")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login Sahifasi")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _loginController,
              decoration: const InputDecoration(labelText: "Login"),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Parol"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: handleLogin,
                    child: const Text("Kirish"),
                  ),
          ],
        ),
      ),
    );
  }
}
