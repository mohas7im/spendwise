import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../widgets/common/custom_tab_bar.dart';
import '../providers/finance_provider.dart';
import '../providers/ledger_provider.dart';
import '../providers/budget_provider.dart';
import '../models/global_transaction.dart';
import 'category_analytics_screen.dart';
import 'spending_analytics_screen.dart'; // for TimeFilter
import '../models/budget.dart';

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
      return '📦';
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

  List<Map<String, dynamic>> _getTopCategories(List<GlobalTransaction> txs, BuildContext context) {
    final Map<String, double> catSums = {};
    for (var t in txs) {
      catSums[t.category] = (catSums[t.category] ?? 0) + t.amount;
    }
    
    final sorted = catSums.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(4).toList();
    
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    LimitPeriod period = _tabController.index == 0 
        ? LimitPeriod.weekly 
        : (_tabController.index == 1 ? LimitPeriod.monthly : LimitPeriod.yearly);
    
    return top.map((e) {
      final catLimit = budgetProvider.budget.categoryLimits.cast<CategoryLimit?>().firstWhere(
        (l) => l?.category == e.key && l?.period == period,
        orElse: () => null,
      );
      final limitAmount = catLimit?.limitAmount ?? 0.0;
      final progressPercentage = limitAmount > 0 ? (e.value / limitAmount).clamp(0.0, 1.0) : 0.0;

      return {
        'name': e.key,
        'emoji': _getCategoryEmoji(e.key),
        'amount': e.value,
        'limit': limitAmount,
        'percentage': progressPercentage,
        'transactions': txs.where((t) => t.category == e.key).toList(),
      };
    }).toList();
  }

  void _showTransactionsModal(BuildContext context, String title, double totalAmount, List<GlobalTransaction> txs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 24, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Total: ₹${totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 24),
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
                subtitle: Text(DateFormat('MMM dd, yyyy').format(t.date), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                trailing: Text('₹${t.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ledgerProvider = Provider.of<LedgerProvider>(context);
    
    final filteredTxs = _getFilteredTransactions(ledgerProvider.transactions);
    final totalSpent = filteredTxs.fold(0.0, (sum, t) => sum + t.amount);
    final chartData = _getChartData(filteredTxs);
    final topCategories = _getTopCategories(filteredTxs, context);
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Text('Analytics', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
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
                    Text('₹${totalSpent.toStringAsFixed(0)}', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: -1)),
                    const SizedBox(height: 32),

                    SizedBox(
                      height: 250,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildBarChart(isDark, chartData),
                      ),
                    ),
                    const SizedBox(height: 32),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Text('Top Spending', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    if (topCategories.isEmpty)
                      const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('No spending data for this period.', style: TextStyle(color: Colors.grey))))
                    else
                      ...topCategories.map((c) => _buildCategoryRow(
                        c['name'] as String, 
                        c['emoji'] as String, 
                        c['amount'] as double, 
                        c['limit'] as double,
                        c['percentage'] as double,
                        c['transactions'] as List<GlobalTransaction>,
                        context
                      )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(bool isDark, Map<String, dynamic> chartData) {
    final values = chartData['values'] as List<double>;
    final labels = chartData['labels'] as List<String>;
    final transactions = chartData['transactions'] as List<List<GlobalTransaction>>;
    final maxY = chartData['maxY'] as double;
    
    // Find index with max value for highlighting
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
          color: isActive ? Colors.red.shade900 : (isDark ? const Color(0xFF2A2D34) : Colors.grey.shade300),
          width: width,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryRow(String name, String emoji, double amount, double limit, double percentage, List<GlobalTransaction> txs, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    TimeFilter filter = TimeFilter.thisWeek;
    if (_tabController.index == 1) filter = TimeFilter.thisMonth;
    if (_tabController.index == 2) filter = TimeFilter.thisYear;

    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => CategoryAnalyticsScreen(
            categoryName: name,
            categoryEmoji: emoji,
            categoryColor: _getCategoryColor(name),
            transactions: txs,
            timeFilter: filter,
            budgetLimit: limit > 0 ? limit : null,
          )
        ));
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? Colors.black : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      if (limit > 0)
                        Text('${(percentage * 100).toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Stack(
                    children: [
                      Container(
                        height: 6,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      Container(
                        height: 6,
                        width: MediaQuery.of(context).size.width * 0.5 * percentage,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹${amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (limit > 0)
                  Text('/ ₹${limit.toStringAsFixed(0)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
