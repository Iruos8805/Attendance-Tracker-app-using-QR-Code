import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRViewPage extends StatelessWidget {
  final String qrData;

  QRViewPage(this.qrData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Viewer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: qrData,
              size: 300,
              embeddedImageStyle: QrEmbeddedImageStyle(
                size: Size(80, 80),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Perform any action when the button is pressed
              },
              child: Text('Custom Action'),
            ),
          ],
        ),
      ),
    );
  }
}
