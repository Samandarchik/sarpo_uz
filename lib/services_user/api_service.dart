import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model_user/salary.dart';
import '../model_user/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../admin/models/attendance.dart';
import '../utils/app_constants.dart';

class ApiService {
  static Future<LoginResponse?> login(String login, String password) async {
    final url =
        Uri.parse('${AppConstants.baseUrl}${AppConstants.loginEndpoint}');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json'
        },
        body: json.encode({'login': login, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final loginResponse = LoginResponse.fromJson(data);
        await _saveTokenAndUserInfo(loginResponse);
        return loginResponse;
      } else {
        print('Login failed: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }

  static Future<void> _saveTokenAndUserInfo(LoginResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userTokenKey, response.token);
    await prefs.setInt(AppConstants.userIdKey, response.userInfo.id);
    await prefs.setString(
        AppConstants.userFullNameKey, response.userInfo.fullName);
    await prefs.setString(AppConstants.userImgUrlKey, response.userInfo.imgUrl);
    await prefs.setString(AppConstants.userRoleKey, response.userInfo.role);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.userTokenKey);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(AppConstants.userIdKey);
  }

  static Future<String?> getUserFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.userFullNameKey);
  }

  static Future<String?> getUserImgUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.userImgUrlKey);
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.userRoleKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userTokenKey);
    await prefs.remove(AppConstants.userIdKey);
    await prefs.remove(AppConstants.userFullNameKey);
    await prefs.remove(AppConstants.userImgUrlKey);
    await prefs.remove(AppConstants.userRoleKey);
  }

  static Future<String?> getQrCode(String token) async {
    final url =
        Uri.parse('${AppConstants.baseUrl}${AppConstants.qrCodeEndpoint}');
    try {
      final response = await http.post(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        // Backend javobida 'qr_id' bo‘lishi kerak
        return jsonResponse['qr_id']?.toString();
      } else {
        print(
            'QR Code request failed: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching QR Code: $e');
      return null;
    }
  }

  static Future<AttendanceResponse?> getAttendance(
      int userId, String fromDate, String toDate, String token) async {
    final url = Uri.parse(
        '${AppConstants.baseUrl}${AppConstants.attendanceEndpoint}?id=$userId&fromDate=$fromDate&toDate=$toDate');
    try {
      final response = await http.get(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response
            .bodyBytes)); // Decode with utf8 for proper character handling
        return AttendanceResponse.fromJson(data);
      } else {
        print(
            'Attendance request failed: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching attendance: $e');
      return null;
    }
  }

  static Future<SalaryResponse?> getSalary(
      int userId, String fromDate, String toDate, String token) async {
    final url = Uri.parse(
        '${AppConstants.baseUrl}${AppConstants.salaryEndpoint}?id=$userId&fromDate=$fromDate&toDate=$toDate');
    try {
      final response = await http.get(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return SalaryResponse.fromJson(data);
      } else {
        print('Salary request failed: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching salary: $e');
      return null;
    }
  }
}
