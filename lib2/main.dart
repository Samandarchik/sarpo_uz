import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dio.dart';
import 'ui/login.dart';
import 'ui/qr-code.dart';
import 'user/ui/qr_code_genered.dart';
import 'user/ui/user_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        home: Scaffold(
            body: ListView.builder(
          itemBuilder: (context, index) {
            List<String> title = [
              'User Home Page',
              'Login Page',
              'QR Code Generated',
              'Barcode Scanner',
              "Ask Page"
            ];
            List<Widget> items = [
              const UserHomePage(),
              const LoginPage(),
              const QRCodePageGenerd(),
              BarcodeScannerPage(),
              AskPage()
            ];
            return ListTile(
              title: Text(title[index % title.length]),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => items[index % items.length],
                ),
              ),
            );
          },
          itemCount: 6,
        )));
  }
}
