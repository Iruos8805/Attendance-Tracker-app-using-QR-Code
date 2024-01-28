import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GenerateQRPage extends StatelessWidget {
  final String random;

  GenerateQRPage({required this.random});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,

      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: random,
              size: 300,
              embeddedImageStyle: QrEmbeddedImageStyle(
                size: Size(80, 80),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
