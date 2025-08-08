import 'package:flutter/material.dart';
import 'package:sarpo_uz/screens/users_list_screen.dart';
import 'package:sarpo_uz/screens_user/user_home_page.dart';
import 'package:sarpo_uz/services_user/login_page.dart';
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
  Widget _initialRoute = const Scaffold(
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
      setState(() {
        _initialRoute = const UserHomePage();
      });
    } else if (token != null && role == 'admin') {
      setState(() {
        _initialRoute = UsersListScreen();
      });
    } else {
      setState(() {
        _initialRoute = const LoginPage();
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
      home: UsersListScreen(),
    );
  }
}
