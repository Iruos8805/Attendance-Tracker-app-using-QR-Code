import 'package:attendence_tracker/constants.dart';
import 'package:attendence_tracker/home_screen.dart';
import 'package:attendence_tracker/screens/database_sql.dart';
import 'package:attendence_tracker/screens/sign_up.dart';
import 'package:attendence_tracker/views/student_page.dart';
import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as Path;

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late SqliteService sqliteService;
  Map routes = {


  };
  @override
  void initState() {
    super.initState();
    sqliteService = SqliteService();
    initializeDatabase();
  }

  Future<void> initializeDatabase() async {
    await sqliteService.initializeDB();
  }






  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              kpurple,
              kviolet,
            ],
          )),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _page(),
      ),
    );
  }

  Widget _page() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _icon(),
            const SizedBox(height: 50),
            _inputField("Username", usernameController),
            const SizedBox(height: 20),
            _inputField("Password", passwordController, isPassword: true),
            const SizedBox(height: 50),
            _loginBtn(),
            const SizedBox(height: 20),
            _extraText(),
          ],
        ),
      ),
    );
  }

  Widget _icon() {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          shape: BoxShape.circle),
      child: const Icon(Icons.person, color: Colors.white, size: 120),
    );
  }

  Widget _inputField(String hintText, TextEditingController controller,
      {isPassword = false}) {
    var border = OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.white));

    return TextField(
      style: const TextStyle(color: Colors.white),
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white),
        enabledBorder: border,
        focusedBorder: border,
      ),
      obscureText: isPassword,
    );
  }

  Widget _loginBtn() {
    return ElevatedButton(
      onPressed: () {
        Map<String, dynamic> userData = {
          "username": usernameController.text,
          "password": passwordController.text,
        };
        String jsonUserData = jsonEncode(userData);

        http
            .post(
          Uri.parse('https://sabarixr.pythonanywhere.com/api/login/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonUserData,
        )
            .then((http.Response response) {
          if (response.statusCode == 200) {
            debugPrint("Login success");
            debugPrint("Response: ${response.body}");


            Map<String, dynamic> jsonResponse =
            jsonDecode(response.body) as Map<String, dynamic>;
            sqliteService.insertOrUpdateRecord(1, jsonResponse["token"]);
            String token = jsonResponse["token"];
            bool isStudent = jsonResponse["is_student"];

            if (isStudent) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => StudentPage()));
            } else {
              Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
            }


          } else {
            debugPrint("User Data: $jsonUserData");
            debugPrint("Status code: ${response.statusCode}");
            debugPrint("Login failed");

          }


        });

      },
      child:  SizedBox(
          width: double.infinity,
          child: Text(
            "Login",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, color: kpurple1),
          )),
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
        primary: Colors.white,
        onPrimary: Colors.blue,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
  Widget _extraText() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignUpScreen()),
        );
      },
      child: Text(
        'Sign Up',
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }




}