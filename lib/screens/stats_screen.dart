import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../widgets/common/custom_tab_bar.dart';
import '../providers/finance_provider.dart';
import '../models/transaction.dart';

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

  String _getCategoryEmoji(String category) {
    final Map<String, String> map = {
      'Food & Drink': '🍔', 'Groceries': '🛒', 'Rent': '🏠', 'Transport': '🚕',
      'Shopping': '🛍️', 'Entertainment': '🎬', 'Health': '💊', 'Bills': '📄',
      'Invest': '📈', 'Income': '💰', 'Other': '📦'
    };
    return map[category] ?? '📦';
  }

  Color _getCategoryColor(String category) {
    final Map<String, Color> map = {
      'Food & Drink': Colors.orange, 'Groceries': Colors.green, 'Rent': Colors.blue, 'Transport': Colors.purple,
      'Shopping': Colors.pink, 'Entertainment': Colors.red, 'Health': Colors.teal, 'Bills': Colors.amber,
      'Invest': Colors.indigo, 'Income': Colors.lightGreen, 'Other': Colors.grey
    };
    return map[category] ?? Colors.grey;
  }

  List<TransactionModel> _getFilteredTransactions(List<TransactionModel> allTransactions) {
    final now = DateTime.now();
    return allTransactions.where((t) {
      if (t.type != TransactionType.expense) return false;
      if (_tabController.index == 0) {
        return t.date.isAfter(now.subtract(const Duration(days: 7)));
      } else if (_tabController.index == 1) {
        return t.date.year == now.year && t.date.month == now.month;
      } else {
        return t.date.year == now.year;
      }
    }).toList();
  }

  Map<String, dynamic> _getChartData(List<TransactionModel> txs) {
    final now = DateTime.now();
    List<double> barValues = [];
    List<String> barLabels = [];
    List<List<TransactionModel>> barTransactions = [];

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

  List<Map<String, dynamic>> _getTopCategories(List<TransactionModel> txs) {
    final Map<String, double> catSums = {};
    for (var t in txs) {
      catSums[t.category] = (catSums[t.category] ?? 0) + t.amount;
    }
    
    final sorted = catSums.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(4).toList();
    
    final totalSpent = txs.fold(0.0, (sum, t) => sum + t.amount);
    
    return top.map((e) {
      return {
        'name': e.key,
        'emoji': _getCategoryEmoji(e.key),
        'amount': e.value,
        'percentage': totalSpent > 0 ? (e.value / totalSpent) : 0.0,
        'transactions': txs.where((t) => t.category == e.key).toList(),
      };
    }).toList();
  }

  void _showTransactionsModal(BuildContext context, String title, double totalAmount, List<TransactionModel> txs) {
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
    final provider = Provider.of<FinanceProvider>(context);
    
    final filteredTxs = _getFilteredTransactions(provider.transactions);
    final totalSpent = filteredTxs.fold(0.0, (sum, t) => sum + t.amount);
    final chartData = _getChartData(filteredTxs);
    final topCategories = _getTopCategories(filteredTxs);
    
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                        c['percentage'] as double,
                        c['transactions'] as List<TransactionModel>,
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
    final transactions = chartData['transactions'] as List<List<TransactionModel>>;
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

  Widget _buildCategoryRow(String name, String emoji, double amount, double percentage, List<TransactionModel> txs, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () => _showTransactionsModal(context, '$emoji $name', amount, txs),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161618) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Stack(
                    children: [
                      Container(
                        height: 6,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade200,
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
            Text('₹${amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
