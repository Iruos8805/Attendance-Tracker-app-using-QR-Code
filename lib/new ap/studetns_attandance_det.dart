import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StudentAttendance {
  final int hourId;
  final int courseId;
  final int classId;
  final String uid;
  String class_name;

  StudentAttendance({
    required this.hourId,
    required this.courseId,
    required this.classId,
    required this.uid,
    required this.class_name,
  });

  factory StudentAttendance.fromJson(Map<String, dynamic> data) {
    return StudentAttendance(
      hourId: data['hour_id'],
      courseId: data['course_id'],
      classId: data['class_id'],
      uid: data['uid'],
      class_name: '', // Initialize with an empty string
    );
  }
}

class StudentAttendancePage extends StatefulWidget {
  static String routeName = "/attendance-student";
  final String email;
  const StudentAttendancePage({required this.email});

  @override
  State<StudentAttendancePage> createState() => StudentAttendancePageState();
}

class StudentAttendancePageState extends State<StudentAttendancePage> {
  late Future<List<StudentAttendance>> _fetchAttendanceDetails;

  @override
  void initState() {
    super.initState();
    _fetchAttendanceDetails = fetchAttendanceDetails();
  }

  Future<List<StudentAttendance>> fetchAttendanceDetails() async {
    final response = await http.get(
      Uri.parse(
          'https://group4attendance.pythonanywhere.com/api/courses/1/classes/1/hours/1/attendance'),
    );
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);

      Set<StudentAttendance> uniqueAttendances = Set();

      for (var data in jsonResponse) {
        StudentAttendance attendance = StudentAttendance.fromJson(data);
        if (!uniqueAttendances.any((a) =>
            a.hourId == attendance.hourId &&
            a.courseId == attendance.courseId &&
            a.classId == attendance.classId &&
            a.uid == attendance.uid)) {
          uniqueAttendances.add(attendance);
        }
      }

      List<StudentAttendance> filteredList = uniqueAttendances.toList();

      // Fetch class names for each class ID
      for (var attendance in filteredList) {
        final classResponse = await http.get(
          Uri.parse(
              'https://group4attendance.pythonanywhere.com/api/courses/${attendance.courseId}/classes/${attendance.classId}'),
        );
        if (classResponse.statusCode == 200) {
          Map<String, dynamic> classData = json.decode(classResponse.body);
          // Update the class name for the attendance
          attendance.class_name = classData['class_name'];
        } else {
          throw Exception(
              'Failed to fetch class name for class ID ${attendance.classId}');
        }
      }

      return filteredList;
    } else {
      throw Exception('Unexpected error occurred!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Attendance'),
      ),
      body: Container(
        child: FutureBuilder<List<StudentAttendance>>(
          future: _fetchAttendanceDetails,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return buildAttendanceList(snapshot.data!);
            }
          },
        ),
      ),
    );
  }

  Widget buildAttendanceList(List<StudentAttendance> attendanceList) {
    return ListView.builder(
      itemCount: attendanceList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Attendance ${index + 1}'),
          subtitle: Text('Email: ${attendanceList[index].uid}\n'
              'Course ID: ${attendanceList[index].courseId}\n'
              'Class Name: ${attendanceList[index].class_name}\n'
              'Hour ID: ${attendanceList[index].hourId}'),
        );
      },
    );
  }
}
