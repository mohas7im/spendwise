import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/global_transaction.dart';
import 'spending_analytics_screen.dart'; // for TimeFilter

class CategoryAnalyticsScreen extends StatefulWidget {
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
  State<CategoryAnalyticsScreen> createState() => _CategoryAnalyticsScreenState();
}

class _CategoryAnalyticsScreenState extends State<CategoryAnalyticsScreen> {
  String _searchQuery = '';
  String _sortMode = 'newest'; // newest, oldest, highest, lowest
  final TextEditingController _searchCtrl = TextEditingController();
  int _chartPage = 0;
  final PageController _pageCtrl = PageController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  List<GlobalTransaction> get _sorted {
    var list = widget.transactions
        .where((t) => t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            t.notes.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
    switch (_sortMode) {
      case 'newest':
        list.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'oldest':
        list.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'highest':
        list.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'lowest':
        list.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sortedTxs = widget.transactions.toList()..sort((a, b) => b.date.compareTo(a.date));
    final totalSpent = sortedTxs.fold(0.0, (s, t) => s + t.amount);
    final avgTx = sortedTxs.isEmpty ? 0.0 : totalSpent / sortedTxs.length;
    final highestTx = sortedTxs.isEmpty ? 0.0 : sortedTxs.map((t) => t.amount).reduce((a, b) => a > b ? a : b);
    final lowestTx = sortedTxs.isEmpty ? 0.0 : sortedTxs.map((t) => t.amount).reduce((a, b) => a < b ? a : b);

    // Analytics
    final Map<String, double> dayMap = {};
    for (var t in sortedTxs) {
      final key = DateFormat('EEE, MMM d').format(t.date);
      dayMap[key] = (dayMap[key] ?? 0) + t.amount;
    }
    String? highestDay;
    String? lowestDay;
    if (dayMap.isNotEmpty) {
      highestDay = dayMap.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      lowestDay = dayMap.entries.reduce((a, b) => a.value < b.value ? a : b).key;
    }
    final dailyAvg = dayMap.isEmpty ? 0.0 : totalSpent / dayMap.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.categoryEmoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(widget.categoryName, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: sortedTxs.isEmpty
          ? const Center(child: Text('No transactions in this period.', style: TextStyle(color: Colors.grey)))
          : CustomScrollView(
              slivers: [
                // Summary 4-card grid
                SliverToBoxAdapter(
                  child: _buildSummaryGrid(context, isDark, totalSpent, avgTx, highestTx, sortedTxs.length),
                ),

                // Chart PageView with dots
                SliverToBoxAdapter(
                  child: _buildChartSection(context, isDark, sortedTxs, totalSpent),
                ),

                // Category Insights
                SliverToBoxAdapter(
                  child: _buildCategoryInsights(context, isDark, sortedTxs, highestDay, lowestDay, dailyAvg, highestTx, lowestTx),
                ),

                // Budget card
                if (widget.budgetLimit != null)
                  SliverToBoxAdapter(
                    child: _buildBudgetCard(context, isDark, totalSpent),
                  ),

                // Transactions header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Transactions', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            _buildSortDropdown(isDark),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Search bar
                        Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: (v) => setState(() => _searchQuery = v),
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Search transactions...',
                              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                              prefixIcon: const Icon(Icons.search, size: 18, color: Colors.grey),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 16, color: Colors.grey),
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Transaction list
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final list = _sorted;
                      if (index >= list.length) return null;
                      return _buildTransactionTile(context, isDark, list[index]);
                    },
                    childCount: _sorted.length,
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
    );
  }

  Widget _buildSummaryGrid(BuildContext context, bool isDark, double total, double avg, double highest, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _metricCard(context, isDark, 'Total Spent', '?${total.toStringAsFixed(0)}', widget.categoryColor)),
              const SizedBox(width: 12),
              Expanded(child: _metricCard(context, isDark, 'Average', '?${avg.toStringAsFixed(0)}', Colors.blueAccent)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _metricCard(context, isDark, 'Highest', '?${highest.toStringAsFixed(0)}', Colors.orange)),
              const SizedBox(width: 12),
              Expanded(child: _metricCard(context, isDark, 'Transactions', '$count', Colors.purple)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricCard(BuildContext context, bool isDark, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildChartSection(BuildContext context, bool isDark, List<GlobalTransaction> txs, double totalSpent) {
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final chartTitles = ['Trend', 'Bar', 'By Method'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // Chart tab row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: List.generate(3, (i) {
                final active = _chartPage == i;
                return GestureDetector(
                  onTap: () {
                    _pageCtrl.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    setState(() => _chartPage = i);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: active ? widget.categoryColor.withValues(alpha: 0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: active ? widget.categoryColor : Colors.grey.withValues(alpha: 0.3)),
                    ),
                    child: Text(chartTitles[i],
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: active ? widget.categoryColor : Colors.grey)),
                  ),
                );
              }),
            ),
          ),
          SizedBox(
            height: 200,
            child: PageView(
              controller: _pageCtrl,
              onPageChanged: (i) => setState(() => _chartPage = i),
              children: [
                Padding(padding: const EdgeInsets.all(16), child: _buildLineChart(isDark, txs)),
                Padding(padding: const EdgeInsets.all(16), child: _buildBarChartCategory(isDark, txs)),
                Padding(padding: const EdgeInsets.all(16), child: _buildPieChart(isDark, txs, totalSpent)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(bool isDark, List<GlobalTransaction> txs) {
    final sorted = List<GlobalTransaction>.from(txs)..sort((a, b) => a.date.compareTo(b.date));
    final Map<String, double> grouped = {};
    for (var t in sorted) {
      final key = DateFormat('MMM d').format(t.date);
      grouped[key] = (grouped[key] ?? 0) + t.amount;
    }
    final keys = grouped.keys.toList();
    final spots = List.generate(keys.length, (i) => FlSpot(i.toDouble(), grouped[keys[i]]!));
    final maxY = spots.isEmpty ? 1000.0 : spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.3;

    return LineChart(LineChartData(
      minY: 0,
      maxY: maxY == 0 ? 1000 : maxY,
      gridData: FlGridData(show: true, drawVerticalLine: false,
          getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey.withValues(alpha: 0.1), strokeWidth: 1)),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: keys.length > 5 ? (keys.length / 3).ceilToDouble() : 1,
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i < 0 || i >= keys.length) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(keys[i], style: const TextStyle(color: Colors.grey, fontSize: 9)),
              );
            },
          ),
        ),
      ),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => isDark ? Colors.white : Colors.black87,
          getTooltipItems: (s) => s.map((spot) => LineTooltipItem(
            '?${spot.y.round()}',
            TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
          )).toList(),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: widget.categoryColor,
          barWidth: 2.5,
          dotData: FlDotData(
            show: true,
            getDotPainter: (_, _, _, _) => FlDotCirclePainter(radius: 3, color: widget.categoryColor, strokeWidth: 0),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [widget.categoryColor.withValues(alpha: 0.2), widget.categoryColor.withValues(alpha: 0.0)],
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    ));
  }

  Widget _buildBarChartCategory(bool isDark, List<GlobalTransaction> txs) {
    final Map<String, double> grouped = {};
    for (var t in txs) {
      final key = DateFormat('MMM d').format(t.date);
      grouped[key] = (grouped[key] ?? 0) + t.amount;
    }
    final keys = grouped.keys.toList();
    final vals = keys.map((k) => grouped[k]!).toList();
    final maxY = vals.isEmpty ? 1000.0 : vals.reduce((a, b) => a > b ? a : b) * 1.3;

    return BarChart(BarChartData(
      maxY: maxY == 0 ? 1000 : maxY,
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i < 0 || i >= keys.length) return const SizedBox();
              if (keys.length > 5 && i % (keys.length ~/ 4) != 0 && i != keys.length - 1) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(keys[i], style: const TextStyle(color: Colors.grey, fontSize: 9)),
              );
            },
          ),
        ),
      ),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => isDark ? Colors.white : Colors.black87,
          getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
            '?${rod.toY.round()}',
            TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
          ),
        ),
      ),
      barGroups: List.generate(keys.length, (i) => BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: vals[i],
            color: widget.categoryColor,
            width: keys.length > 10 ? 8 : 14,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      )),
    ));
  }

  Widget _buildPieChart(bool isDark, List<GlobalTransaction> txs, double totalSpent) {
    final Map<String, double> methodMap = {};
    for (var t in txs) {
      final key = t.paymentMethod.isNotEmpty ? t.paymentMethod : 'Other';
      methodMap[key] = (methodMap[key] ?? 0) + t.amount;
    }
    if (methodMap.isEmpty) {
      return const Center(child: Text('No data', style: TextStyle(color: Colors.grey)));
    }
    final colors = [Colors.blueAccent, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.redAccent];
    final entries = methodMap.entries.toList();

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 30,
            sections: List.generate(entries.length, (i) {
              final pct = totalSpent > 0 ? (entries[i].value / totalSpent * 100) : 0.0;
              return PieChartSectionData(
                color: colors[i % colors.length],
                value: entries[i].value,
                title: '${pct.round()}%',
                radius: 50,
                titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
              );
            }),
          )),
        ),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(entries.length, (i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[i % colors.length], shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Flexible(child: Text(entries[i].key, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis)),
                ],
              ),
            )),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryInsights(
    BuildContext context, bool isDark, List<GlobalTransaction> txs,
    String? highestDay, String? lowestDay, double dailyAvg, double highest, double lowest,
  ) {
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Category Insights', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 12),
          _insightRow(Icons.arrow_upward, 'Highest Spending Day', highestDay ?? 'N/A', Colors.redAccent, isDark),
          _insightRow(Icons.arrow_downward, 'Lowest Spending Day', lowestDay ?? 'N/A', Colors.green, isDark),
          _insightRow(Icons.today_outlined, 'Daily Average', '?${dailyAvg.toStringAsFixed(0)}', Colors.orange, isDark),
          _insightRow(Icons.receipt_long, 'Highest Transaction', '?${highest.toStringAsFixed(0)}', Colors.blueAccent, isDark),
          _insightRow(Icons.receipt, 'Lowest Transaction', '?${lowest.toStringAsFixed(0)}', Colors.purple, isDark),
        ],
      ),
    );
  }

  Widget _insightRow(IconData icon, String label, String value, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13))),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(BuildContext context, bool isDark, double totalSpent) {
    final limit = widget.budgetLimit!;
    final over = totalSpent > limit;
    final pct = (totalSpent / limit).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: over ? Colors.redAccent.withValues(alpha: 0.08) : Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: over ? Colors.redAccent.withValues(alpha: 0.3) : Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(over ? Icons.warning_amber_rounded : Icons.check_circle_outline, color: over ? Colors.redAccent : Colors.green),
                  const SizedBox(width: 8),
                  Text(over ? 'Budget Exceeded' : 'Budget On Track',
                      style: TextStyle(fontWeight: FontWeight.bold, color: over ? Colors.redAccent : Colors.green)),
                ],
              ),
              Text('${(pct * 100).round()}%',
                  style: TextStyle(fontWeight: FontWeight.bold, color: over ? Colors.redAccent : Colors.green)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: (over ? Colors.redAccent : Colors.green).withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(over ? Colors.redAccent : Colors.green),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Spent: ?${totalSpent.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
              Text('Budget: ?${limit.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
          if (over)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Over by ?${(totalSpent - limit).toStringAsFixed(0)}',
                style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '?${(limit - totalSpent).toStringAsFixed(0)} remaining',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSortDropdown(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _sortMode,
          isDense: true,
          style: TextStyle(fontSize: 12, color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
          dropdownColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
          items: const [
            DropdownMenuItem(value: 'newest', child: Text('Newest')),
            DropdownMenuItem(value: 'oldest', child: Text('Oldest')),
            DropdownMenuItem(value: 'highest', child: Text('Highest')),
            DropdownMenuItem(value: 'lowest', child: Text('Lowest')),
          ],
          onChanged: (v) => setState(() => _sortMode = v!),
        ),
      ),
    );
  }

  Widget _buildTransactionTile(BuildContext context, bool isDark, GlobalTransaction t) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: widget.categoryColor.withValues(alpha: 0.12),
        child: Icon(Icons.receipt_long, color: widget.categoryColor, size: 18),
      ),
      title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(DateFormat('MMM d, yyyy  hh:mm a').format(t.date), style: const TextStyle(fontSize: 11, color: Colors.grey)),
          if (t.paymentMethod.isNotEmpty)
            Text(t.paymentMethod, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          if (t.notes.isNotEmpty)
            Text(t.notes, style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
      isThreeLine: t.notes.isNotEmpty || t.paymentMethod.isNotEmpty,
      trailing: Text(
        '?${t.amount.toStringAsFixed(0)}',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }
}
