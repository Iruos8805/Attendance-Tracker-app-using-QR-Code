import 'package:attendence_tracker/new%20ap/profile_screen.dart';
import 'package:attendence_tracker/new%20ap/student_page%20.dart';
import 'package:attendence_tracker/new%20ap/studetns_attandance_det.dart';
import 'package:flutter/material.dart';
import 'package:attendence_tracker/new%20ap/constants.dart';

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
    BottomNavigationBarItem(
      icon: Icon(
        Icons.home,
        color: Colors.white,
      ),
      label: "Home",
    ),
    BottomNavigationBarItem(
      icon: Icon(
        Icons.article_rounded,
        color: Colors.white,
      ),
      label: "Attendance",
    ),
    BottomNavigationBarItem(
      icon: Icon(
        Icons.account_circle,
        color: Colors.white,
      ),
      label: "Profile",
    ),
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
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          // Set the label text color to white
          primaryColor: Colors.white,
        ),
        child: BottomNavigationBar(
          currentIndex: _currindex,
          items: _bottomNavigationBarItems,
          onTap: (index) {
            _pageController.animateToPage(
              index,
              duration: Duration(microseconds: 500),
              curve: Curves.easeIn,
            );
          },
          selectedItemColor: Colors.amber,
          unselectedItemColor: Colors.white ,
          // Set the background color to damber
          backgroundColor: damber,
        ),
      ),
    );
  }
}
