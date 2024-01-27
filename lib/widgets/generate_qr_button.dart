import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:random_string/random_string.dart';
import 'package:http/http.dart' as http;

class GenerateQRPage extends StatefulWidget {
  late final int classId;

  @override
  _GenerateQRPageState createState() => _GenerateQRPageState();
}

class _GenerateQRPageState extends State<GenerateQRPage> {
  String random = '';
  String lat = '9.090025';
  String long = '76.486411';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('Generate QR', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  random = randomString(10);
                });
                postDataToDjango(random);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.purple, // Set the button background color to purple
              ),
              child: Text('GENERATE QR', style: TextStyle(color: Colors.white)), // Set button text color to white
            ),

            if (random != '')
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

  Future<void> postDataToDjango(String random) async {
    var uri = Uri.parse('https://sabarixr.pythonanywhere.com/api/teacher-qrpost/');

    try {
      var response = await http.post(
        uri,
        body: jsonEncode({
          "classname_id": 4,
          "special_id": random,
          'longitude': long,
          'latitude': lat,
          'time': DateTime.now().toUtc().toIso8601String(),
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print(response.statusCode);
      if (response.statusCode == 201) {
        print('Qr appended');
      } else {
        print('Failed ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Generate QR App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GenerateQRPage(),
    );
  }
}
