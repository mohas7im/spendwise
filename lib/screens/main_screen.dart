import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'budget_screen.dart';
import 'debt_screen.dart';
import 'stats_screen.dart';
import '../widgets/add_transaction_modal.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const BudgetScreen(),
    Container(), // '+' add action
    const DebtScreen(),
    const StatsScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      _showAddModal();
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _showAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTransactionModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBgColor = isDark ? const Color(0xFF161618) : Colors.white;
    final iconColor = isDark ? Colors.white54 : Colors.black54;
    final activeIconColor = isDark ? Colors.white : Colors.black;
    final activeBgColor = isDark ? Colors.white12 : Colors.black12;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          _screens[_currentIndex],

          // Floating Bottom Navigation Bar
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: navBgColor,
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.4 : 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(0, Icons.home_outlined, Icons.home, ''),
                  _buildNavItem(1, Icons.pie_chart_outline, Icons.pie_chart, ''),
                  _buildAddButton(),
                  _buildNavItem(3, Icons.receipt_long_outlined, Icons.receipt_long, ''),
                  _buildNavItem(4, Icons.bar_chart_outlined, Icons.bar_chart, ''),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData iconOutlined, IconData iconFilled, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _currentIndex == index;
    final iconColor = isDark ? Colors.white54 : Colors.black54;
    final activeIconColor = isDark ? Colors.white : Colors.black;
    final activeBgColor = isDark ? Colors.white12 : Colors.black12;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? activeBgColor : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSelected ? iconFilled : iconOutlined,
          color: isSelected ? activeIconColor : iconColor,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final btnColor = isDark ? Colors.white : Colors.black;
    final iconColor = isDark ? Colors.black : Colors.white;

    return GestureDetector(
      onTap: () => _onItemTapped(2),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: btnColor,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.add, color: iconColor, size: 28),
      ),
    );
  }
}
