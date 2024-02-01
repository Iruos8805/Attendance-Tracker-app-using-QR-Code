import 'package:attendence_tracker/new%20ap/account_details.dart';
import 'package:attendence_tracker/new%20ap/constants.dart';
import 'package:attendence_tracker/new%20ap/help_centre.dart';
import 'package:attendence_tracker/new%20ap/login%20.dart';
import 'package:attendence_tracker/new%20ap/profcomponents.dart';
import 'package:attendence_tracker/screens/database_sql.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  static String routeName = "/profile";

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late SqliteService sqliteService;
  @override
  void initState() {
    super.initState();
    sqliteService = SqliteService();
  }

  Future<void> LogoutUser() async {
    final token = await sqliteService.getTokenForId(1);
    final response = await http.post(
      Uri.parse('https://group4attendance.pythonanywhere.com/api/logout/'),
      headers: {'Authorization': 'Token $token'},
    );
    print(response.body);
    print("'Authorization': 'Token{ $token'");
    if (response.statusCode == 200) {
      print('Logout successful');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    } else {
      print(response.statusCode);
    }
  }

  Future<void> _launchEmail() async {
    // ignore: deprecated_member_use
    var url = launch("mailto:ashwinpraveengo@gmail.com");
    await launch("mailto:ashwinpraveengo@gmail.com");
    // if (await launch(url)) {
    //   await launch(url);
    // } else {
    //   throw 'Could not launch $url';
    // }
  }

  Future<void> _showInformationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Information'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _buildInfoRow('Product Version', '1.0'),
                _buildInfoRow('Database Version', '1.0'),
                _buildInfoRow('Company Name & Address',
                    'HiveSpark, Amrita VishwaVidyapeetham, Amritapuri'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(fontSize: 16),
        ),
        Divider(color: Colors.grey),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        automaticallyImplyLeading: false,
        backgroundColor: kdblue,
      ),
      backgroundColor: kdblue,
      body: Container(
        decoration: BoxDecoration(
          color: kdblue,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              // const ProfilePic(),
              const SizedBox(height: 80),
              ProfileMenu(
                text: "My Account",
                icon: Icons.account_circle_rounded,
                press: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AccountDetailsScreen()),
                  )
                },
              ),
              ProfileMenu(
                text: "Help Center",
                icon: Icons.help_center,
                press: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HelpCentrePage()));
                },
              ),
              ProfileMenu(
                text: "Contact Admin",
                icon: Icons.admin_panel_settings,
                press: () {
                  _launchEmail();
                },
              ),
              ProfileMenu(
                text: "Log Out",
                icon: Icons.logout_outlined,
                press: () {
                  LogoutUser();
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.info_outline_rounded,
            color: Colors.white,
          ),
          backgroundColor: kdblue,
          onPressed: () {
            _showInformationDialog(context);
          }),
    );
  }
}
