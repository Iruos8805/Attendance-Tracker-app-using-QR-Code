import 'package:attendence_tracker/new%20ap/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanQRPage extends StatefulWidget {
  final int courseId;
  final int classId;
  final int hourId;

  const ScanQRPage({Key? key, required this.courseId, required this.classId, required this.hourId}) : super(key: key);

  @override
  _ScanQRPageState createState() => _ScanQRPageState();
}

class _ScanQRPageState extends State<ScanQRPage> {
  String? scannedResult;
  bool isCameraPaused = false;
  bool isFlashOn = false;
  bool isAlertShown = false;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> postScannedResult(String result) async {
    final courseId = widget.courseId;
    final classId = widget.classId;
    final hourId = widget.hourId;

    var response = await http.post(
      Uri.parse('https://group4attendance.pythonanywhere.com/api/courses/$courseId/classes/$classId/hours/$hourId/tr-scan'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'special_uid': result,
        'course_id': courseId,
        'class_id': classId,
        'hour_id': hourId,
      }),
    );

    print(result);
    print(courseId);
    print(classId);
    print(hourId);

    if (response.statusCode == 201 && !isAlertShown) {
      // Show a popup message if attendance is successfully marked
      showDialog(
        context: context,
        builder: (BuildContext context) {
          isAlertShown = true; // Set the flag to true to prevent showing again
          return AlertDialog(
            title: Text('Attendance Marked'),
            backgroundColor: Colors.white,
            content: Text('The attendance has been successfully marked.', style: TextStyle(fontFamily: GoogleFonts.bebasNeue().fontFamily),),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK', style: TextStyle(color: Colors.black54)),
              ),
            ],
          );
        },
      );
      print('Success');
    } else {
      print('Failed to post scanned result: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false, // Removes back button
      ),
      body: Column(
        children: [
          Expanded(
            child: QRView(
              key: qrKey,
              onQRViewCreated: (QRViewController controller) {
                this.controller = controller;
                controller.scannedDataStream.listen((scanData) {
                  setState(() {
                    scannedResult = scanData.code;
                  });
                  postScannedResult(scanData.code.toString());
                });
              },
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 10),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await controller.toggleFlash();
                  setState(() {
                    isFlashOn = !isFlashOn;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kdblue,
                  foregroundColor: Colors.white

                ),
                child: Icon(isFlashOn ? Icons.flash_off : Icons.flash_on),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: () async {
                  await controller.flipCamera();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kdblue,
                  foregroundColor: Colors.white
                ),
                child: Icon(Icons.switch_camera),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: () async {
                  if (isCameraPaused) {
                    await controller.resumeCamera();
                  } else {
                    await controller.pauseCamera();
                  }
                  setState(() {
                    isCameraPaused = !isCameraPaused;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kdblue,
                  foregroundColor: Colors.white
                ),
                child: Icon(isCameraPaused ? Icons.play_arrow : Icons.pause),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
