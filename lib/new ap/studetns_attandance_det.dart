import 'dart:convert';
import 'package:attendence_tracker/new%20ap/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StudentAttendance {
  final int hourId;
  final int courseId;
  final int classId;
  final String uid;
  final String date;
  String class_name;
  String hour_name;

  StudentAttendance({
    required this.hourId,
    required this.courseId,
    required this.classId,
    required this.uid,
    required this.date,
    required this.class_name,
    required this.hour_name,
  });

  factory StudentAttendance.fromJson(Map<String, dynamic> data) {
    return StudentAttendance(
      hourId: data['hour_id'],
      courseId: data['course_id'],
      classId: data['class_id'],
      uid: data['uid'],
      date: data['date'],
      class_name: '', 
      hour_name:'',
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
        'https://group4attendance.pythonanywhere.com/api/courses/1/classes/1/hours/1/attendance',
      ),
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      Set<StudentAttendance> uniqueAttendances = Set();

      for (var data in jsonResponse) {
        StudentAttendance attendance = StudentAttendance.fromJson(data);
        if (attendance.uid == widget.email &&
            !uniqueAttendances.any((a) =>
                a.hourId == attendance.hourId &&
                a.courseId == attendance.courseId &&
                a.classId == attendance.classId &&
                a.uid == attendance.uid)) {
          uniqueAttendances.add(attendance);
        }
      }

      List<StudentAttendance> filteredList = uniqueAttendances.toList();

      for (var attendance in filteredList) {
        final classResponse = await http.get(
          Uri.parse(
            'https://group4attendance.pythonanywhere.com/api/courses/${attendance.courseId}/classes/${attendance.classId}',
          ),
        );
        if (classResponse.statusCode == 200) {
          Map<String, dynamic> classData = json.decode(classResponse.body);
          attendance.class_name = classData['class_name'];
        } else {
          throw Exception(
              'Failed to fetch class name for class ID ${attendance.classId}');
        }

        final hourResponse = await http.get(
          Uri.parse(
            'https://group4attendance.pythonanywhere.com/api/courses/${attendance.courseId}/classes/${attendance.classId}/hours/${attendance.hourId}',
          ),
        );
        if (hourResponse.statusCode == 200) {
          Map<String, dynamic> hourData = json.decode(hourResponse.body);
          attendance.hour_name = hourData['hour'];
        } else {
          throw Exception(
              'Failed to fetch hour name for hour ID ${attendance.hourId}');
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Attendance Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Spacer(),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white10, 
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              kdmeroon,
              kdblue,
            ],
          ),
        ),
        child: FutureBuilder<List<StudentAttendance>>(
          future: _fetchAttendanceDetails,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                  child: Text(
                'No attendance details found.',
                style: TextStyle(color: Colors.white),
              ));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  StudentAttendance attendanceDetail = snapshot.data![index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(
                        'Attendance ${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date: ${attendanceDetail.date}',
                            style: TextStyle(
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Class Name: ${attendanceDetail.class_name}\n'
                            'Hour Name: ${attendanceDetail.hour_name}',
                    
                            style: TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
