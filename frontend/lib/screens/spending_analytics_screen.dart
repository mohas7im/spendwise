import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/ledger_provider.dart';
import '../providers/finance_provider.dart';
import '../providers/budget_provider.dart';
import '../models/global_transaction.dart';
import '../models/budget.dart';
import 'category_analytics_screen.dart';

enum TimeFilter { today, thisWeek, thisMonth, thisQuarter, thisYear, custom }

class SpendingAnalyticsScreen extends StatefulWidget {
  final bool showBackButton;
  const SpendingAnalyticsScreen({super.key, this.showBackButton = false});

  @override
  State<SpendingAnalyticsScreen> createState() => _SpendingAnalyticsScreenState();
}

class _SpendingAnalyticsScreenState extends State<SpendingAnalyticsScreen> {
  TimeFilter _selectedFilter = TimeFilter.thisMonth;
  DateTimeRange? _customDateRange;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Spending Analytics', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.showBackButton ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)) : null,
      ),
      body: SafeArea(
        child: Consumer3<LedgerProvider, FinanceProvider, BudgetProvider>(
          builder: (context, ledger, finance, budget, child) {
            final transactions = _filterTransactions(ledger.transactions);
            final categorySums = _getCategorySums(transactions);
            
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {}); // trigger rebuild
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildTimeFilters()),
                  if (transactions.isEmpty)
                    const SliverFillRemaining(
                      child: Center(
                        child: Text('No spending in this period.', style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  else ...[
                    SliverToBoxAdapter(child: _buildSpendingTrendChart(transactions)),
                    SliverToBoxAdapter(child: _buildSmartInsights(transactions, ledger.transactions)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: Text('Categories', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final entry = categorySums[index];
                            return _buildCategoryCard(entry, transactions, finance, budget);
                          },
                          childCount: categorySums.length,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ]
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTimeFilters() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: TimeFilter.values.map((filter) {
          final isSelected = _selectedFilter == filter;
          String label = '';
          switch (filter) {
            case TimeFilter.today: label = 'Today'; break;
            case TimeFilter.thisWeek: label = 'This Week'; break;
            case TimeFilter.thisMonth: label = 'This Month'; break;
            case TimeFilter.thisQuarter: label = 'This Qtr'; break;
            case TimeFilter.thisYear: label = 'This Year'; break;
            case TimeFilter.custom: label = 'Custom'; break;
          }
          if (filter == TimeFilter.custom && _customDateRange != null) {
            label = '${DateFormat('MMM d').format(_customDateRange!.start)} - ${DateFormat('MMM d').format(_customDateRange!.end)}';
          }
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) async {
                if (filter == TimeFilter.custom) {
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    initialDateRange: _customDateRange,
                  );
                  if (range != null) {
                    setState(() {
                      _customDateRange = range;
                      _selectedFilter = filter;
                    });
                  }
                } else if (selected) {
                  setState(() => _selectedFilter = filter);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  List<GlobalTransaction> _filterTransactions(List<GlobalTransaction> allTxs) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = now;

    switch (_selectedFilter) {
      case TimeFilter.today:
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case TimeFilter.thisWeek:
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case TimeFilter.thisMonth:
        startDate = DateTime(now.year, now.month, 1);
        break;
      case TimeFilter.thisQuarter:
        int startMonth = ((now.month - 1) ~/ 3) * 3 + 1;
        startDate = DateTime(now.year, startMonth, 1);
        break;
      case TimeFilter.thisYear:
        startDate = DateTime(now.year, 1, 1);
        break;
      case TimeFilter.custom:
        if (_customDateRange != null) {
          startDate = _customDateRange!.start;
          endDate = _customDateRange!.end.add(const Duration(days: 1)); // inclusive
        } else {
          startDate = DateTime(now.year, now.month, 1); // fallback
        }
        break;
    }

    return allTxs.where((t) {
      if (t.type != GlobalTransactionType.expense) return false;
      return t.date.isAfter(startDate.subtract(const Duration(seconds: 1))) && 
             t.date.isBefore(endDate.add(const Duration(seconds: 1)));
    }).toList();
  }

  List<MapEntry<String, double>> _getCategorySums(List<GlobalTransaction> txs) {
    final Map<String, double> sums = {};
    for (var t in txs) {
      sums[t.category] = (sums[t.category] ?? 0) + t.amount;
    }
    final sorted = sums.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted;
  }

  Widget _buildSpendingTrendChart(List<GlobalTransaction> txs) {
    final sortedTxs = List<GlobalTransaction>.from(txs)..sort((a, b) => a.date.compareTo(b.date));
    bool groupByMonth = _selectedFilter == TimeFilter.thisYear || _selectedFilter == TimeFilter.thisQuarter;
    
    Map<String, double> aggregated = {};
    for (var t in sortedTxs) {
      String key = groupByMonth 
          ? DateFormat('MMM').format(t.date)
          : DateFormat('MMM d').format(t.date);
      aggregated[key] = (aggregated[key] ?? 0) + t.amount;
    }

    List<FlSpot> spots = [];
    List<String> labels = aggregated.keys.toList();
    double maxY = 0;
    
    for (int i = 0; i < labels.length; i++) {
      double val = aggregated[labels[i]]!;
      spots.add(FlSpot(i.toDouble(), val));
      if (val > maxY) maxY = val;
    }
    if (maxY == 0) maxY = 1000;
    if (spots.isEmpty) spots.add(const FlSpot(0, 0));

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalSpent = txs.fold(0.0, (sum, t) => sum + t.amount);

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
          Text('Total Spent', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('₹${totalSpent.toStringAsFixed(0)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                maxY: maxY * 1.2,
                minY: 0,
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (group) => isDark ? Colors.white : Colors.black87,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '₹${spot.y.round()}',
                          TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4 > 0 ? maxY / 4 : 1,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withValues(alpha: 0.1), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= labels.length) return const SizedBox();
                        if (labels.length > 7 && index % (labels.length ~/ 5) != 0 && index != labels.length - 1) return const SizedBox();
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
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Theme.of(context).primaryColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: spots.length < 15),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartInsights(List<GlobalTransaction> txs, List<GlobalTransaction> allTxs) {
    if (txs.isEmpty) return const SizedBox();
    
    final sums = _getCategorySums(txs);
    String topCat = sums.isNotEmpty ? sums.first.key : 'None';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lightbulb, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Smart Insight', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    'Your highest spending category this period is $topCat. Consider setting a stricter budget to optimize savings.',
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

  Widget _buildCategoryCard(
    MapEntry<String, double> entry, 
    List<GlobalTransaction> currentPeriodTxs, 
    FinanceProvider finance,
    BudgetProvider budget
  ) {
    final catName = entry.key;
    final catAmount = entry.value;
    final totalAmount = currentPeriodTxs.fold(0.0, (sum, t) => sum + t.amount);
    final percentage = totalAmount > 0 ? (catAmount / totalAmount) * 100 : 0;
    
    final catTxs = currentPeriodTxs.where((t) => t.category == catName).toList();
    
    String emoji = '📦';
    Color color = Colors.grey;
    try {
      final c = finance.categories.firstWhere((c) => c.name == catName);
      emoji = c.emoji;
      color = c.color;
    } catch (_) {}

    double? budgetLimit;
    LimitPeriod period = LimitPeriod.monthly;
    if (_selectedFilter == TimeFilter.thisWeek) period = LimitPeriod.weekly;
    if (_selectedFilter == TimeFilter.thisYear) period = LimitPeriod.yearly;

    try {
      final lim = budget.budget.categoryLimits.cast<CategoryLimit?>().firstWhere((l) => l?.category == catName && l?.period == period, orElse: () => null);
      if (lim != null && lim.limitAmount > 0) {
        budgetLimit = lim.limitAmount;
      }
    } catch (_) {}

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => CategoryAnalyticsScreen(
            categoryName: catName,
            categoryEmoji: emoji,
            categoryColor: color,
            transactions: catTxs,
            timeFilter: _selectedFilter,
            dateRange: _customDateRange,
            budgetLimit: budgetLimit,
          )
        ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Text(emoji, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(catName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('${catTxs.length} transactions', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₹${catAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('${percentage.toStringAsFixed(1)}%', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ],
            ),
            if (budgetLimit != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Budget: ₹${budgetLimit.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  Text(
                    catAmount > budgetLimit ? 'Over Budget by ₹${(catAmount - budgetLimit).toStringAsFixed(0)}' : '₹${(budgetLimit - catAmount).toStringAsFixed(0)} left',
                    style: TextStyle(
                      color: catAmount > budgetLimit ? Colors.redAccent : Colors.grey[500], 
                      fontSize: 12,
                      fontWeight: catAmount > budgetLimit ? FontWeight.bold : FontWeight.normal
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: (catAmount / budgetLimit).clamp(0.0, 1.0),
                backgroundColor: color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(catAmount > budgetLimit ? Colors.redAccent : color),
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
