// pubspec.yaml ga qo'shish kerak:
// dependencies:
//   flutter:
//     sdk: flutter
//   http: ^1.1.0  # HTTP requests uchun

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BarcodeScannerPage extends StatefulWidget {
  @override
  _BarcodeScannerPageState createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final TextEditingController _barcodeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Map<String, dynamic>> scanHistory = [];
  String lastScannedCode = '';
  bool isLoading = false;

  // Backend API URL
  final String apiUrl = 'http://localhost:3030/attendance/create';

  @override
  void initState() {
    super.initState();
    // Sahifa ochildigida input ga fokus berish
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Barcode scan qilinganda ishlaydigan funksiya
  void _onBarcodeScanned(String barcode) {
    if (barcode.isEmpty) return;

    setState(() {
      lastScannedCode = barcode;
    });

    // Status ni so'rash
    _showStatusDialog(barcode);

    // Input ni tozalash va yana fokus berish
    _barcodeController.clear();
    _focusNode.requestFocus();
  }

  // User dan status so'rash dialog
  void _showStatusDialog(String qrId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Davomat belgilash',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.qr_code_scanner,
                size: 64,
                color: Colors.blue[700],
              ),
              SizedBox(height: 16),
              Text(
                'QR Code: $qrId',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Siz hozir nima qilmoqchisiz?',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _sendAttendanceRequest(qrId, 'entered');
                    },
                    icon: Icon(Icons.login, color: Colors.white),
                    label: Text('Ishga kirdim'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _sendAttendanceRequest(qrId, 'come_out');
                    },
                    icon: Icon(Icons.logout, color: Colors.white),
                    label: Text('Ishdan chiqdim'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _focusNode.requestFocus();
                },
                child: Text('Bekor qilish'),
              ),
            ),
          ],
        );
      },
    );
  }

  // Backend ga so'rov yuborish
  Future<void> _sendAttendanceRequest(String qrId, String status) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'qr_id': qrId,
          'status': status,
        }),
      );
      print(status);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Muvaffaqiyatli
        final responseData = json.decode(response.body);
        _showSuccessMessage(status, qrId);
        _addToHistory(qrId, status, 'success', null);
      } else {
        // Xatolik
        String errorMessage = 'Noma\'lum xatolik yuz berdi';

        try {
          final errorData = json.decode(response.body);
          if (errorData.containsKey('Error creating Attendance:')) {
            errorMessage = errorData['Error creating Attendance:'];
          } else if (errorData.containsKey('error')) {
            errorMessage = errorData['error'];
          } else if (errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          }
        } catch (e) {
          errorMessage = 'Server xatosi: ${response.statusCode}';
        }

        _showErrorMessage(errorMessage);
        _addToHistory(qrId, status, 'error', errorMessage);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      String errorMessage =
          'Server bilan bog\'lanishda xatolik: ${e.toString()}';
      _showErrorMessage(errorMessage);
      _addToHistory(qrId, status, 'error', errorMessage);
    }

    _focusNode.requestFocus();
  }

  // Muvaffaqiyat xabarini ko'rsatish
  void _showSuccessMessage(String status, String qrId) {
    String message = status == 'entered'
        ? 'Ishga kirish muvaffaqiyatli qayd etildi!'
        : 'Ishdan chiqish muvaffaqiyatli qayd etildi!';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Xatolik xabarini ko'rsatish
  void _showErrorMessage(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('Xatolik', style: TextStyle(color: Colors.red)),
            ],
          ),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Tarixga qo'shish
  void _addToHistory(String qrId, String status, String result, String? error) {
    setState(() {
      scanHistory.insert(0, {
        'qr_id': qrId,
        'status': status,
        'result': result,
        'error': error,
        'time': DateTime.now().toString().substring(11, 19),
        'date': DateTime.now().toString().substring(0, 10),
      });
    });
  }

  // Status uchun rang olish
  Color _getStatusColor(String status, String result) {
    if (result == 'error') return Colors.red;
    return status == 'entered' ? Colors.green : Colors.blue;
  }

  // Status uchun icon olish
  IconData _getStatusIcon(String status, String result) {
    if (result == 'error') return Icons.error;
    return status == 'entered' ? Icons.login : Icons.logout;
  }

  // Status uchun text olish
  String _getStatusText(String status) {
    return status == 'entered' ? 'Ishga kirdi' : 'Ishdan chiqdi';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Davomat tizimi'),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[700]!, Colors.blue[50]!],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Scanner Input Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.qr_code_scanner,
                                color: Colors.blue[700]),
                            SizedBox(width: 8),
                            Text(
                              'QR Code Scanner',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _barcodeController,
                          focusNode: _focusNode,
                          autofocus: true,
                          enabled: !isLoading,
                          decoration: InputDecoration(
                            hintText: 'QR kodni shu yerga scan qiling...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: Icon(Icons.qr_code_scanner),
                            suffixIcon: isLoading
                                ? Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                  )
                                : IconButton(
                                    icon: Icon(Icons.clear),
                                    onPressed: () {
                                      _barcodeController.clear();
                                      _focusNode.requestFocus();
                                    },
                                  ),
                          ),
                          onSubmitted: (value) {
                            if (value.isNotEmpty && !isLoading) {
                              _onBarcodeScanned(value);
                            }
                          },
                        ),
                        SizedBox(height: 12),
                        Text(
                          isLoading
                              ? 'Ma\'lumot yuborilmoqda...'
                              : 'QR kodni skanerini bu input ga yo\'naltiring',
                          style: TextStyle(
                            color: isLoading
                                ? Colors.orange[600]
                                : Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Last Scanned Code Display
                if (lastScannedCode.isNotEmpty)
                  Card(
                    elevation: 4,
                    color: Colors.green[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              SizedBox(width: 8),
                              Text(
                                'Oxirgi scan qilingan QR kod:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green[200]!),
                            ),
                            child: Text(
                              lastScannedCode,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                SizedBox(height: 16),

                // Scan History
                Expanded(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.history, color: Colors.blue[700]),
                              SizedBox(width: 8),
                              Text(
                                'Davomat tarixi',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                              Spacer(),
                              if (scanHistory.isNotEmpty)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      scanHistory.clear();
                                      lastScannedCode = '';
                                    });
                                  },
                                  child: Text('Tozalash'),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: scanHistory.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.history,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Hali hech qanday faoliyat yo\'q',
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: scanHistory.length,
                                  itemBuilder: (context, index) {
                                    final item = scanHistory[index];
                                    final color = _getStatusColor(
                                        item['status'], item['result']);
                                    final icon = _getStatusIcon(
                                        item['status'], item['result']);

                                    return Card(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 4),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor:
                                              color.withOpacity(0.2),
                                          child: Icon(icon, color: color),
                                        ),
                                        title: Text(
                                          item['result'] == 'error'
                                              ? 'Xatolik - ${_getStatusText(item['status'])}'
                                              : _getStatusText(item['status']),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: color,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'QR: ${item['qr_id']}',
                                              style: TextStyle(
                                                fontFamily: 'monospace',
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                                '${item['date']} ${item['time']}'),
                                            if (item['error'] != null)
                                              Text(
                                                'Xatolik: ${item['error']}',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 12,
                                                ),
                                              ),
                                          ],
                                        ),
                                        trailing: Icon(
                                          item['result'] == 'success'
                                              ? Icons.check_circle
                                              : Icons.error,
                                          color: color,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _focusNode.requestFocus();
        },
        child: Icon(Icons.center_focus_strong),
        tooltip: 'Input ga fokus berish',
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
    );
  }
}
