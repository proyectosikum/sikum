import 'package:flutter/material.dart';

class ScreenSubtitle extends StatelessWidget {
  final String text;

  const ScreenSubtitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      )),
    );
  }
}