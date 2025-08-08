import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sarpo_uz/services_user/api_service.dart';

class QrCodePage extends StatelessWidget {
  final String userToken;

  const QrCodePage({Key? key, required this.userToken}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code')),
      body: Center(
        child: FutureBuilder<String?>(
          future: ApiService.getQrCode(userToken),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(
                color: Colors.black,
              );
            } else if (snapshot.hasError) {
              return Text('Xatolik: ${snapshot.error}');
            } else if (snapshot.hasData && snapshot.data != null) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  QrImageView(
                    data: snapshot.data!,
                    version: QrVersions.auto,
                    size: 200.0,
                    gapless: false,
                    errorStateBuilder: (cxt, err) {
                      return const Center(
                        child: Text(
                          'QR kod yuklanmadi.',
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              );
            } else {
              return const Text('QR kod mavjud emas.');
            }
          },
        ),
      ),
    );
  }
}
