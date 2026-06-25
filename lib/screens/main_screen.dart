import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import '../widgets/add_transaction_modal.dart';

// Placeholder screens
class StatsScreen extends StatelessWidget { const StatsScreen({super.key}); @override Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Stats View', style: Theme.of(context).textTheme.titleLarge))); }
class CardsScreen extends StatelessWidget { const CardsScreen({super.key}); @override Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Cards View', style: Theme.of(context).textTheme.titleLarge))); }
class ProfileScreen extends StatelessWidget { const ProfileScreen({super.key}); @override Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Profile View', style: Theme.of(context).textTheme.titleLarge))); }

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const StatsScreen(),
    Container(), // Placeholder for '+' add action
    const CardsScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      // Show Add Action Modal
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
          
          // Custom Floating Bottom Navigation Bar
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
                    color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  )
                ]
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(0, Icons.home_outlined, Icons.home, activeBgColor, activeIconColor, iconColor),
                  _buildNavItem(1, Icons.bar_chart_outlined, Icons.bar_chart, activeBgColor, activeIconColor, iconColor),
                  _buildNavItem(2, Icons.add_circle_outline, Icons.add_circle, activeBgColor, activeIconColor, iconColor),
                  _buildNavItem(3, Icons.credit_card_outlined, Icons.credit_card, activeBgColor, activeIconColor, iconColor),
                  _buildNavItem(4, Icons.person_outline, Icons.person, activeBgColor, activeIconColor, iconColor),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData iconOutlined, IconData iconFilled, Color activeBgColor, Color activeIconColor, Color iconColor) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected && index != 2 ? activeBgColor : Colors.transparent,
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
}
