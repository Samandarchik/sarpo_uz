// pubspec.yaml ga qo'shish kerak:
// dependencies:
//   flutter:
//     sdk: flutter
//   http: ^1.1.0  # HTTP requests uchun
//   web_socket_channel: ^2.4.0  # WebSocket uchun

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';

class BarcodeScannerPage extends StatefulWidget {
  @override
  _BarcodeScannerPageState createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final TextEditingController _barcodeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Map<String, dynamic>> scanHistory =
      []; // Faqat WebSocket orqali to'ldiriladi
  String lastScannedCode = '';
  bool isLoading = false;
  bool showImages = true; // Rasmlarni ko'rsatish/yashirish uchun

  // WebSocket ulanishi
  WebSocketChannel? _channel;
  bool isConnected = false;
  String connectionStatus = 'Ulanish...';

  // Backend API URL
  final String apiUrl = 'https://crm.uzjoylar.uz/attendance/create';
  final String baseImageUrl = 'https://crm.uzjoylar.uz/';
  final String wsUrl = 'ws://localhost:7070/ws';

  @override
  void initState() {
    super.initState();
    // Sahifa ochildigida input ga fokus berish
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    // WebSocket ulanishini boshlash
    _connectWebSocket();
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _focusNode.dispose();
    _channel?.sink.close();
    super.dispose();
  }

  // WebSocket ulanishini o'rnatish
  void _connectWebSocket() {
    try {
      _channel = IOWebSocketChannel.connect(wsUrl);

      setState(() {
        isConnected = true;
        connectionStatus = 'Ulandi';
      });

      // WebSocket xabarlarini tinglash
      _channel!.stream.listen(
        (data) {
          try {
            final jsonData = json.decode(data);
            _handleWebSocketMessage(jsonData);
          } catch (e) {
            print('WebSocket xabar parsing xatosi: $e');
          }
        },
        onError: (error) {
          setState(() {
            isConnected = false;
            connectionStatus = 'Ulanish xatosi';
          });
          print('WebSocket xatosi: $error');
          // Qayta ulanishga harakat
          Future.delayed(Duration(seconds: 5), () {
            if (mounted) _connectWebSocket();
          });
        },
        onDone: () {
          setState(() {
            isConnected = false;
            connectionStatus = 'Ulanish uzildi';
          });
          // Qayta ulanishga harakat
          Future.delayed(Duration(seconds: 3), () {
            if (mounted) _connectWebSocket();
          });
        },
      );
    } catch (e) {
      setState(() {
        isConnected = false;
        connectionStatus = 'Ulanish mumkin emas';
      });
      print('WebSocket ulanish xatosi: $e');
      // Qayta ulanishga harakat
      Future.delayed(Duration(seconds: 5), () {
        if (mounted) _connectWebSocket();
      });
    }
  }

  // WebSocket xabarini qayta ishlash
  void _handleWebSocketMessage(Map<String, dynamic> data) {
    setState(() {
      // Yangi ma'lumotni tarix boshiga qo'shish
      scanHistory.insert(0, {
        'qr_id': data['qr_id'] ?? '',
        'status': data['status'] ?? 'entered',
        'result': 'success',
        'error': null,
        'userData': {
          'full_name': data['full_name'] ?? 'Noma\'lum foydalanuvchi',
          'img_url': data['img_url'] ?? '',
        },
        'time': data['timestamp'] != null
            ? DateTime.parse(data['timestamp']).toString().substring(11, 19)
            : DateTime.now().toString().substring(11, 19),
        'date': data['timestamp'] != null
            ? DateTime.parse(data['timestamp']).toString().substring(0, 10)
            : DateTime.now().toString().substring(0, 10),
      });
    });

    // Real-time xabar ko'rsatish
    _showRealTimeNotification(data);
  }

  // Real-time bildirishnoma
  void _showRealTimeNotification(Map<String, dynamic> data) {
    String status = data['status'] ?? 'entered';
    String userName = data['full_name'] ?? 'Noma\'lum foydalanuvchi';
    String message = status == 'entered'
        ? '$userName ishga kirdi'
        : '$userName ishdan chiqdi';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              status == 'entered' ? Icons.login : Icons.logout,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: status == 'entered' ? Colors.green : Colors.red,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
              color: Colors.red[700],
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        _sendAttendanceRequest(qrId, 'entered');
                      },
                      child: Text(
                        textAlign: TextAlign.center,
                        'Ishga kirdim',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        _sendAttendanceRequest(qrId, 'come_out');
                      },
                      child: Text(
                        textAlign: TextAlign.center,
                        'Ishdan chiqdim',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    textAlign: TextAlign.center,
                    'Bekor qilish',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Muvaffaqiyatli
        final responseData = json.decode(response.body);

        // Response dan user ma'lumotlarini olish
        Map<String, dynamic>? userData;
        if (responseData.containsKey('card')) {
          userData = responseData['card'];
        }

        // User card dialogini ko'rsatish
        _showUserCardDialog(status, userData);

        // WebSocket orqali real-time ma'lumotlar keladi,
        // shuning uchun qo'lda tarixga qo'shmaslik kerak
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
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      String errorMessage =
          'Server bilan bog\'lanishda xatolik: ${e.toString()}';
      _showErrorMessage(errorMessage);
    }

