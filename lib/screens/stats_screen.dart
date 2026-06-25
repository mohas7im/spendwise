import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../widgets/common/custom_tab_bar.dart';

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Text('Analytics', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            ),

            // Tab Bar
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
                    // Total Spent
                    const Text('Total Spent', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 4),
                    const Text('₹18,450', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: -1)),
                    const SizedBox(height: 32),

                    // Bar Chart
                    SizedBox(
                      height: 250,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildBarChart(isDark),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Top Categories
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Text('Top Spending', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildCategoryRow('Food & Dining', '🍔', 4500, 0.45, context),
                    _buildCategoryRow('Shopping', '🛍️', 3200, 0.32, context),
                    _buildCategoryRow('Transport', '🚕', 1800, 0.18, context),
                    _buildCategoryRow('Bills', '📄', 1200, 0.12, context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(bool isDark) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 20000,
        barTouchData: BarTouchData(
          enabled: false,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Colors.transparent,
            tooltipPadding: EdgeInsets.zero,
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final isActive = groupIndex == 3; // Match the highest value
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
                final isActive = value.toInt() == 3; // Hardcoding index 3 (Wed) or max value index as active
                final style = TextStyle(
                  color: isActive ? (Theme.of(context).primaryColor) : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                );
                String text;
                switch (value.toInt()) {
                  case 0: text = 'Sun'; break;
                  case 1: text = 'Mon'; break;
                  case 2: text = 'Tue'; break;
                  case 3: text = 'Wed'; break;
                  case 4: text = 'Thu'; break;
                  case 5: text = 'Fri'; break;
                  case 6: text = 'Sat'; break;
                  default: text = ''; break;
                }
                return SideTitleWidget(meta: meta, space: 8, child: Text(text, style: style));
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          _buildBarGroup(0, 12000, isDark),
          _buildBarGroup(1, 8000, isDark),
          _buildBarGroup(2, 15000, isDark),
          _buildBarGroup(3, 18000, isDark),
          _buildBarGroup(4, 9000, isDark),
          _buildBarGroup(5, 11000, isDark),
          _buildBarGroup(6, 16000, isDark),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, bool isDark) {
    final isActive = x == 3; // Making the highest value (index 3) active
    return BarChartGroupData(
      x: x,
      showingTooltipIndicators: [0], // Always show tooltip for the first rod
      barRods: [
        BarChartRodData(
          toY: y,
          color: isActive ? Colors.red.shade900 : (isDark ? const Color(0xFF2A2D34) : Colors.grey.shade300),
          width: 28,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
          backDrawRodData: BackgroundBarChartRodData(show: false),
        ),
      ],
    );
  }

  Widget _buildCategoryRow(String name, String emoji, double amount, double percent, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
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
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('₹${amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 6,
                    backgroundColor: Theme.of(context).cardColor,
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
