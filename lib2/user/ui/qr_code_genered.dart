import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QRCodePageGenerd extends StatefulWidget {
  const QRCodePageGenerd({super.key});

  @override
  State<QRCodePageGenerd> createState() => _QRCodePageGenerdState();
}

class _QRCodePageGenerdState extends State<QRCodePageGenerd> {
  String? qrId;
  bool isLoading = false;
  String? error;

  Future<void> createQRId() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    // final prefs = await SharedPreferences.getInstance();
    final token =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NTQ2NTY4OTUsImlhdCI6MTc1NDQ4NDA5NSwiaWQiOiIxIiwicm9sZSI6InVzZXIifQ.JnrAFSCy7sVDyWcVXLrdVTVfTwdxiuUhVO_sicZeN70";

    if (token == null) {
      setState(() {
        error = 'Token topilmadi. Iltimos, qayta login qiling.';
        isLoading = false;
      });
      return;
    }

    final url = Uri.parse('https://crm.uzjoylar.uz/qr-id/create');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      setState(() {
        qrId = jsonResponse['qr_id'];
        isLoading = false;
      });
    } else {
      setState(() {
        error = 'QR ID yaratishda xatolik: ${response.statusCode}';
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    createQRId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code')),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator(
                color: Colors.black,
              )
            : error != null
                ? Text(error!, style: const TextStyle(color: Colors.red))
                : qrId != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          QrImageView(
                            data: qrId!,
                            version: QrVersions.auto,
                            size: 250.0,
                          ),
                          const SizedBox(height: 16),
                          Text('QR ID: $qrId'),
                        ],
                      )
                    : const Text('QR ID mavjud emas'),
      ),
    );
  }
}
