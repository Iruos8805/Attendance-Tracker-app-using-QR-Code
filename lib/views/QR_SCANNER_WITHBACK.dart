import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../screens/database_sql.dart';

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  SqliteService sqliteService = SqliteService();
  String? storedToken;
  String? user_namepos;
  String c_ode = '';
  @override
  void initState() {
    super.initState();
    initDatabase();
    getTokenById(1);

    // Call authTokenUserInfo with the storedToken
    if (storedToken != null) {
      callAuthTokenUserInfo(storedToken!);
    }
  }

  Future<void> initDatabase() async {
    await sqliteService.initializeDB();
  }

  Future<void> getTokenById(int id) async {
    String? token = await sqliteService.getTokenForId(id);
    if (token != null) {
      print('Token for ID $id: $token');
      setState(() {
        storedToken = token;
      });
    } else {
      print('Token not found for ID $id');
    }
  }

  Future<void> callAuthTokenUserInfo(String token) async {
    Map<String, dynamic>? userInfo = await authTokenUserInfo(token);
    if (userInfo != null) {
      String? uid = extractUidFromApiResponse(userInfo);
      if (uid != null) {
        print('UID extracted from API response: $uid');
        setState(() {
          user_namepos = uid; // Set the username to user_namepos
        });
      } else {
        print('UID not found in API response');
      }
    } else {
      print('authTokenUserInfo call failed');
    }
  }

  Future<void> postDataToDjango(String random, String username) async {
    var uri = Uri.parse('https://sabarixr.pythonanywhere.com/api/teacher-qrpost/4/');

    try {
      var response = await http.post(
        uri,
        body: jsonEncode({
          "special_id": random,
          "longitude": "12.123123",
          "latitude": "123.123120",
          "time": DateTime.now().toUtc().toIso8601String(),
          "uid": user_namepos,
          "teacher_qrpost": 1,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // Check the response
      if (response.statusCode == 201) {
        print('Data posted successfully');
        // You can perform additional actions if needed
      } else {
        print('Failed to post data. Status code: ${response.statusCode}');
        // Handle the error accordingly
      }
    } catch (e) {
      print('Error: $e');
      // Handle the error accordingly
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    controller?.resumeCamera();
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Column(
          children: <Widget>[
            Expanded(flex: 4, child: _buildQrView(context)),
            Expanded(flex: 1, child: _buildBottomButtons(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;

    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedBox(height: 10),
          if (result != null)
            Text(
              'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}',
              style: TextStyle(
                color: Colors.white,
              ),
            )
          else
            const Text(
              'Scan the code',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildActionButton(
                onPressed: () async {
                  await controller?.toggleFlash();
                  setState(() {});
                },
                label: 'Flash',
              ),
              _buildActionButton(
                onPressed: () async {
                  await controller?.flipCamera();
                  setState(() {});
                },
                label: 'Flip Camera',
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildActionButton(
                onPressed: () async {
                  await controller?.pauseCamera();
                },
                label: 'Pause',
              ),
              SizedBox(width: 5),
              _buildActionButton(
                onPressed: () async {
                  await controller?.resumeCamera();
                },
                label: 'Resume',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required VoidCallback onPressed, required String label}) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3.0),
          ),
          primary: Colors.grey,
          onPrimary: Colors.black,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });

      if (result != null) {
        print("Result");
        print(result!.code);
        setState(() {
          c_ode = result as String;
        });

        postDataToDjango(c_ode, user_namepos!);

      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

String? extractUidFromApiResponse(Map<String, dynamic>? responseData) {
  if (responseData != null && responseData.containsKey("user")) {
    return responseData["user"].toString();
  }
  return null;
}

Future<Map<String, dynamic>?> authTokenUserInfo(String token) async {
  String apiUrl = 'https://sabarixr.pythonanywhere.com/api/student-only/';

  try {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      print('Response data: $data');
      return data;
    } else {
      print('Request failed with status: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error: $e');
    return null;
  }
}
