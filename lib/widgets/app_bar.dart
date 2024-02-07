import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.purple,
      title: Center(
        child: Text("Student's Page",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // children: [
          //   IconButton(
          //     onPressed: () {},
          //     icon: const Icon(
          //       Icons.dashboard_rounded,
          //       color: Colors.purple,
          //     ),
          //   ),
          //   IconButton(
          //     onPressed: () {},
          //     icon: const Icon(
          //       Icons.settings_outlined,
          //       color: Colors.purple,
          //     ),
          //   ),
          // ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
