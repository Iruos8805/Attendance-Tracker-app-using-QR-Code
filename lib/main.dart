import 'package:attendence_tracker/home_screen.dart';
import 'package:attendence_tracker/screens/login.dart';
import 'package:attendence_tracker/screens/sign_up.dart';
import 'package:attendence_tracker/screens/splash_screen.dart';
import 'package:attendence_tracker/views/QR_SCANNER_WITHBACK.dart';

import 'package:attendence_tracker/views/student_page.dart';
import 'package:attendence_tracker/views/teacher_page.dart';
import 'package:attendence_tracker/widgets/generate_qr_button.dart';
import 'package:attendence_tracker/widgets/qr_scanner.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // The useMaterial3 property is not available in ThemeData
        // If you're using the latest Flutter version, it's not necessary.
      ),
      home: SplashScreen(),
    );
  }
}
