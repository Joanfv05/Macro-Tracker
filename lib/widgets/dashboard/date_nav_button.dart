import 'package:flutter/material.dart';

class DateNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const DateNavButton({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color:
              onTap == null ? Colors.white.withOpacity(0.2) : Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
