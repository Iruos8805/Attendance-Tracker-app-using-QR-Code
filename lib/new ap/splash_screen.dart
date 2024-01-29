import 'package:attendence_tracker/new%20ap/constants.dart';
import 'package:attendence_tracker/new%20ap/login%20.dart';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    Future.delayed(
      Duration(
        seconds: 4,
      ),
          () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => LoginPage()),
        );
      },
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: kdmeroon,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Image
            Image.asset(
              "assets/images/attendance2.png",
              width: 120, // Adjust the width as needed
              height: 120, // Adjust the height as needed
            ),
            SizedBox(height: 16), // Adjust the spacing between logo and text

            // Text below the logo
            Text(
              'Roll Call',
              style: TextStyle(
                fontFamily: GoogleFonts.pacifico().fontFamily,
                color: Colors.white,
                fontSize: 35,
              ),
            ),

            // Additional text below "Roll Call"
            SizedBox(height: 8), // Adjust the spacing between "Roll Call" and additional text
            Text(
              'Scan.Track.Attend',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontFamily: GoogleFonts.sacramento().fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
