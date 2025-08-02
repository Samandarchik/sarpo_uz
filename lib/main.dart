import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sarpo_uz/admin/create_user.dart';
import 'package:sarpo_uz/core/di/di.dart';
import 'package:sarpo_uz/ui/login.dart';
import 'package:sarpo_uz/ui/qr-code.dart';
import 'package:sarpo_uz/user/ui/user_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupInit();
  runApp(ScreenUtilInit(
    designSize: Size(375, 812),
    minTextAdapt: true,
    builder: (context, child) {
      return const MyApp();
    },
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: UserHomePage(),
    );
  }
}
