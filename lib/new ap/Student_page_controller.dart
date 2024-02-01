import 'package:attendence_tracker/new%20ap/profile_screen.dart';
import 'package:attendence_tracker/new%20ap/student_page%20.dart';
import 'package:attendence_tracker/new%20ap/studetns_attandance_det.dart';
import 'package:flutter/material.dart';

class StudentPageController extends StatefulWidget {
  final String uid;
  final String email;
  const StudentPageController({required this.uid, required this.email});
  @override
  _StudentPageControllerState createState() => _StudentPageControllerState();
}

class _StudentPageControllerState extends State<StudentPageController> {
  int _currindex = 0;

  final PageController _pageController = PageController(initialPage: 0);
  final _bottomNavigationBarItems = [
    const BottomNavigationBarItem(
        icon: Icon(
          Icons.home,
          color: Colors.green,
        ),
        label: "Home"),
    const BottomNavigationBarItem(
        icon: Icon(
          Icons.article_rounded,
          color: Colors.blueGrey,
        ),
        label: "Attendance"),
    const BottomNavigationBarItem(
        icon: Icon(
          Icons.account_circle,
          color: Colors.yellow,
        ),
        label: "Profile"),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (newIndex) {
          setState(() {
            _currindex = newIndex;
          });
        },
        children: [
          StudentPage(uid: widget.uid),
          StudentAttendancePage(email: widget.email),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currindex,
        items: _bottomNavigationBarItems,
        onTap: (index) {
          _pageController.animateToPage(index,
              duration: Duration(microseconds: 500), curve: Curves.easeIn);
        },
        selectedItemColor: Colors.black26,
      ),
    );
  }
}