    _focusNode.requestFocus();
  }

  // User card dialogini ko'rsatish
  void _showUserCardDialog(String status, Map<String, dynamic>? userData) {
    String message = status == 'entered'
        ? 'Ishga kirish muvaffaqiyatli!'
        : 'Ishdan chiqish muvaffaqiyatli!';

    String userName = userData != null && userData['full_name'] != null
        ? userData['full_name']
        : 'Noma\'lum foydalanuvchi';

    String userImage = userData != null && userData['img_url'] != null
        ? userData['img_url']
        : '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // 2 soniyadan keyin avtomatik yopish
        Future.delayed(Duration(seconds: 2), () {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
        });

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: status == 'entered'
                    ? [Colors.green.shade400, Colors.green.shade600]
                    : [Colors.red.shade400, Colors.red.shade600],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // User rasmi
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    image: userImage.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage('$baseImageUrl$userImage'),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: userImage.isEmpty ? Colors.grey[300] : null,
                  ),
                  child: userImage.isEmpty
                      ? Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey[600],
                        )
                      : null,
                ),

                SizedBox(height: 20),

                // Status icon
                Icon(
                  status == 'entered' ? Icons.login : Icons.logout,
                  size: 40,
                  color: Colors.white,
                ),

                SizedBox(height: 10),

                // User ismi
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 10),

                // Status xabari
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 15),

                // Vaqt
                Text(
                  DateTime.now().toString().substring(11, 19),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

  // Tarix faqat WebSocket orqali to'ldiriladi, qo'lda qo'shish yo'q

  // Status uchun rang olish
  Color _getStatusColor(String status, String result) {
    if (result == 'error') return Colors.red;
    return status == 'entered' ? Colors.green : Colors.red;
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
        title: Row(
          children: [
            Text('Davomat tizimi'),
            Spacer(),
            // WebSocket ulanish holati
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isConnected ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isConnected ? Icons.wifi : Icons.wifi_off,
                    size: 16,
                    color: Colors.white,
                  ),
                  SizedBox(width: 4),
                  Text(
                    connectionStatus,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[700],
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red[700]!, Colors.red[50]!],
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
                            Icon(Icons.qr_code_scanner, color: Colors.red[700]),
                            SizedBox(width: 8),
                            Text(
                              'QR Code Scanner',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
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
                              Icon(Icons.history, color: Colors.red[700]),
                              SizedBox(width: 8),
                              Text(
                                'Real-time davomat tarixi',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[700],
                                ),
                              ),
                              Spacer(),
                              // Rasmlarni ko'rsatish/yashirish tugmasi
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    showImages = !showImages;
                                  });
                                },
                                icon: Icon(
                                  showImages
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.red[700],
                                ),
                                tooltip: showImages
                                    ? 'Rasmlarni yashirish'
                                    : 'Rasmlarni ko\'rsatish',
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                            child: scanHistory.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.wifi_tethering,
                                          size: 64,
                                          color: isConnected
                                              ? Colors.green[400]
                                              : Colors.grey[400],
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          isConnected
                                              ? 'Real-time ma\'lumotlar kutilmoqda...'
                                              : 'Server bilan aloqa yo\'q',
                                          style: TextStyle(
                                              color: isConnected
                                                  ? Colors.grey[600]
                                                  : Colors.red[600]),
                                        ),
                                      ],
                                    ),
                                  )
                                : GridView.builder(
                                    padding: EdgeInsets.all(8),
                                    gridDelegate:
                                        SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 300,
                                      mainAxisSpacing: 20,
                                      crossAxisSpacing: 16,
                                      childAspectRatio: 0.8,
                                    ),
                                    shrinkWrap: true,
                                    physics: BouncingScrollPhysics(),
                                    primary: false,
                                    itemCount: scanHistory.length,
                                    itemBuilder: (context, index) {
                                      final item = scanHistory[index];

                                      final userData = item['userData']
                                          as Map<String, dynamic>?;
                                      final isSuccess =
                                          item['result'] == 'success';

                                      // Status bo'yicha rang aniqlash
                                      Color statusColor;
                                      Color borderColor;
                                      Color bgColor;

                                      if (item['status'] == 'entered') {
                                        statusColor = Colors.green.shade700;
                                        borderColor = Colors.green.shade400;
                                        bgColor = Colors.green.shade50;
                                      } else if (item['status'] == 'come_out') {
                                        statusColor = Colors.red.shade700;
                                        borderColor = Colors.red.shade400;
                                        bgColor = Colors.red.shade50;
                                      } else {
                                        statusColor = Colors.red.shade700;
                                        borderColor = Colors.red.shade400;
                                        bgColor = Colors.red.shade50;
                                      }

                                      return Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: borderColor,
                                              width: 1,
                                            ),
                                            color: statusColor,
                                          ),
                                          child: Column(children: [
                                            // Rasm qismi - yuqori yarmi
                                            Expanded(
                                              child: Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  image: showImages && isSuccess
                                                      ? DecorationImage(
                                                          image: NetworkImage(
                                                              '$baseImageUrl${userData!['img_url']}'),
                                                          fit: BoxFit.cover,
                                                        )
                                                      : null,
                                                  color: bgColor,
                                                ),
                                              ),
                                            ),

                                            Text(
                                              userData?["full_name"] ?? "",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            ),
                                            Text(
                                              '${item['time']}',
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ]));
                                    },
                                  ))
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
          if (!isConnected) {
            _connectWebSocket();
          }
          _focusNode.requestFocus();
        },
        child: Icon(isConnected ? Icons.center_focus_strong : Icons.refresh),
        tooltip: isConnected ? 'Input ga fokus berish' : 'Qayta ulanish',
        backgroundColor: isConnected ? Colors.red[700] : Colors.orange[700],
        foregroundColor: Colors.white,
      ),
    );
  }
}
