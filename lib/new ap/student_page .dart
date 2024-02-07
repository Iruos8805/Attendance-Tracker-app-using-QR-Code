import 'package:attendence_tracker/new%20ap/constants.dart';
import 'package:attendence_tracker/new%20ap/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flip_card/flip_card.dart';

class StudentPage extends StatefulWidget {
  final String uid;

  const StudentPage({required this.uid});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  bool _showBack = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Center(
          child: Text(
            "Student's Page",
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              kdmeroon,
              kdblue,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  );
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 5.0),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/graduating-student2.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 100),
              FlipCard(
                direction: FlipDirection.VERTICAL,
                flipOnTouch: true,
                front: _buildFront(),
                back: _buildBack(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFront() {
    return Column(
      children: [
        Container(
          height: 200,
          width: 200,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(15.0),
            image: DecorationImage(
              image: AssetImage('assets/images/scan-qr.png'),
              fit: BoxFit.fill,
            ),
          ),
        ),
        Text(
          'Tap to view the QR code',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 25,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.merriweatherSans().fontFamily,
          ),
        ),
      ],
    );
  }

  Widget _buildBack() {
    return InkWell(
      onTap: () {
        setState(() {
          _showBack = false;
        });
      },
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(color: Colors.white, width: 2.0),
        ),
        child: widget.uid.isNotEmpty
            ? Container(
                color: Colors.white,
                child: QrImageView(
                  data: widget.uid,
                  size: 300,
                  embeddedImageStyle: QrEmbeddedImageStyle(
                    size: Size(80, 80),
                  ),
                ),
              )
            : Center(
                child: Text(
                  'Error: Invalid QR data',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
              ),
      ),
    );
  }
}
