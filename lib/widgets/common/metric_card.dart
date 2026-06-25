import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  final Color baseColor;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderWidth;

  const MetricCard({
    super.key,
    required this.baseColor,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderWidth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: baseColor.withOpacity(0.3),
          width: borderWidth,
        ),
      ),
      child: child,
    );
  }
}
