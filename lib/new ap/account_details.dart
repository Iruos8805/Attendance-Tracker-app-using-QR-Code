import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:attendence_tracker/new%20ap/constants.dart';
import 'package:attendence_tracker/screens/database_sql.dart';

class AccountDetailsScreen extends StatefulWidget {
  @override
  _AccountDetailsScreenState createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  String _token = '';
  bool _isLoading = true;
  late SqliteService sqliteService;
  late Map<String, dynamic> _userData;

  @override
  void initState() {
    super.initState();
    sqliteService = SqliteService();
    AuthTokenGet();
  }

  Future<void> AuthTokenGet() async {
    try {
      final token = await sqliteService.getTokenForId(1);
      setState(() {
        _token = token!;
      });
      final response = await http.get(
        Uri.parse('https://group4attendance.pythonanywhere.com/api/student-only'),
        headers: {'Authorization': 'Token $_token'},
      );
      if (response.statusCode == 200) {
        _userData = jsonDecode(response.body);
      } else {
        final teacherResponse = await http.get(
          Uri.parse('https://group4attendance.pythonanywhere.com/api/teacher-only'),
          headers: {'Authorization': 'Token $_token'},
        );
        if (teacherResponse.statusCode == 200) {
          _userData = jsonDecode(teacherResponse.body);
        } else {
          throw Exception('Unable to authenticate as a student or teacher');
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
      // Handle error, maybe show a snackbar or display an error message
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: damber,
        title: Text(
          _userData['is_student']
              ? 'Student Account Details'
              : 'Teacher Account Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      )
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kdmeroon, kdblue],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoTile('Username', _userData['username']),
                _buildInfoTile('Full Name', _userData['name']),
                _buildInfoTile('Email', _userData['email']),
                _buildInfoTile('Date Joined', _userData['date_joined']),
                if (_userData['is_student'])
                  ...[
                    _buildInfoTile('Roll No', _userData['roll_no']),
                    _buildInfoTile('Course', _userData['course']),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, dynamic value) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 5),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AccountDetailsScreen(),
  ));
}
