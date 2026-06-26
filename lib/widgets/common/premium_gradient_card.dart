import 'package:flutter/material.dart';

class PremiumGradientCard extends StatelessWidget {
  final Widget Function(BuildContext context, Color textColor, Color subTextColor) builder;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? color;

  const PremiumGradientCard({
    super.key,
    required this.builder,
    this.padding = const EdgeInsets.all(22),
    this.borderRadius = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Invert the theme colors for the hero effect
    final cardColor = isDark ? const Color(0xFFF8F9FA) : const Color(0xFF1A1A1A);
    final textColor = isDark ? Colors.black : Colors.white;
    final subTextColor = isDark ? Colors.black54 : Colors.white70;

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DefaultTextStyle(
        style: TextStyle(color: textColor),
        child: IconTheme(
          data: IconThemeData(color: textColor),
          child: builder(context, textColor, subTextColor),
        ),
      ),
    );
  }
}
