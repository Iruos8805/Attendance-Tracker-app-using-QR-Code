import 'package:attendence_tracker/new%20ap/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'hour_page.dart'; // Import the HourPage

class ClassScreen extends StatefulWidget {
  final int courseId;

  const ClassScreen({Key? key, required this.courseId}) : super(key: key);

  @override
  _ClassScreenState createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen> {
  late Future<List<dynamic>> _fetchClasses;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _fetchClasses = fetchClasses(widget.courseId);
    _controller = TextEditingController();
  }

  Future<List<dynamic>> fetchClasses(int courseId) async {
    final response = await http.get(
      Uri.parse('https://group4attendance.pythonanywhere.com/api/courses/$courseId/classes/'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load classes');
    }
  }

  Future<void> addClass(String className) async {
    final courseId = widget.courseId;

    final response = await http.post(
      Uri.parse('https://group4attendance.pythonanywhere.com/api/courses/$courseId/classes/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'class_name': className,
        'course_id': courseId,
      }),
    );

    if (response.statusCode == 201) {
      setState(() {
        _fetchClasses = fetchClasses(widget.courseId);
      });
      print('Class added');
    } else {
      print('Failed ${response.statusCode}');
    }
  }

  void _addClass() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Class"),
          backgroundColor: Colors.white,
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: "Class Name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel",
              style: TextStyle(
                color: Colors.black
              ),),
            ),
            TextButton(
              onPressed: () {
                String className = _controller.text;
                addClass(className);
                Navigator.of(context).pop();
              },
              child: Text("Add",
              style: TextStyle(
                color: Colors.black
              ),),
            ),
          ],
        );
      },
    );
  }

  void _navigateToHourPage(int classId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HourPage(courseId: widget.courseId, classId: classId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Classes',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: damber,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        automaticallyImplyLeading: false,
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
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Background Image
            Positioned(
              top: 150,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(12.0),
                child: Image.asset(
                  'assets/images/attend.png',
                  height: 100,
                  width: 100,
                ),
              ),
            ),
            // Classes
            Positioned(
              top: 200,
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: FutureBuilder<List<dynamic>>(
                      future: _fetchClasses,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData) {
                          return Center(child: Text('No classes found.', style: TextStyle(color: Colors.white)));
                        } else {
                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  _navigateToHourPage(snapshot.data![index]['id']);
                                },
                                child: Container(
                                  margin: EdgeInsets.all(10),
                                  padding: EdgeInsets.all(25),
                                  decoration: BoxDecoration(
                                    color: ksecblue,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      snapshot.data![index]['class_name'],
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,
                                      fontSize: 18),
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
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addClass,
        label: Text(
          'Add Class',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        icon: Icon(Icons.add, color: Colors.white),
        backgroundColor: damber,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      extendBodyBehindAppBar: true,
    );
  }
}
