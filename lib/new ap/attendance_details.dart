import 'dart:convert';
import 'dart:io';
import 'package:attendence_tracker/new%20ap/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AttendanceDetail {
  final int courseId;
  final int classId;
  final int hourId;
  final String date;
  final String uid;
  final String name;

  AttendanceDetail({
    required this.courseId,
    required this.classId,
    required this.hourId,
    required this.date,
    required this.uid,
    required this.name,
  });

  factory AttendanceDetail.fromJson(Map<String, dynamic> json) {
    return AttendanceDetail(
      courseId: json['course_id'],
      classId: json['class_id'],
      hourId: json['hour_id'],
      date: json['date'],
      uid: json['uid'],
      name: json['name'],
    );
  }
}

class AttendanceList extends StatefulWidget {
  final int courseId;
  final int classId;
  final int hourId;

  AttendanceList({
    required this.courseId,
    required this.classId,
    required this.hourId,
  });

  @override
  _AttendanceListState createState() => _AttendanceListState();
}

class _AttendanceListState extends State<AttendanceList> {
  late Future<List<AttendanceDetail>> _fetchAttendanceDetails;

  @override
  void initState() {
    super.initState();
    _fetchAttendanceDetails = fetchAttendanceDetails();
  }

  Future<List<AttendanceDetail>> fetchAttendanceDetails() async {
    int courseId = widget.courseId;
    int classId = widget.classId;
    int hourId = widget.hourId;

    final response = await http.get(
      Uri.parse(
          'https://group4attendance.pythonanywhere.com/api/courses/$courseId/classes/$classId/hours/$hourId/attendance'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      List<AttendanceDetail> filteredDetails = data
          .map((item) => AttendanceDetail.fromJson(item))
          .where((detail) =>
              detail.courseId == courseId &&
              detail.classId == classId &&
              detail.hourId == hourId)
          .toList();

      Set<String> uniqueUids = Set<String>();
      List<AttendanceDetail> attendanceDetails = [];

      for (var detail in filteredDetails) {
        if (!uniqueUids.contains(detail.uid)) {
          uniqueUids.add(detail.uid);
          attendanceDetails.add(detail);
        }
      }

      return attendanceDetails;
    } else {
      throw Exception('Failed to load attendance details');
    }
  }

  Future<void> _downloadAttendancePDF(
      List<AttendanceDetail> attendanceDetails) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          return [
            pw.Header(
                level: 0,
                child: pw.Text('Attendance Details',
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold))),
            pw.SizedBox(height: 20),
            for (var detail in attendanceDetails)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                      'Date: ${detail.date}, Name: ${detail.name}, UID: ${detail.uid}'),
                  pw.SizedBox(height: 10),
                ],
              ),
          ];
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/attendance_details.pdf');
    await file.writeAsBytes(await pdf.save());

    if (Platform.isAndroid) {
      await Printing.sharePdf(
          bytes: await pdf.save(), filename: 'attendance_details.pdf');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Attendance PDF downloaded to ${file.path}')),
    );
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
            IconButton(
              onPressed: () async {
                final attendanceDetails = await _fetchAttendanceDetails;
                await _downloadAttendancePDF(attendanceDetails);
              },
              icon: Icon(
                Icons.download,
                size: 30,
                color: Colors.white,
              ),
            )
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: damber,
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
        child: FutureBuilder<List<AttendanceDetail>>(
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
                  AttendanceDetail attendanceDetail = snapshot.data![index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(
                        '${attendanceDetail.date}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      subtitle: Text(
                        'Name: ${attendanceDetail.name},\nUID: ${attendanceDetail.uid}',
                        style: TextStyle(color: Colors.black87),
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
