import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserService {
  static final ImagePicker _picker = ImagePicker();

  /// Rasm tanlash uchun optimizatsiya qilingan usul
  static Future<File?> pickImage(BuildContext context) async {
    try {
      // Avval modal bottom sheet yopilishini kutish
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Rasm tanlash',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    context: context,
                    icon: Icons.camera_alt,
                    label: 'Kamera',
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
                  _buildImageSourceOption(
                    context: context,
                    icon: Icons.photo_library,
                    label: 'Galereya',
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Bekor qilish tugmasi
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Bekor qilish',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      );

      // Agar source tanlangan bo'lsa
      if (source != null) {
        // Kichik kechikish qo'shish (UI stabillik uchun)
        await Future.delayed(const Duration(milliseconds: 300));
        return await _pickImageFromSource(source);
      }
      
      return null;
    } catch (e) {
      print('Rasm tanlashda xatolik: $e');
      return null;
    }
  }

  /// Rasm tanlash tugmasi widget
  static Widget _buildImageSourceOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                size: 30,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tanlangan manbadan rasm olish (optimizatsiya bilan)
  static Future<File?> _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,    // Sifatni biroz oshirish
        maxWidth: 1920,      // Maksimal kenglik
        maxHeight: 1920,     // Maksimal balandlik
        requestFullMetadata: false, // Metadata o'qimaydi (tezroq)
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Rasm tanlashda xatolik: $e');
      return null;
    }
  }

  /// Foydalanuvchini saqlash (yangi yoki mavjudni yangilash)
  static Future<bool> saveUser({
    required User user,
    required File? selectedImage,
    String? existingImageUrl,
    int? existingUserId,
  }) async {
    try {
      String? imageUrl = existingImageUrl;

      // Agar yangi rasm tanlangan bo'lsa, uni yuklash
      if (selectedImage != null) {
        imageUrl = await ApiService.uploadImage(selectedImage);
        if (imageUrl == null) {
          return false;
        }
      }

      // Foydalanuvchi ma'lumotlarini yangilash
      final updatedUser = User(
        fullName: user.fullName,
        imgUrl: imageUrl ?? '',
        phoneNumber: user.phoneNumber,
        password: user.password,
        salary: user.salary,
      );

      // Yangi foydalanuvchi yaratish yoki mavjudni yangilash
      if (existingUserId == null) {
        return await ApiService.createUser(updatedUser);
      } else {
        return await ApiService.updateUser(existingUserId, updatedUser);
      }
    } catch (e) {
      print('Foydalanuvchini saqlashda xatolik: $e');
      return false;
    }
  }

  /// Foydalanuvchini o'chirish tasdiqlash dialog
  static Future<bool> showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Ogohlantirish'),
          ],
        ),
        content: const Text(
          'Siz bu foydalanuvchini o\'chirmoqchimisiz?\nBu amal qaytarib bo\'lmaydi.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Bekor qilish',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Foydalanuvchini o'chirish
  static Future<bool> deleteUser(int userId) async {
    try {
      return await ApiService.deleteUser(userId);
    } catch (e) {
      print('Foydalanuvchini o\'chirishda xatolik: $e');
      return false;
    }
  }

  /// SnackBar ko'rsatish uchun yordamchi funksiya
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// Form validatsiya qoidalari
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'To\'liq ismni kiriting';
    }
    if (value.length < 2) {
      return 'Ism kamida 2 ta belgidan iborat bo\'lishi kerak';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefon raqamni kiriting';
    }
    if (value.length < 9) {
      return 'Telefon raqam to\'g\'ri formatda emas';
    }
    return null;
  }

  static String? validatePassword(String? value, {bool isRequired = true}) {
    if (isRequired && (value == null || value.isEmpty)) {
      return 'Parolni kiriting';
    }
    if (value != null && value.isNotEmpty && value.length < 6) {
      return 'Parol kamida 6 ta belgidan iborat bo\'lishi kerak';
    }
    return null;
  }

  static String? validateSalary(String? value) {
    if (value != null && value.isNotEmpty) {
      final salary = int.tryParse(value);
      if (salary == null || salary < 0) {
        return 'Maosh to\'g\'ri formatda emas';
      }
    }
    return null;
  }
}