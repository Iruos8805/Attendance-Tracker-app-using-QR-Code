// AddClass.dart

import 'package:attendence_tracker/api.dart';
import 'package:attendence_tracker/appbar.dart';
import 'package:attendence_tracker/widgets/bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;

final _classFormKey = GlobalKey<FormState>();
final _studentFormKey = GlobalKey<FormState>();
final _classNameController = TextEditingController();
final _rollNoController = TextEditingController();
final _nameController = TextEditingController();

class AddClass extends StatefulWidget {
  @override
  _AddClassState createState() => _AddClassState();
}

class _AddClassState extends State<AddClass> {
  String? addedClassName;

  List<String> studentDetails = [];
  List<String> classDetails = [];

  Future<void> postClass(String className) async {
    final response = await http.post(
      Uri.parse(ApiConfig.baseUrl + ApiConfig.classEndpoint),
      body: {'classname': className},
    );
    print('Failed ${response.statusCode}');
    if (response.statusCode == 201) {
      print('Class added');
    } else {
      print('Failed ${response.statusCode}');
    }
  }

  Future<void> postStudent(String uid, String name, int classId) async {
    final response = await http.post(
      Uri.parse(ApiConfig.baseUrl +
          ApiConfig.classEndpoint +
          '$classId/${ApiConfig.studentsAddEndpoint}'),
      body: {
        'uid': uid,
        'name': name,
        'classname': classId.toString(),
      },
    );

    if (response.statusCode == 201) {
      print('Student added');
    } else {
      print('Failed ${response.statusCode}');
    }
  }

  Future<int?> fetchClassId(String className) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.classEndpoint}?classname=$className'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      for (var classEntry in data) {
        if (classEntry['classname'] == className) {
          print(classEntry['id']);
          return classEntry['id'] as int;

        }
      }
    }
    print("returning null");
    return null;
  }

  Future<List<String>> fetchStudents(String className) async {
    final classId = await fetchClassId(className);
    if (classId != null) {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.classEndpoint}$classId/${ApiConfig.studentsAddEndpoint}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((student) => 'Roll No: ${student['uid']}, Name: ${student['name']}').toList();
      }
    }
    return [];
  }

  Color? boxColor;
  bool showClassForm = true;
  bool showStudentForm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppBar(),
            const Padding(
              padding: EdgeInsets.all(9.0),
            ),
            if (showClassForm)
              Form(
                key: _classFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _classNameController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.class_rounded,
                          color: Colors.teal,
                        ),
                        hintText: 'Class Name',
                        hintStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Class name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        backgroundColor: const Color.fromARGB(255, 117, 205, 221),
                      ),
                      onPressed: () {
                        if (_classFormKey.currentState!.validate()) {
                          postClass(_classNameController.text);
                          setState(() {
                            classDetails.add('Class Name: ${_classNameController.text},');
                            boxColor = Colors.primaries[Random().nextInt(Colors.primaries.length)];
                            showClassForm = false;
                            showStudentForm = false;
                            studentDetails.clear();
                          });
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            if (boxColor != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: boxColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_classNameController.text),
                  ],
                ),
              ),
            if (showStudentForm)
              Column(
                children: [
                  const SizedBox(height: 20),
                  Form(
                    key: _studentFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _rollNoController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(
                              Icons.class_rounded,
                              color: Color.fromARGB(255, 26, 153, 37),
                            ),
                            labelText: 'Roll No',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Roll No is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(
                              Icons.numbers,
                              color: Color.fromARGB(255, 26, 153, 37),
                            ),
                            labelText: 'Name',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () async {
                            if (_studentFormKey.currentState!.validate()) {
                              final classId = await fetchClassId(_classNameController.text);
                              if (classId != null) {
                                postStudent(_rollNoController.text, _nameController.text, classId);
                                setState(() {
                                  studentDetails.add('Roll No: ${_rollNoController.text}, Name: ${_nameController.text}');
                                  _rollNoController.clear();
                                  _nameController.clear();
                                  showStudentForm = false;
                                });
                              } else {
                                print('Error: Class ID not found for class name ${_classNameController.text}');
                              }
                            }
                          },
                          child: const Text('Submit'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            if (!showClassForm && !showStudentForm)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showStudentForm = true;
                  });
                },
                child: const Text('Add Student Details'),
              ),
            const SizedBox(height: 20),
            if (!showStudentForm)
              FutureBuilder<List<String>>(
                future: fetchStudents(_classNameController.text),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No students in this class.');
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Student Details:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        DataTable(
                          columns: const [
                            DataColumn(label: Text('Roll No')),
                            DataColumn(label: Text('Name')),
                          ],
                          rows: snapshot.data!.map((student) {
                            final studentData = student.split(', ');
                            return DataRow(cells: [
                              DataCell(Text(studentData[0].substring(9))),
                              DataCell(Text(studentData[1].substring(6))),
                            ]);
                          }).toList(),
                        ),
                      ],
                    );
                  }
                },
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
