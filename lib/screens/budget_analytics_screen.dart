import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/budget_provider.dart';
import '../models/budget.dart';
import '../widgets/common/premium_gradient_card.dart';

class BudgetAnalyticsScreen extends StatelessWidget {
  const BudgetAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Budget vs. Actual Spending', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildBudgetVsActualChart(budget, context),
                const SizedBox(height: 32),

                const Text('Category-wise Utilization', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildCategoryUtilizationChart(budget, context),
                const SizedBox(height: 32),

                const Text('Savings Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildSavingsProgressChart(budget, context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBudgetVsActualChart(BudgetModel budget, BuildContext context) {
    double totalBudget = budget.globalLimits.isNotEmpty ? budget.globalLimits.first.limitAmount : budget.categoryLimits.fold(0, (sum, l) => sum + l.limitAmount);
    double totalSpent = budget.globalLimits.isNotEmpty ? budget.globalLimits.first.spentAmount : budget.categoryLimits.fold(0, (sum, l) => sum + l.spentAmount);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
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
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(value == 0 ? 'Budget' : 'Spent', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [BarChartRodData(toY: totalBudget, color: Colors.blue, width: 40, borderRadius: BorderRadius.circular(8))],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [BarChartRodData(toY: totalSpent, color: totalSpent > totalBudget ? Colors.redAccent : Colors.green, width: 40, borderRadius: BorderRadius.circular(8))],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryUtilizationChart(BudgetModel budget, BuildContext context) {
    if (budget.categoryLimits.isEmpty) return const SizedBox();

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: budget.categoryLimits.map((limit) {
            return PieChartSectionData(
              color: limit.isOverBudget ? Colors.redAccent : Colors.primaries[budget.categoryLimits.indexOf(limit) % Colors.primaries.length],
              value: limit.spentAmount > 0 ? limit.spentAmount : 1, // Avoid 0 size
              title: limit.emoji,
              radius: limit.isOverBudget ? 60 : 50,
              titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSavingsProgressChart(BudgetModel budget, BuildContext context) {
    if (budget.savingsGoals.isEmpty) return const Text('No savings goals set.', style: TextStyle(color: Colors.grey));

    return Column(
      children: budget.savingsGoals.map((goal) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(goal.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('${(goal.progressPercentage * 100).toStringAsFixed(1)}%', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: goal.progressPercentage,
                  minHeight: 12,
                  backgroundColor: Colors.grey.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
