import 'package:flutter/material.dart';
import 'package:sarpo_uz/screens_user/user_home_page.dart';
import 'package:sarpo_uz/services_user/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _loginController =
      TextEditingController(text: '770451118'); // Pre-fill for testing
  final TextEditingController _passwordController =
      TextEditingController(text: 'string'); // Pre-fill for testing
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final login = _loginController.text;
    final password = _passwordController.text;

    final response = await ApiService.login(login, password);

    setState(() {
      _isLoading = false;
    });

    if (response != null) {
      if (response.userInfo.role == 'user') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserHomePage()),
        );
      } else {
        setState(() {
          _errorMessage =
              'Sizda ushbu panelga kirish huquqi yo\'q.'; // You don't have access to this panel.
        });
      }
    } else {
      setState(() {
        _errorMessage =
            'Login yoki parol noto\'g\'ri.'; // Incorrect login or password.
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRM Login'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _loginController,
                decoration: const InputDecoration(
                  labelText: 'Login (Telefon raqam)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Parol',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24.0),
              _isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.black,
                    )
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(
                            double.infinity, 50), // full width button
                      ),
                      child: const Text('Kirish'),
                    ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
