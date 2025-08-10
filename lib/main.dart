import 'package:flutter/material.dart';
import 'package:sarpo_uz/postter/qr-code.dart';

import 'admin/screens/users_list_screen.dart';
import 'screens_user/user_home_page.dart';
import 'services_user/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/app_constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget initialRoute = const Scaffold(
      body: Center(
          child: CircularProgressIndicator(
    color: Colors.black,
  )));

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.userTokenKey);
    final role = prefs.getString(AppConstants.userRoleKey);

    if (token != null && role == 'user') {
      print('User is logged in with role: $role');
      setState(() {
        initialRoute = const UserHomePage();
      });
    } else if (token != null && role == 'admin') {
      print('User is logged in with role: $role');

      setState(() {
        initialRoute = UsersListScreen();
      });
    } else if (token != null && role == 'qr') {
      print('User is logged in with role: $role');

      setState(() {
        initialRoute = BarcodeScannerPage();
      });
    } else {
      print('User is logged in with role: $role');

      setState(() {
        initialRoute = const LoginPage();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Uzjoylar CRM',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: initialRoute, // UserHomePage(), // LoginPage(),
    );
  }
}
