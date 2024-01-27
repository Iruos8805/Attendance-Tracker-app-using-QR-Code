import 'package:attendence_tracker/api.dart';
import 'package:attendence_tracker/appbar.dart';
import 'package:attendence_tracker/constants.dart';
import 'package:attendence_tracker/views/add_class_screen.dart';

import 'package:attendence_tracker/widgets/bottom_navbar.dart';
import 'package:attendence_tracker/widgets/generate_qr_button.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  
Future<List<Map<String, dynamic>>> fetchClasses() async {
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}${ApiConfig.classEndpoint}'),
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((classEntry) => {
      'id': classEntry['id'],
      'classname': classEntry['classname'].toString(),
    }).toList();
  } else {
    throw Exception('Failed to load classes');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
             CustomAppBar(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hello !",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            child: Image.asset(
                              "assets/images/teacher.png",
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: fetchClasses(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Text('No classes yet.');
                            } else {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Classes',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    height: 500, 
                                    child: ListView.builder(
                                      itemCount: snapshot.data!.length,
                                      itemBuilder: (context, index) {
                                              return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddClass(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                          margin: const EdgeInsets.only(bottom: 25),
                                          padding: const EdgeInsets.all(18),
                                          decoration: BoxDecoration(
                                            color: Colors.lightBlue[100], 
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                            snapshot.data![index]['classname'],
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.qr_code),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => GenerateQRPage(classId: snapshot.data![index]['id']),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                              );
                                      },
                                    ),
                                    
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                        ],
                      ),
                    ),
          ],
              ),
            ),
        
      
      bottomNavigationBar: const BottomNavBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddClass()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Class'),
        backgroundColor: kpurple,
        elevation: 20.0,
      ),
    );
  }
}

