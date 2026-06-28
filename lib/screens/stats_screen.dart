import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../widgets/common/custom_tab_bar.dart';
import '../providers/finance_provider.dart';
import '../providers/ledger_provider.dart';
import '../providers/budget_provider.dart';
import '../models/global_transaction.dart';
import '../widgets/common/custom_bottom_sheet.dart';
import '../models/budget.dart';
import 'category_analytics_screen.dart';
import 'spending_analytics_screen.dart'; // for TimeFilter


class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getCategoryEmoji(String categoryName) {
    final categories = Provider.of<FinanceProvider>(context, listen: false).categories;
    try {
      return categories.firstWhere((c) => c.name == categoryName).emoji;
    } catch (e) {
      return '??';
    }
  }

  Color _getCategoryColor(String categoryName) {
    final categories = Provider.of<FinanceProvider>(context, listen: false).categories;
    try {
      return categories.firstWhere((c) => c.name == categoryName).color;
    } catch (e) {
      return Colors.grey;
    }
  }

  List<GlobalTransaction> _getFilteredTransactions(List<GlobalTransaction> allTransactions) {
    final now = DateTime.now();
    return allTransactions.where((t) {
      if (t.type != GlobalTransactionType.expense) return false;
      if (_tabController.index == 0) {
        return t.date.isAfter(now.subtract(const Duration(days: 7)));
      } else if (_tabController.index == 1) {
        return t.date.year == now.year && t.date.month == now.month;
      } else {
        return t.date.year == now.year;
      }
    }).toList();
  }



  Map<String, dynamic> _getChartData(List<GlobalTransaction> txs) {
    final now = DateTime.now();
    List<double> barValues = [];
    List<String> barLabels = [];
    List<List<GlobalTransaction>> barTransactions = [];

    if (_tabController.index == 0) {
      for (int i = 6; i >= 0; i--) {
        final d = now.subtract(Duration(days: i));
        barLabels.add(DateFormat('E').format(d));
        final dayTxs = txs.where((t) => t.date.year == d.year && t.date.month == d.month && t.date.day == d.day).toList();
        barTransactions.add(dayTxs);
        barValues.add(dayTxs.fold(0.0, (sum, t) => sum + t.amount));
      }
    } else if (_tabController.index == 1) {
      for (int i = 0; i < 5; i++) {
        barLabels.add('W${i+1}');
        final wTxs = txs.where((t) {
          int w = ((t.date.day - 1) / 7).floor();
          if (w > 4) w = 4;
          return w == i;
        }).toList();
        barTransactions.add(wTxs);
        barValues.add(wTxs.fold(0.0, (sum, t) => sum + t.amount));
      }
    } else {
      for (int i = 1; i <= 12; i++) {
        barLabels.add(DateFormat('MMM').format(DateTime(now.year, i, 1)));
        final mTxs = txs.where((t) => t.date.month == i).toList();
        barTransactions.add(mTxs);
        barValues.add(mTxs.fold(0.0, (sum, t) => sum + t.amount));
      }
    }

    double maxY = barValues.isEmpty ? 1000 : barValues.reduce((a, b) => a > b ? a : b);
    if (maxY == 0) maxY = 1000;

    return {
      'values': barValues,
      'labels': barLabels,
      'transactions': barTransactions,
      'maxY': maxY * 1.2,
    };
  }

  List<FlSpot> _getTrendSpots(List<GlobalTransaction> txs) {
    final now = DateTime.now();
    if (_tabController.index == 0) {
      return List.generate(7, (i) {
        final d = now.subtract(Duration(days: 6 - i));
        final total = txs
            .where((t) => t.date.year == d.year && t.date.month == d.month && t.date.day == d.day)
            .fold(0.0, (sum, t) => sum + t.amount);
        return FlSpot(i.toDouble(), total);
      });
    } else if (_tabController.index == 1) {
      return List.generate(5, (i) {
        final total = txs.where((t) {
          int w = ((t.date.day - 1) / 7).floor();
          if (w > 4) w = 4;
          return w == i;
        }).fold(0.0, (sum, t) => sum + t.amount);
        return FlSpot(i.toDouble(), total);
      });
    } else {
      return List.generate(12, (i) {
        final total = txs.where((t) => t.date.month == i + 1).fold(0.0, (sum, t) => sum + t.amount);
        return FlSpot(i.toDouble(), total);
      });
    }
  }

  List<Map<String, dynamic>> _getAllCategories(List<GlobalTransaction> txs, BuildContext context) {
    final Map<String, double> catSums = {};
    final Map<String, int> catCounts = {};
    for (var t in txs) {
      catSums[t.category] = (catSums[t.category] ?? 0) + t.amount;
      catCounts[t.category] = (catCounts[t.category] ?? 0) + 1;
    }

    final sorted = catSums.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    LimitPeriod period = _tabController.index == 0
        ? LimitPeriod.weekly
        : (_tabController.index == 1 ? LimitPeriod.monthly : LimitPeriod.yearly);

    final totalSpent = catSums.values.fold(0.0, (a, b) => a + b);

    return sorted.map((e) {
      final catLimit = budgetProvider.budget.categoryLimits.cast<CategoryLimit?>().firstWhere(
        (l) => l?.category == e.key && l?.period == period,
        orElse: () => budgetProvider.budget.categoryLimits.cast<CategoryLimit?>().firstWhere(
          (l) => l?.category == e.key,
          orElse: () => null,
        ),
      );
      final limitAmount = catLimit?.limitAmount ?? 0.0;
      final progressPercentage = limitAmount > 0 ? (e.value / limitAmount).clamp(0.0, 2.0) : 0.0;
      final percentOfTotal = totalSpent > 0 ? e.value / totalSpent : 0.0;

      return {
        'name': e.key,
        'emoji': _getCategoryEmoji(e.key),
        'amount': e.value,
        'limit': limitAmount,
        'percentage': progressPercentage,
        'percentOfTotal': percentOfTotal,
        'count': catCounts[e.key] ?? 0,
        'transactions': txs.where((t) => t.category == e.key).toList(),
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ledgerProvider = Provider.of<LedgerProvider>(context);

    final allTxs = ledgerProvider.transactions;
    final filteredTxs = _getFilteredTransactions(allTxs);
    final totalSpent = filteredTxs.fold(0.0, (sum, t) => sum + t.amount);
    final chartData = _getChartData(filteredTxs);
    final allCategories = _getAllCategories(filteredTxs, context);
    final trendSpots = _getTrendSpots(filteredTxs);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Analytics', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),

                ],
              ),
            ),
            CustomTabBar(
              controller: _tabController,
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              tabs: const [
                Tab(text: 'Weekly'),
                Tab(text: 'Monthly'),
                Tab(text: 'Yearly'),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  children: [
                    const Text('Total Spent', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                      '₹${totalSpent.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: -1),
                    ),

                    const SizedBox(height: 28),
                    SizedBox(
                      height: 230,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildBarChart(isDark, chartData),
                      ),
                    ),
                    const SizedBox(height: 32),


                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Spending by Category',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          if (filteredTxs.isNotEmpty)
                            IconButton(
                              icon: Icon(Icons.trending_up, color: Theme.of(context).primaryColor, size: 22),
                              onPressed: () => _showTrendSheet(isDark, trendSpots, chartData['labels'] as List<String>),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: 'View Trend',
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (allCategories.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: Text('No spending data for this period.', style: TextStyle(color: Colors.grey))),
                      )
                    else
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Column(
                            children: [
                              for (int i = 0; i < allCategories.length; i++) ...[
                                _buildCategoryRow(
                                  allCategories[i]['name'] as String,
                                  allCategories[i]['emoji'] as String,
                                  allCategories[i]['amount'] as double,
                                  allCategories[i]['limit'] as double,
                                  allCategories[i]['percentage'] as double,
                                  allCategories[i]['percentOfTotal'] as double,
                                  allCategories[i]['count'] as int,
                                  allCategories[i]['transactions'] as List<GlobalTransaction>,
                                  context,
                                  isDark,
                                ),
                                if (i < allCategories.length - 1)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 80, right: 24),
                                    child: Divider(height: 1, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  void _showTrendSheet(bool isDark, List<FlSpot> spots, List<String> labels) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomBottomSheet(
        title: 'Spending Trend',
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _buildTrendLineChart(isDark, spots, labels),
        ),
      ),
    );
  }

  Widget _buildTrendLineChart(bool isDark, List<FlSpot> spots, List<String> labels) {
    final maxY = spots.isEmpty ? 1000.0 : spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.3;
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY == 0 ? 1000 : maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 3 > 0 ? maxY / 3 : 1,
                  getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey.withValues(alpha: 0.12), strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: labels.length > 6 ? (labels.length / 4).ceilToDouble() : 1,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= labels.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(labels[i],
                              style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => isDark ? Colors.white : Colors.black87,
                    getTooltipItems: (touchedSpots) => touchedSpots
                        .map((s) => LineTooltipItem(
                              '₹${s.y.round()}',
                              TextStyle(
                                  color: isDark ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ))
                        .toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: Theme.of(context).primaryColor,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, pct, bar, idx) => FlDotCirclePainter(
                        radius: 3,
                        color: Theme.of(context).primaryColor,
                        strokeWidth: 1.5,
                        strokeColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor.withValues(alpha: 0.18),
                          Theme.of(context).primaryColor.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
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



  Widget _buildBarChart(bool isDark, Map<String, dynamic> chartData) {
    final values = chartData['values'] as List<double>;
    final labels = chartData['labels'] as List<String>;
    final transactions = chartData['transactions'] as List<List<GlobalTransaction>>;
    final maxY = chartData['maxY'] as double;

    int maxIndex = 0;
    for (int i = 0; i < values.length; i++) {
      if (values[i] > values[maxIndex]) maxIndex = i;
    }
    if (values.isEmpty || values[maxIndex] == 0) maxIndex = -1;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          handleBuiltInTouches: false,
          touchCallback: (FlTouchEvent event, barTouchResponse) {
            if (event is FlTapUpEvent && barTouchResponse != null && barTouchResponse.spot != null) {
              final index = barTouchResponse.spot!.touchedBarGroupIndex;
              _showTransactionsModal(context, labels[index], values[index], transactions[index]);
            }
          },
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Colors.transparent,
            tooltipPadding: EdgeInsets.zero,
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (rod.toY == 0) return null;
              final isActive = groupIndex == maxIndex;
              return BarTooltipItem(
                '₹${rod.toY.round()}',
                TextStyle(
                  color: isActive ? (Theme.of(context).primaryColor) : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= labels.length) return const SizedBox();
                final isActive = index == maxIndex;
                final style = TextStyle(
                  color: isActive ? (Theme.of(context).primaryColor) : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                );
                return SideTitleWidget(meta: meta, space: 8, child: Text(labels[index], style: style));
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(values.length, (index) {
          return _buildBarGroup(index, values[index], index == maxIndex, isDark, values.length > 7 ? 16 : 28);
        }),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, bool isActive, bool isDark, double width) {
    return BarChartGroupData(
      x: x,
      showingTooltipIndicators: y > 0 ? [0] : [],
      barRods: [
        BarChartRodData(
          toY: y,
          color: isActive ? Theme.of(context).primaryColor : (isDark ? const Color(0xFF2A2D34) : Colors.grey.shade300),
          width: width,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
        ),
      ],
    );
  }

  void _showTransactionsModal(BuildContext context, String title, double totalAmount, List<GlobalTransaction> txs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CustomBottomSheet(
        title: title,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total: ₹${totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 16),
            if (txs.isEmpty)
              const Padding(padding: EdgeInsets.all(16), child: Center(child: Text('No transactions', style: TextStyle(color: Colors.grey))))
            else
              ...txs.map((t) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: _getCategoryColor(t.category).withValues(alpha: 0.1),
                      child: Text(_getCategoryEmoji(t.category), style: const TextStyle(fontSize: 20)),
                    ),
                    title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(DateFormat('MMM dd, yyyy').format(t.date),
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    trailing: Text('₹${t.amount.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow(
    String name,
    String emoji,
    double amount,
    double limit,
    double percentage,
    double percentOfTotal,
    int count,
    List<GlobalTransaction> txs,
    BuildContext context,
    bool isDark,
  ) {
    TimeFilter filter = TimeFilter.thisWeek;
    if (_tabController.index == 1) filter = TimeFilter.thisMonth;
    if (_tabController.index == 2) filter = TimeFilter.thisYear;

    final isOverBudget = limit > 0 && amount > limit;
    final barColor = isOverBudget ? Colors.redAccent : Theme.of(context).primaryColor;

    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => CategoryAnalyticsScreen(
                      categoryName: name,
                      categoryEmoji: emoji,
                      categoryColor: _getCategoryColor(name),
                      transactions: txs,
                      timeFilter: filter,
                      budgetLimit: limit > 0 ? limit : null,
                    )));
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? Colors.black : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            overflow: TextOverflow.ellipsis),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isOverBudget)
                            Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('Over',
                                  style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          Text('${((limit > 0 ? percentage : percentOfTotal) * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('$count transaction${count == 1 ? '' : 's'}',
                      style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      Container(
                        height: 5,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A2D34) : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      Container(
                        height: 5,
                        width: MediaQuery.of(context).size.width * 0.48 * (limit > 0 ? percentage : percentOfTotal).clamp(0.0, 1.0),
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹${amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text('/ ₹${limit.toStringAsFixed(0)}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
