import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/global_transaction.dart';
import 'spending_analytics_screen.dart';

class CategoryAnalyticsScreen extends StatelessWidget {
  final String categoryName;
  final String categoryEmoji;
  final Color categoryColor;
  final List<GlobalTransaction> transactions;
  final TimeFilter timeFilter;
  final DateTimeRange? dateRange;
  final double? budgetLimit;

  const CategoryAnalyticsScreen({
    super.key,
    required this.categoryName,
    required this.categoryEmoji,
    required this.categoryColor,
    required this.transactions,
    required this.timeFilter,
    this.dateRange,
    this.budgetLimit,
  });

  @override
  Widget build(BuildContext context) {
    final sortedTxs = List<GlobalTransaction>.from(transactions)..sort((a, b) => b.date.compareTo(a.date));
    final totalSpent = sortedTxs.fold(0.0, (sum, t) => sum + t.amount);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Text(categoryEmoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(categoryName, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: sortedTxs.isEmpty
          ? const Center(child: Text('No transactions in this period.'))
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildSummaryMetrics(context, totalSpent, sortedTxs)),
                SliverToBoxAdapter(child: _buildCategoryTrendChart(context, sortedTxs)),
                if (budgetLimit != null)
                  SliverToBoxAdapter(child: _buildBudgetInsight(context, totalSpent, isDark)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Text('Transactions', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final t = sortedTxs[index];
                      return _buildTransactionTile(context, t);
                    },
                    childCount: sortedTxs.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
    );
  }

  Widget _buildSummaryMetrics(BuildContext context, double totalSpent, List<GlobalTransaction> txs) {
    double highest = 0;
    double lowest = double.infinity;
    for (var t in txs) {
      if (t.amount > highest) highest = t.amount;
      if (t.amount < lowest) lowest = t.amount;
    }
    if (lowest == double.infinity) lowest = 0;

    double avg = txs.isEmpty ? 0 : totalSpent / txs.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildMetricCard(context, 'Total Spent', '₹${totalSpent.toStringAsFixed(0)}', categoryColor)),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricCard(context, 'Average', '₹${avg.toStringAsFixed(0)}', Colors.blue)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMetricCard(context, 'Highest', '₹${highest.toStringAsFixed(0)}', Colors.orange)),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricCard(context, 'Transactions', '${txs.length}', Colors.purple)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String label, String value, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCategoryTrendChart(BuildContext context, List<GlobalTransaction> txs) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Group by day
    final sortedTxs = List<GlobalTransaction>.from(txs)..sort((a, b) => a.date.compareTo(b.date));
    Map<String, double> aggregated = {};
    for (var t in sortedTxs) {
      String key = DateFormat('MMM d').format(t.date);
      aggregated[key] = (aggregated[key] ?? 0) + t.amount;
    }

    List<BarChartGroupData> barGroups = [];
    List<String> labels = aggregated.keys.toList();
    double maxY = 0;
    
    for (int i = 0; i < labels.length; i++) {
      double val = aggregated[labels[i]]!;
      if (val > maxY) maxY = val;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: val,
              color: categoryColor,
              width: 12,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            )
          ],
        )
      );
    }
    if (maxY == 0) maxY = 100;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Spending Trend', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                maxY: maxY * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => isDark ? Colors.white : Colors.black87,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '₹${rod.toY.round()}',
                        TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 3 > 0 ? maxY / 3 : 1,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withValues(alpha: 0.1), strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= labels.length) return const SizedBox();
                        if (labels.length > 5 && index % (labels.length ~/ 4) != 0 && index != labels.length - 1) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(labels[index], style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                barGroups: barGroups,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetInsight(BuildContext context, double totalSpent, bool isDark) {
    bool overBudget = totalSpent > budgetLimit!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: overBudget ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: overBudget ? Colors.red.withValues(alpha: 0.3) : Colors.green.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(overBudget ? Icons.warning_amber_rounded : Icons.check_circle_outline, color: overBudget ? Colors.redAccent : Colors.green),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(overBudget ? 'Budget Exceeded' : 'On Track', style: TextStyle(color: overBudget ? Colors.redAccent : Colors.green, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    overBudget 
                      ? 'You exceeded your $categoryName budget by ₹${(totalSpent - budgetLimit!).toStringAsFixed(0)}.'
                      : 'You still have ₹${(budgetLimit! - totalSpent).toStringAsFixed(0)} left in your budget.',
                    style: TextStyle(fontSize: 13, height: 1.4, color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(BuildContext context, GlobalTransaction t) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: categoryColor.withValues(alpha: 0.15),
        child: Icon(Icons.receipt_long, color: categoryColor, size: 20),
      ),
      title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(DateFormat('MMM d, yyyy').format(t.date), style: const TextStyle(fontSize: 12)),
      trailing: Text('₹${t.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
    );
  }
}
