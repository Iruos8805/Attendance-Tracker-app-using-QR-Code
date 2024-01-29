import 'package:attendence_tracker/new%20ap/profiles/profcomponents.dart';
import 'package:attendence_tracker/new%20ap/profiles/profile_pic.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  static String routeName = "/profile";

  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            const ProfilePic(),
            const SizedBox(height: 20),
            ProfileMenu(
              text: "My Account",
              icon: 'assets/icon/settings.png',
              press: () => {},
            ),
            ProfileMenu(
              text: "Settings",
              icon: "assets/icon/settings.png",
              press: () {},
            ),
            ProfileMenu(
              text: "Help Center",
              icon: "assets/icon/questionmark.png",
              press: () {},
            ),
            ProfileMenu(
              text: "Contact Admin",
              icon: "assets/icon/logout.png",
              press: () {},
            ),
            ProfileMenu(
              text: "Log Out",
              icon: "assets/icon/logout.png",
              press: () {},
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.info_outline_rounded),
          backgroundColor: Colors.white10,
          onPressed: () {}),
    );
  }
}
