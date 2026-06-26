import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/finance_provider.dart';
import '../models/transaction.dart';
import '../models/debt.dart';
import '../main.dart'; // for ThemeProvider
import '../widgets/common/premium_gradient_card.dart';
import '../widgets/unified_activity_card.dart';
import '../widgets/spending_breakdown_sheet.dart';
import '../widgets/add_transaction_modal.dart';
import 'profile_screen.dart';
import 'calculator_hub_screen.dart';
import 'fuel_screen.dart';
import '../providers/fuel_provider.dart';

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
              builder: (context, textColor, subTextColor) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Net Balance', style: TextStyle(color: subTextColor, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(
                    '₹${financeProvider.totalBalance.toStringAsFixed(0)}',
                    style: TextStyle(color: textColor, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: -1),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Income', style: TextStyle(color: subTextColor, fontSize: 11)),
                          Text('₹${financeProvider.totalIncome.toStringAsFixed(0)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Total Expenses', style: TextStyle(color: subTextColor, fontSize: 11)),
                          Text('₹${financeProvider.totalExpenses.toStringAsFixed(0)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Net Savings', style: TextStyle(color: subTextColor, fontSize: 11)),
                          Text('₹${financeProvider.totalSavings.toStringAsFixed(0)}', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Spending Summary ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Spending Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const AddTransactionModal(),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.add, size: 14, color: Theme.of(context).colorScheme.onPrimary),
                        const SizedBox(width: 4),
                        Text('Add', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SpendingSummaryGrid(financeProvider: financeProvider),
            const SizedBox(height: 32),

            // Calculator Hub
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Calculator Hub', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalculatorHubScreen())),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalculatorHubScreen())),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                  image: DecorationImage(
                    image: const NetworkImage('https://www.transparenttextures.com/patterns/cubes.png'), // Subtle pattern
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Theme.of(context).primaryColor.withOpacity(0.05), BlendMode.dstATop),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: Icon(Icons.calculate_outlined, color: Theme.of(context).primaryColor, size: 28),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Financial Tools', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              Text('Splits, Loans, Trips & Fuel', style: TextStyle(color: Colors.grey, fontSize: 13)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _CalcChip(emoji: '👥', label: 'Splits'),
                        _CalcChip(emoji: '🏦', label: 'Loans'),
                        _CalcChip(emoji: '⛽', label: 'Fuel'),
                        _CalcChip(emoji: '✈️', label: 'Trips'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),


            // Unified Recent Activity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Activity', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                TextButton(
                  onPressed: () => showSpendingBreakdownSheet(context, 'All Time'),
                  child: const Text('See all'),
                ),
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

}

// ─── SPENDING SUMMARY GRID ─────────────────────────────────────────────────────
class _SpendingSummaryGrid extends StatelessWidget {
  final FinanceProvider financeProvider;
  const _SpendingSummaryGrid({required this.financeProvider});

  @override
  Widget build(BuildContext context) {
    final periods = ['Today', 'This Week', 'This Month', 'This Year', 'All Time'];
    final fmt = NumberFormat('#,##,##0', 'en_IN');

    final Map<String, double> amounts = {
      'Today': financeProvider.spendingToday,
      'This Week': financeProvider.spendingThisWeek,
      'This Month': financeProvider.spendingThisMonth,
      'This Year': financeProvider.spendingThisYear,
      'All Time': financeProvider.totalExpenses,
    };

    final Map<String, Map<String, dynamic>> summaries = {
      for (var p in periods) p: financeProvider.spendingSummary(p),
    };

    return Column(children: [
      // First two side by side
      Row(
        children: [
          Expanded(child: _SummaryCard(period: 'Today', amount: amounts['Today']!, summary: summaries['Today']!, fmt: fmt)),
          const SizedBox(width: 12),
          Expanded(child: _SummaryCard(period: 'This Week', amount: amounts['This Week']!, summary: summaries['This Week']!, fmt: fmt)),
        ],
      ),
      const SizedBox(height: 12),
      // Next two side by side
      Row(
        children: [
          Expanded(child: _SummaryCard(period: 'This Month', amount: amounts['This Month']!, summary: summaries['This Month']!, fmt: fmt)),
          const SizedBox(width: 12),
          Expanded(child: _SummaryCard(period: 'This Year', amount: amounts['This Year']!, summary: summaries['This Year']!, fmt: fmt)),
        ],
      ),
      const SizedBox(height: 12),
      // All Time – full width
      _SummaryCard(period: 'All Time', amount: amounts['All Time']!, summary: summaries['All Time']!, fmt: fmt, fullWidth: true),
    ]);
  }
}

class _SummaryCard extends StatelessWidget {
  final String period;
  final double amount;
  final Map<String, dynamic> summary;
  final NumberFormat fmt;
  final bool fullWidth;

  const _SummaryCard({
    required this.period, required this.amount, required this.summary,
    required this.fmt, this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final count = summary['count'] as int;
    final pctChange = summary['pctChange'] as double?;
    final bool up = pctChange != null && pctChange >= 0;

    return GestureDetector(
      onTap: () => showSpendingBreakdownSheet(context, period),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: fullWidth
            ? Row(
                children: [
                  Expanded(child: _CardContent(period: period, amount: amount, count: count, pctChange: pctChange, up: up, fmt: fmt)),
                  Icon(Icons.chevron_right, color: Colors.grey.withOpacity(0.5), size: 20),
                ],
              )
            : _CardContent(period: period, amount: amount, count: count, pctChange: pctChange, up: up, fmt: fmt),
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  final String period;
  final double amount;
  final int count;
  final double? pctChange;
  final bool up;
  final NumberFormat fmt;

  const _CardContent({required this.period, required this.amount, required this.count, required this.pctChange, required this.up, required this.fmt});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(period, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
            if (pctChange != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: (up ? const Color(0xFFEF4444) : const Color(0xFF10B981)).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(up ? Icons.trending_up : Icons.trending_down, size: 10, color: up ? const Color(0xFFEF4444) : const Color(0xFF10B981)),
                    const SizedBox(width: 2),
                    Text('${up ? '+' : ''}${pctChange!.toStringAsFixed(0)}%',
                      style: TextStyle(color: up ? const Color(0xFFEF4444) : const Color(0xFF10B981), fontSize: 9, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text('₹${fmt.format(amount)}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
        const SizedBox(height: 4),
        Text('$count transaction${count != 1 ? 's' : ''}',
          style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}

class _CalcChip extends StatelessWidget {
  final String emoji;
  final String label;

  const _CalcChip({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 20)),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
