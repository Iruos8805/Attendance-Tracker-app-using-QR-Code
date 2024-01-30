import 'package:attendence_tracker/new%20ap/constants.dart';
import 'package:attendence_tracker/new%20ap/course_screen.dart';
import 'package:attendence_tracker/new%20ap/login%20.dart';
import 'package:attendence_tracker/new%20ap/student_page%20.dart';
import 'package:attendence_tracker/screens/database_sql.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late SqliteService sqliteService;

  @override
  void initState() {
    super.initState();
    sqliteService = SqliteService();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    checkTokenAndNavigate();
  }

  Future<void> checkTokenAndNavigate() async {
    if (sqliteService.getTokenForId(1) != null) {
      try {
        await AuthTokenGet();
        // Navigate to the appropriate page based on the response
      } catch (e) {
        print('Error while fetching token: $e');
        // Navigate to LoginPage regardless of the error
        navigateToLoginPage();
      }
    } else {
      // No token found, navigate to LoginPage
      navigateToLoginPage();
    }
  }

  Future<void> AuthTokenGet() async {
    final response = await http.get(
      Uri.parse('https://group4attendance.pythonanywhere.com/api/student-only'),
      headers: <String, String>{
        'Authorization': 'Token ${sqliteService.getTokenForId(1)}',
      },
    );
    print("tttttttttttttt");
    String? result = await sqliteService.getTokenForId(1);
    print(result);
    print(response.body);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var uid = data['uid'];
      print('PROCEED WITH STUDENT');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StudentPage(
            uid: uid,
          ),
        ),
      );
    } else {
      String result = sqliteService.getTokenForId(1) as String;
      // If student-only API fails, try teacher-only API
      final teacherResponse = await http.get(
        Uri.parse('https://group4attendance.pythonanywhere.com/api/teacher-only'),
        headers: <String, String>{
          'Authorization': 'Token $result',
        },
      );
      if (teacherResponse.statusCode == 200) {
        print('PROCEED WITH TEACHER');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseScreen(),
          ),
        );
      } else {
        // Handle any other cases or errors here
        throw Exception('Unable to authenticate as student or teacher');
      }
    }
  }

  void navigateToLoginPage() {
    Future.delayed(
      const Duration(seconds: 2),
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              kdmeroon,
              kdblue,
            ],
          ),
        ),
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
            SizedBox(
              height: 8,
            ), // Adjust the spacing between "Roll Call" and additional text
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
