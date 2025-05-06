import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  //final String title;
  final VoidCallback onLogout;

  const CustomAppBar({
    super.key,
    //required this.title,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF4F959D),
      elevation: 0,
      title: Text(
        "SIKUM",
        style: const TextStyle(
          color: Color(0xFFFFF8E1),
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Color(0xFFFFF8E1)),
          onPressed: onLogout,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

}
