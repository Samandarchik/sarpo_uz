import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../admin/models/attendance.dart';
import '../admin/models/user.dart';
import '../admin/models/salary.dart';

class ApiService {
  static const String baseUrl = 'https://crm.uzjoylar.uz';

  static Future<String?> uploadImage(File imageFile) async {
    try {
      // Fayl hajmini tekshirish
      int fileSize = await imageFile.length();
      print('Original size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');

      File fileToUpload = imageFile;

      if (fileSize > 1024 * 1024) {
        // 1MB dan katta bo‘lsa
        // Rasmni o‘qish
        Uint8List imageBytes = await imageFile.readAsBytes();
        img.Image? originalImage = img.decodeImage(imageBytes);

        if (originalImage != null) {
          int quality = 90; // Boshlang‘ich sifat

          Uint8List compressedBytes = Uint8List.fromList(
            img.encodeJpg(originalImage, quality: quality),
          );

          // 1 MB dan kichik bo‘lmaguncha sifatni pasaytirish
          while (compressedBytes.length > 1024 * 1024 && quality > 10) {
            quality -= 10;
            compressedBytes = Uint8List.fromList(
              img.encodeJpg(originalImage, quality: quality),
            );
          }

          // Yangi faylga yozish
          fileToUpload = File('${imageFile.path}_compressed.jpg');
          await fileToUpload.writeAsBytes(compressedBytes);

          print(
              'Compressed size: ${(compressedBytes.length / 1024 / 1024).toStringAsFixed(2)} MB');
        }
      }

      var request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/img-upload'));
      var multipartFile =
          await http.MultipartFile.fromPath('file', fileToUpload.path);
      request.files.add(multipartFile);
      request.headers['accept'] = 'application/json';

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(responseBody);
        return jsonResponse['url'];
      } else {
        print('Image upload failed: ${response.statusCode}');
        print('Response body: $responseBody');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Create user
  static Future<bool> createUser(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/create'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(user.toJson()),
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('Error creating user: $e');
      return false;
    }
  }

  // Update user
  static Future<bool> updateUser(int id, User user) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/update?id=$id'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(user.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  // Get users list
  static Future<List<User>> getUsersList() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/list'),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        List<dynamic> usersJson = jsonResponse['users'];
        return usersJson.map((json) => User.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  // Delete user
  static Future<bool> deleteUser(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/delete?id=$id'),
        headers: {'accept': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  // Update salary
  static Future<bool> updateSalary(int id, Salary salary) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/salary/update?id=$id'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(salary.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating salary: $e');
      return false;
    }
  }

  // Get attendance
  static Future<AttendanceResponse?> getAttendance(
      int id, String fromDate, String toDate, ) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/attendance/get?id=$id&fromDate=$fromDate&toDate=$toDate'),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        return AttendanceResponse.fromJson(jsonResponse);
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting attendance: $e');
      return null;
    }
  }
}
