import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  final TabController controller;
  final List<Tab> tabs;
  final EdgeInsetsGeometry padding;

  const CustomTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
  });

  @override
  Widget build(BuildContext context) {
    final indicatorColor = Theme.of(context).primaryColor;
    final activeLabelColor = Theme.of(context).colorScheme.onPrimary;

    return Padding(
      padding: padding,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TabBar(
          controller: controller,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: indicatorColor,
            borderRadius: BorderRadius.circular(12),
          ),
          labelColor: activeLabelColor,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          dividerColor: Colors.transparent,
          tabs: tabs,
        ),
      ),
    );
  }
}
