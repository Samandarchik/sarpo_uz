// lib/user/services_user/salary_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_constants.dart';

class SalaryService {
  // Maoshni yangilash
  static Future<bool> updateSalary({
    required int salaryId,
    int? advance,
    String? advanceDescription,
    int? fine,
    String? fineDescription,
    int? bonus,
    String? bonusDescription,
  }) async {
    try {
      // Token olish
      final prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('user_token');

      if (userToken == null) {
        print('User token not found');
        return false;
      }

      // Request body yaratish
      final Map<String, dynamic> requestBody = {};

      if (advance != null) requestBody['advance'] = advance;
      if (advanceDescription != null && advanceDescription.isNotEmpty) {
        requestBody['advance_description'] = advanceDescription;
      }
      if (fine != null) requestBody['fine'] = fine;
      if (fineDescription != null && fineDescription.isNotEmpty) {
        requestBody['fine_description'] = fineDescription;
      }
      if (bonus != null) requestBody['bonus'] = bonus;
      if (bonusDescription != null && bonusDescription.isNotEmpty) {
        requestBody['bonus_description'] = bonusDescription;
      }

      print('Updating salary with data: $requestBody');

      // API so'rovi
      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}/salary/update?id=$salaryId'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating salary: $e');
      return false;
    }
  }

  // Maosh ma'lumotlarini olish (qo'shimcha funksiya)
  static Future<Map<String, dynamic>?> getSalaryDetails(int salaryId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('user_token');

      if (userToken == null) {
        print('User token not found');
        return null;
      }

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/salary/details?id=$salaryId'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error fetching salary details: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching salary details: $e');
      return null;
    }
  }

  // Maosh hisobotini olish
  static Future<Map<String, dynamic>?> getSalaryReport(
    int userId,
    String fromDate,
    String toDate,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('user_token');

      if (userToken == null) {
        print('User token not found');
        return null;
      }

      final response = await http.get(
        Uri.parse(
            '${AppConstants.baseUrl}/salary/report?user_id=$userId&from_date=$fromDate&to_date=$toDate'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error fetching salary report: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching salary report: $e');
      return null;
    }
  }

  // Maoshni o'chirish (admin uchun)
  static Future<bool> deleteSalary(int salaryId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('user_token');

      if (userToken == null) {
        print('User token not found');
        return false;
      }

      final response = await http.delete(
        Uri.parse('${AppConstants.baseUrl}/salary/delete?id=$salaryId'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error deleting salary: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error deleting salary: $e');
      return false;
    }
  }
}
