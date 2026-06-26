import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/budget_provider.dart';
import '../models/budget.dart';

class BudgetAnalyticsScreen extends StatelessWidget {
  const BudgetAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Budget Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<BudgetProvider>(
        builder: (context, provider, child) {
          final budget = provider.budget;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(title: 'Budget vs. Actual Spending'),
                const SizedBox(height: 12),
                _buildBudgetVsActualChart(budget, context),
                const SizedBox(height: 28),

                _SectionHeader(title: 'Category-wise Utilization'),
                const SizedBox(height: 12),
                _buildCategoryUtilizationList(budget, context),
                const SizedBox(height: 28),

                _SectionHeader(title: 'Savings Progress'),
                const SizedBox(height: 12),
                _buildSavingsProgressChart(budget, context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBudgetVsActualChart(BudgetModel budget, BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    double totalBudget = budget.globalLimits.isNotEmpty
        ? budget.globalLimits.first.limitAmount
        : budget.categoryLimits.fold(0, (sum, l) => sum + l.limitAmount);
    double totalSpent = budget.globalLimits.isNotEmpty
        ? budget.globalLimits.first.spentAmount
        : budget.categoryLimits.fold(0, (sum, l) => sum + l.spentAmount);
    final isOver = totalSpent > totalBudget;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _LegendDot(color: primary, label: 'Budget'),
              _LegendDot(color: isOver ? Colors.redAccent : Colors.green, label: 'Spent'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (totalBudget > totalSpent ? totalBudget : totalSpent) * 1.2,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          value == 0 ? 'Budget' : 'Spent',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [BarChartRodData(toY: totalBudget, color: primary, width: 44, borderRadius: BorderRadius.circular(10))],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [BarChartRodData(toY: totalSpent, color: isOver ? Colors.redAccent : Colors.green, width: 44, borderRadius: BorderRadius.circular(10))],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatChip(label: 'Total Budget', value: '₹${totalBudget.toStringAsFixed(0)}', color: primary),
              _StatChip(label: 'Total Spent', value: '₹${totalSpent.toStringAsFixed(0)}', color: isOver ? Colors.redAccent : Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryUtilizationList(BudgetModel budget, BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    if (budget.categoryLimits.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('No category limits set.', style: TextStyle(color: Colors.grey.withOpacity(0.7))),
        ),
      );
    }

    // Sort by spent descending for better visualization
    final sorted = [...budget.categoryLimits]..sort((a, b) => b.spentAmount.compareTo(a.spentAmount));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: sorted.map((limit) {
          final pct = (limit.percentUsed).clamp(0.0, 1.0);
          final isOver = limit.isOverBudget;
          final barColor = isOver ? Colors.redAccent : pct > 0.9 ? Colors.orange : primary;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(limit.emoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(limit.category, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    ),
                    if (isOver)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('OVER', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    else
                      Text('${(pct * 100).toStringAsFixed(0)}%', style: TextStyle(color: barColor, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 8,
                    backgroundColor: Colors.grey.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('₹${limit.spentAmount.toStringAsFixed(0)} spent', style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6))),
                    Text('of ₹${limit.limitAmount.toStringAsFixed(0)}', style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6))),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSavingsProgressChart(BudgetModel budget, BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    if (budget.savingsGoals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('No savings goals set.', style: TextStyle(color: Colors.grey.withOpacity(0.7))),
        ),
      );
    }

    return Column(
      children: budget.savingsGoals.map((goal) {
        final pct = goal.progressPercentage;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.flag_circle, color: primary, size: 20),
                      const SizedBox(width: 8),
                      Text(goal.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('${(pct * 100).toStringAsFixed(1)}%', style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 10,
                  backgroundColor: Colors.grey.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(pct >= 1.0 ? Colors.green : primary),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('₹${goal.currentAmount.toStringAsFixed(0)} saved', style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7))),
                  Text('Target: ₹${goal.targetAmount.toStringAsFixed(0)}', style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7))),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16));
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6))),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
