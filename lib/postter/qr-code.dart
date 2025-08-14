import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:sarpo_uz/user/services_user/api_service.dart';
import 'package:sarpo_uz/user/services_user/login_page.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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
  bool showImages = true;
  bool isScanning = false; // Kamera holati

  // Mobile Scanner
  MobileScannerController cameraController = MobileScannerController();

  // WebSocket ulanishi
  WebSocketChannel? _channel;
  bool isConnected = false;
  String connectionStatus = 'Ulanish...';

  // Backend API URL
  final String apiUrl = 'https://crm.uzjoylar.uz/attendance/create';
  final String baseImageUrl = 'https://crm.uzjoylar.uz/';
  final String wsUrl = 'ws://31.187.74.228:7070/ws';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _connectWebSocket();
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _focusNode.dispose();
    _channel?.sink.close();
    cameraController.dispose();
    super.dispose();
  }

  // QR kamera ni ishga tushirish
  void _startQRScanner() {
    setState(() {
      isScanning = true;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'QR Kod Skaneri',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () {
                      _stopQRScanner();
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
            ),
            // QR Scanner
            Expanded(
              child: Container(
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[700]!, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: MobileScanner(
                    controller: cameraController,
                    onDetect: (capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      for (final barcode in barcodes) {
                        if (barcode.rawValue != null &&
                            barcode.rawValue!.isNotEmpty) {
                          // QR kod topildi
                          Navigator.pop(context); // Bottom sheet ni yopish
                          _stopQRScanner();

                          // Scan qilingan kod bilan ishlash
                          _onBarcodeScanned(barcode.rawValue!);
                          break;
                        }
                      }
                    },
                  ),
                ),
              ),
            ),
            // Footer
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 32,
                    color: Colors.red[700],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'QR kodni kamera ko\'rinishiga joylashtiring',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // QR scanner ni to'xtatish
  void _stopQRScanner() {
    setState(() {
      isScanning = false;
    });
    cameraController.stop();
  }

  // WebSocket ulanishini o'rnatish
  void _connectWebSocket() {
    try {
      _channel = IOWebSocketChannel.connect(wsUrl);

      setState(() {
        isConnected = true;
        connectionStatus = 'Ulandi';
      });

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
          Future.delayed(Duration(seconds: 5), () {
            if (mounted) _connectWebSocket();
          });
        },
        onDone: () {
          setState(() {
            isConnected = false;
            connectionStatus = 'Ulanish uzildi';
          });
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
      Future.delayed(Duration(seconds: 5), () {
        if (mounted) _connectWebSocket();
      });
    }
  }

  // WebSocket xabarini qayta ishlash
  void _handleWebSocketMessage(Map<String, dynamic> data) {
    setState(() {
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

    _showStatusDialog(barcode);

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
        final responseData = json.decode(response.body);

        Map<String, dynamic>? userData;
        if (responseData.containsKey('card')) {
          userData = responseData['card'];
        }

        _showUserCardDialog(status, userData);
      } else {
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
                CachedNetworkImage(
                  imageUrl: '$baseImageUrl$userImage',
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                SizedBox(height: 20),
                Icon(
                  status == 'entered' ? Icons.login : Icons.logout,
                  size: 40,
                  color: Colors.white,
                ),
                SizedBox(height: 10),
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
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await ApiService.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
        title: Row(
          children: [
            Text('Davomat tizimi'),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isConnected ? Colors.black : Colors.red,
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
        decoration: BoxDecoration(color: Colors.red[700]),
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
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.red[700]!, width: 3),
                            ),
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
                              : 'QR kodni skanerini bu input ga yo\'naltiring yoki kamera tugmasini bosing',
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
          } else {
            // Kamera QR skanerni ochish
            _startQRScanner();
          }
        },
        tooltip:
            isConnected ? 'QR kodni kamera bilan skanlash' : 'Qayta ulanish',
        backgroundColor: isConnected ? Colors.red[700] : Colors.orange[700],
        foregroundColor: Colors.white,
        child: Icon(isConnected ? Icons.qr_code_scanner : Icons.refresh),
      ),
    );
  }
}
