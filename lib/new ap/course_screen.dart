import 'package:attendence_tracker/new%20ap/class_screen.dart';
import 'package:attendence_tracker/new%20ap/constants.dart';
import 'package:attendence_tracker/new%20ap/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CourseScreen extends StatefulWidget {
  const CourseScreen({Key? key}) : super(key: key);

  @override
  _CourseScreenState createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  Future<List<Map<String, dynamic>>> fetchCourses() async {
    final response = await http.get(
      Uri.parse('https://group4attendance.pythonanywhere.com/api/courses/'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((courseEntry) => {
        'id': courseEntry['id'],
        'course_name': courseEntry['course_name'].toString(),
      }).toList();
    } else {
      throw Exception('Failed to load courses');
    }
  }

  Future<void> postcourses(String className) async {
    final response = await http.post(
      Uri.parse('https://group4attendance.pythonanywhere.com/api/courses/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'course_name': className,
      }),
    );

    if (response.statusCode == 201) {
      print('Course added');
      setState(() {});
    } else {
      print('Failed ${response.statusCode}');
    }
  }

  Future<void> _deleteCourse(int courseId) async {
    final response = await http.delete(
      Uri.parse('https://group4attendance.pythonanywhere.com/api/courses/$courseId/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 204) {
      print('Course deleted');
      setState(() {});
    } else {
      print('Failed to delete course: ${response.statusCode}');
    }
  }

  void _createClass() {
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
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                String className = _controller.text;
                postcourses(className);
                Navigator.of(context).pop();
              },
              child: Text(
                "Add",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Center(
            child: Text(
              "Teacher's Page",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(40),
            ),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: damber,
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20,),
              GestureDetector(
                onTap: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(),
                    ),
                  );
                },
                child: Container(
                  width: 125,
                  height: 125,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/unnamed.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Courses',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchCourses(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No courses yet.'));
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ClassScreen(courseId: snapshot.data![index]['id']),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Container(
                                  width: 300,
                                  margin: EdgeInsets.only(bottom: 5),
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: ksecblue,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          snapshot.data![index]['course_name'],
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {_deleteCourse(snapshot.data![index]['id']);},
                                        icon: Icon(Icons.delete_forever_outlined,
                                            color: damber,
                                            size: 30),
                                      ),
                                    ],
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
            ],
          ),
        ),
        floatingActionButton: Container(
          margin: EdgeInsets.only(bottom: 66),
          child: FloatingActionButton.extended(
            onPressed: _createClass,
            label: Text(
              'Add Courses',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            icon: Icon(Icons.add, color: Colors.white),
            backgroundColor: damber,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}


