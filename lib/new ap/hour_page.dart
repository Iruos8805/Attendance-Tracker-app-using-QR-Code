import 'package:attendence_tracker/new%20ap/constants.dart';
import 'package:attendence_tracker/new%20ap/QR_SCANNER_WITHBACK.dart';
import 'package:attendence_tracker/new%20ap/attendance_details.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class HourPage extends StatefulWidget {
  final int courseId;
  final int classId;

  const HourPage({Key? key, required this.courseId, required this.classId}) : super(key: key);

  @override
  _HourPageState createState() => _HourPageState();
}

class _HourPageState extends State<HourPage> {
  late Future<List<dynamic>> _fetchHours;
  late TextEditingController _hourController;

  @override
  void initState() {
    super.initState();
    _fetchHours = fetchHours(widget.courseId, widget.classId);
    _hourController = TextEditingController();
  }

  Future<List<dynamic>> fetchHours(int courseId, int classId) async {
    final response = await http.get(
      Uri.parse('https://group4attendance.pythonanywhere.com/api/courses/$courseId/classes/$classId/hours/'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load hours');
    }
  }

  Future<void> createHour(String hour) async {
    final courseId = widget.courseId;
    final classId = widget.classId;

    String formattedDateTime = DateFormat('yyyy-MM-ddTHH:mm:ss.SSSSSSZ').format(DateTime.now());

    var response = await http.post(
      Uri.parse('https://group4attendance.pythonanywhere.com/api/courses/$courseId/classes/$classId/hours/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'course_id': courseId,
        'class_id': classId,
        'hour': hour,
        'time': formattedDateTime,
      }),
    );

    if (response.statusCode == 201) {
      setState(() {
        _fetchHours = fetchHours(widget.courseId, widget.classId);
      });
    } else {
      print('Failed to create hour: ${response.statusCode}');
    }
  }

  @override
  void dispose() {
    _hourController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Center(
          child: Text(
            'Hours',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: damber,
      ),
      body: Stack(
        children: [
          Container(
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
          ),
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: Image.asset(
                'assets/images/clock.png',
                height: 100,
                width: 100,
              ),
            ),
          ),
          Positioned(
            top: 110,
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(top: 100),
                    child: FutureBuilder<List<dynamic>>(
                      future: _fetchHours,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white),));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(child: Text('No hours found.', style: TextStyle(color: Colors.white),));
                        } else {
                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.all(15),
                                child: Center(
                                  child: Container(
                                    width: 290,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFF3F7FAB),
                                        ),
                                        child: ListTile(
                                          title: Center(
                                            child: Text(
                                              snapshot.data![index]['hour'],
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                            ),
                                          ),
                                          onTap: () {

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => AttendanceList( courseId: widget.courseId,
                                                  classId: widget.classId,
                                                  hourId: snapshot.data![index]['id'],
                                                ),
                                              ),
                                            );
                                          },
                                          trailing: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => ScanQRPage(
                                                    courseId: widget.courseId,
                                                    classId: widget.classId,
                                                    hourId: snapshot.data![index]['id'],
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: damber,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'Scan QR',
                                                style: TextStyle(color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        width: 100.0,
        height: 70.0,
        child: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Add Hour'),
                  backgroundColor: Colors.white,
                  content: TextField(
                    controller: _hourController,
                    decoration: InputDecoration(labelText: 'Hour Name'),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel',
                      style: TextStyle(color: Colors.black54),),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        createHour(_hourController.text);
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Add',
                        style: TextStyle(color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                      ),
                    ),
                  ],
                );
              },
            );
          },
          child: Text(
            '+   Add Hour ',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: damber,
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}



