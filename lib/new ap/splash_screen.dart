import 'package:attendence_tracker/new%20ap/constants.dart';
import 'package:attendence_tracker/new%20ap/course_screen.dart';
import 'package:attendence_tracker/new%20ap/database_sql.dart';
import 'package:attendence_tracker/new%20ap/login%20.dart';
import 'package:attendence_tracker/new%20ap/student_page%20.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
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
  late SqliteService sqliteService;
  @override
  void initState() {
    super.initState();
    sqliteService = SqliteService();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    checkTokenAndNavigate();
  }

  Future<void> checkTokenAndNavigate() async {
    try {
      await AuthTokenGet();
    } catch (e) {
      print('Error while fetching token: $e');
      navigateToLoginPage();
    }
  }

  Future<void> AuthTokenGet() async {
    final token = await sqliteService.getTokenForId(1);
    final response = await http.get(
      Uri.parse('https://group4attendance.pythonanywhere.com/api/student-only'),
      headers: {'Authorization': 'Token $token'},
    );
    print(response.body);
    print("'Authorization': 'Token $token'");
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var uid = data['uid'];
      print('PROCEED WITH STUDENT');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => StudentPage(
                uid: uid,
              )));
    } else {
      final teacherResponse = await http.get(
        Uri.parse(
            'https://group4attendance.pythonanywhere.com/api/teacher-only'),
        headers: {'Authorization': 'Token $token'},
      );
      print("'Authorization': 'Token $token'");
      if (teacherResponse.statusCode == 200) {
        print('PROCEED WITH TEACHER');
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    CourseScreen()));
      } else {

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
        width: double.infinity,
        color: kdmeroon,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Image
            Image.asset(
              "assets/images/attendance2.png",
              width: 120,
              height: 120,
            ),
            SizedBox(height: 16),


            Text(
              'Roll Call',
              style: TextStyle(
                fontFamily: GoogleFonts.pacifico().fontFamily,
                color: Colors.white,
                fontSize: 35,
              ),
            ),

            SizedBox(
                height:
                8),
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