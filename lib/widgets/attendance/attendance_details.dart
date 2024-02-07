import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;



class Attendance {
  final int id;
  final String className;
  final String specialId;
  final String date;
  final String time;
  final String uid;
  final int teacherQrpost;

  Attendance({
    required this.id,
    required this.className,
    required this.specialId,
    required this.date,
    required this.time,
    required this.uid,
    required this.teacherQrpost,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      className: json['classname']['id'],
      specialId: json['special_id'],
      date: json['date'],
      time: json['time'],
      uid: json['uid'],
      teacherQrpost: json['teacher_qrpost'],
    );
  }
}


class AttendanceList extends StatefulWidget {
  @override
  _AttendanceListState createState() => _AttendanceListState();
}

class _AttendanceListState extends State<AttendanceList> {
  List<Attendance> attendanceList = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get('https://sabarixr.pythonanywhere.com/api/attendance/$className/$special_id/' as Uri);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<Attendance> tempList = data.map((item) => Attendance.fromJson(item)).toList();

      setState(() {
        attendanceList = tempList.where((attendance) => attendance.teacherQrpost == 6).toList();
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Details'),
      ),
      body: ListView.builder(
        itemCount: attendanceList.length,
        itemBuilder: (context, index) {
          Attendance attendance = attendanceList[index];
          return ListTile(
            title: Text('${attendance.className} - ${attendance.date} ${attendance.time}'),
            subtitle: Text('Roll No: ${attendance.uid}'),
          );
        },
      ),
    );
  }
}