import 'package:attendence_tracker/views/QR_SCANNER_WITHBACK.dart';
import 'package:attendence_tracker/widgets/app_bar.dart';
import 'package:attendence_tracker/widgets/generate_qr_button.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({Key? key}) : super(key: key);

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(),
      body: Stack(
        children: [
          // Background Image
          Image.asset(
            'assets/images/back2.jpeg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
            child: Column(
              children: [
                SizedBox(height: AppBar().preferredSize.height + 20),
                SizedBox(height: 50),// Adjusted top margin
                Text(
                  "Hello! Don't bunk your classes",
                  style: TextStyle(
                    fontSize: 40,
                    fontFamily: GoogleFonts.josefinSans().fontFamily,
                    color: Colors.purple,
                  ),
                ),
                SizedBox(height: 60),
                Container(
                  height: 200,
                  width: 200,
                  child: Image.asset(
                    'assets/images/attend.png',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 20),
                // Text(
                //   'Roll number: {}',
                //   style: TextStyle(
                //     fontSize: 20,
                //     fontFamily: GoogleFonts.zillaSlab().fontFamily,
                //     fontWeight: FontWeight.bold,
                //     color: Colors.black,
                //   ),
                // ),
                SizedBox(height: 60),
                Center(
                  child: Text(
                    'Scan the QR code to mark your attendance',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 15,
                      fontFamily: GoogleFonts.barlowSemiCondensed().fontFamily,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  height: 100,
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => QRViewExample()));
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.purple,
                      onPrimary: Colors.white,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.qr_code_scanner_rounded, size: 45,),
                        const SizedBox(width: 8),
                        Text(
                          'QR Scanner',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
