import 'package:flutter/material.dart';

class SectionLabel extends StatelessWidget {
  final String text;

  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: Colors.white.withOpacity(0.4),
        fontSize: 11,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
