import 'package:flutter/material.dart';

class CustomProgressBar extends StatelessWidget {
  final double percent;
  final double minHeight;

  const CustomProgressBar({
    super.key,
    required this.percent,
    this.minHeight = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    // Dynamic color logic based on usage
    final Color progressColor;
    if (percent > 1.0) {
      progressColor = Colors.redAccent;
    } else if (percent > 0.7) {
      progressColor = const Color(0xFFF59E0B); // Orange
    } else {
      progressColor = Colors.blue;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(minHeight),
      child: LinearProgressIndicator(
        value: percent.clamp(0.0, 1.0),
        minHeight: minHeight,
        backgroundColor: Colors.grey.withValues(alpha: 0.15),
        valueColor: AlwaysStoppedAnimation<Color>(progressColor),
      ),
    );
  }
}
