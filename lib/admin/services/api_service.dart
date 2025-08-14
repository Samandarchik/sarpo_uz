import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/attendance.dart';
import '../models/user.dart';
import '../models/salary.dart';

class ApiService {
  static const String baseUrl = 'https://crm.uzjoylar.uz';

  // Universal image upload method (mobile + web)
  static Future<String?> uploadImageUniversal(XFile imageFile) async {
    try {
      print('Starting universal image upload...');
      print('File name: ${imageFile.name}');
      print('File path: ${imageFile.path}');

      // Fayl hajmini tekshirish
      int fileSize = await imageFile.length();
      print('Original size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');

      if (fileSize == 0) {
        print('File is empty');
        return null;
      }

      // Faylni bytes sifatida o'qish (mobile + web uchun universal)
      Uint8List imageBytes = await imageFile.readAsBytes();

      // Agar fayl 1MB dan katta bo'lsa, siqish
      Uint8List finalBytes = imageBytes;
      if (fileSize > 1024 * 1024) {
        try {
          img.Image? originalImage = img.decodeImage(imageBytes);

          if (originalImage != null) {
            int quality = 90;

            Uint8List compressedBytes = Uint8List.fromList(
              img.encodeJpg(originalImage, quality: quality),
            );

            // 1 MB dan kichik bo'lmaguncha sifatni pasaytirish
            while (compressedBytes.length > 1024 * 1024 && quality > 10) {
              quality -= 10;
              compressedBytes = Uint8List.fromList(
                img.encodeJpg(originalImage, quality: quality),
              );
              print(
                  'Compressing with quality: $quality, size: ${(compressedBytes.length / 1024 / 1024).toStringAsFixed(2)} MB');
            }

            finalBytes = compressedBytes;
            print(
                'Final compressed size: ${(finalBytes.length / 1024 / 1024).toStringAsFixed(2)} MB');
          }
        } catch (compressionError) {
          print('Compression failed: $compressionError');
          // Agar siqish muvaffaqiyatsiz bo'lsa, asl bytesdan foydalanish
          finalBytes = imageBytes;
        }
      }

      // HTTP multipart request yaratish
      var uri = Uri.parse('$baseUrl/img-upload');
      print('Upload URL: $uri');

      var request = http.MultipartRequest('POST', uri);

      // Web va mobile uchun universal MultipartFile yaratish
      String fileName = imageFile.name.isNotEmpty
          ? imageFile.name
          : 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';

      var multipartFile = http.MultipartFile.fromBytes(
        'file',
        finalBytes,
        filename: fileName,
      );

      request.files.add(multipartFile);

      // Headers qo'shish
      request.headers.addAll({
        'accept': 'application/json',
      });

      // Web uchun qo'shimcha headerlar
      if (kIsWeb) {
        request.headers.addAll({
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type',
        });
      }

      print('Sending request...');
      print('File size to upload: ${finalBytes.length} bytes');
      print('Platform: ${kIsWeb ? "Web" : "Mobile"}');

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: $responseBody');

      if (response.statusCode == 200) {
        try {
          var jsonResponse = json.decode(responseBody);
          String? url = jsonResponse['url'];
          print('Upload successful! URL: $url');
          return url;
        } catch (jsonError) {
          print('JSON parsing error: $jsonError');
          return null;
        }
      } else {
        print('Image upload failed with status: ${response.statusCode}');
        print('Error response: $responseBody');
        return null;
      }
    } catch (e, stackTrace) {
      print('Error uploading image: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  // Eski File-based method (faqat mobile uchun)
  static Future<String?> uploadImage(File imageFile) async {
    if (kIsWeb) {
      print(
          'Warning: uploadImage(File) method is not supported on web. Use uploadImageUniversal(XFile) instead.');
      return null;
    }

    try {
      // XFile ga o'tkazib, universal methoddan foydalanish
      XFile xFile = XFile(imageFile.path);
      return await uploadImageUniversal(xFile);
    } catch (e) {
      print('Error in uploadImage: $e');
      return null;
    }
  }

  // Image picker va upload birlashtirilgan method
  static Future<String?> pickAndUploadImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image == null) {
        print('No image selected');
        return null;
      }

      print('Image selected: ${image.name}');
      return await uploadImageUniversal(image);
    } catch (e) {
      print('Error picking and uploading image: $e');
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
    int id,
    String fromDate,
    String toDate,
  ) async {
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
