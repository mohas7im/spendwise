import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'budget_screen.dart';
import 'debt_screen.dart';
import 'stats_screen.dart';
import 'subscriptions_screen.dart';
import 'calculator_hub_screen.dart';
import '../widgets/add_transaction_modal.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../models/income_source.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _hasCheckedSalaries = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasCheckedSalaries) {
        _hasCheckedSalaries = true;
        _checkPendingSalaries();
      }
    });
  }

  void _checkPendingSalaries() {
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    final pending = provider.getPendingIncomes();
    
    if (pending.isNotEmpty) {
      // Just process the first one for the demo
      _showSalaryArrivalDialog(pending.first, provider);
    }
  }

  void _showSalaryArrivalDialog(IncomeSource inc, FinanceProvider provider) {
    final amountController = TextEditingController(text: inc.amount.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              const Text('🎉', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text('Payday?', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your expected income from ${inc.name} is due around this time.', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Received Amount (₹)',
                  helperText: 'Edit if amount changed due to overtime/LOP',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Not Yet', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final amt = double.tryParse(amountController.text) ?? inc.amount;
                provider.creditIncome(inc.id, amt);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Balance updated successfully!'),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Confirm & Add', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  final List<Widget> _screens = [
    const DashboardScreen(),
    const BudgetScreen(),
    const CalculatorHubScreen(),
    Container(), // '+' add action
    const DebtScreen(),
    const StatsScreen(),
    const SubscriptionsScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 3) {
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
                    color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
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
                  _buildNavItem(2, Icons.calculate_outlined, Icons.calculate, ''),
                  _buildAddButton(),
                  _buildNavItem(4, Icons.account_balance_wallet_outlined, Icons.account_balance_wallet, ''),
                  _buildNavItem(5, Icons.bar_chart_outlined, Icons.bar_chart, ''),
                  _buildNavItem(6, Icons.calendar_today_outlined, Icons.calendar_month, ''),
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
    final activeIconColor = Theme.of(context).primaryColor;
    final activeBgColor = isDark ? Colors.white12 : Colors.black12;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? activeBgColor : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSelected ? iconFilled : iconOutlined,
          color: isSelected ? activeIconColor : iconColor,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    final btnColor = Theme.of(context).primaryColor;
    final iconColor = Theme.of(context).colorScheme.onPrimary;

    return GestureDetector(
      onTap: () => _onItemTapped(3),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: btnColor,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.add, color: iconColor, size: 24),
      ),
    );
  }
}
