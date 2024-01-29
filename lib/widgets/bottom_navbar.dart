import 'package:attendence_tracker/widgets/home_screen.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: Colors.black), // Set color to black
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.details, color: Colors.black), // Set color to black
          label: 'Attendance Details',
        ),
      ],
      onTap: (index) {
        if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else if (index == 1) {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => AttendanceList()),
          // );
        }
      },
    );
  }
}
