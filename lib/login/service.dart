import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
      print('Token saqlandi: $token');
      return true;
    } else {
      print('Login xato: ${data['message']}');
      return false;
    }
  } else {
    print('Xatolik: ${response.statusCode}');
    return false;
  }
}
