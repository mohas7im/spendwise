import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../models/transaction.dart';
import '../models/debt.dart';
import '../main.dart'; // for ThemeProvider
import '../widgets/common/premium_gradient_card.dart';
import '../widgets/unified_activity_card.dart';
import 'profile_screen.dart';
import 'split_calculator_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final financeProvider = Provider.of<FinanceProvider>(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 16.0, bottom: 120.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome Back,', style: Theme.of(context).textTheme.bodyMedium),
                        Text('Jacob Simmons', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                      ],
                    )
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                      onPressed: () => themeProvider.toggleTheme(!isDark),
                    ),
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.notifications_none, size: 20),
                        onPressed: () {},
                      ),
                    )
                  ],
                )
              ],
            ),
            const SizedBox(height: 24),
            
            // Financial Summary Section
            PremiumGradientCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Net Balance', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(
                    '₹${financeProvider.totalBalance.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: -1),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Income', style: TextStyle(color: Colors.white60, fontSize: 11)),
                          Text('₹${financeProvider.totalIncome.toStringAsFixed(0)}', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text('Total Expenses', style: TextStyle(color: Colors.white60, fontSize: 11)),
                          Text('₹${financeProvider.totalExpenses.toStringAsFixed(0)}', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Net Savings', style: TextStyle(color: Colors.white60, fontSize: 11)),
                          Text('₹${financeProvider.totalSavings.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Spending Summary Horizon
            const Text('Spending Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  _buildSummaryPill(context, 'Today', financeProvider.spendingToday),
                  const SizedBox(width: 12),
                  _buildSummaryPill(context, 'This Week', financeProvider.spendingThisWeek),
                  const SizedBox(width: 12),
                  _buildSummaryPill(context, 'This Month', financeProvider.spendingThisMonth),
                  const SizedBox(width: 12),
                  _buildSummaryPill(context, 'This Year', financeProvider.spendingThisYear),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Unified Recent Activity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Activity', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                TextButton(onPressed: () {}, child: const Text('See all')),
              ],
            ),
            const SizedBox(height: 16),
            
            Builder(
              builder: (ctx) {
                final activities = financeProvider.recentActivity;
                if (activities.isEmpty) {
                  return const Center(child: Text('No recent activity.', style: TextStyle(color: Colors.grey)));
                }
                
                return Column(
                  children: activities.take(10).map((act) => UnifiedActivityCard(activity: act)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryPill(BuildContext context, String label, double amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text('₹${amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
