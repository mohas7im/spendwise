import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/budget.dart';
import '../providers/budget_provider.dart';
import '../providers/finance_provider.dart';
import '../widgets/common/premium_gradient_card.dart';
import '../widgets/common/custom_tab_bar.dart';
import 'package:fl_chart/fl_chart.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> with SingleTickerProviderStateMixin {
  LimitPeriod _selectedPeriod = LimitPeriod.monthly;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1); // 1 = monthly
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          if (_tabController.index == 0) {
            _selectedPeriod = LimitPeriod.daily;
          } else if (_tabController.index == 1) {
            _selectedPeriod = LimitPeriod.monthly;
          } else {
            _selectedPeriod = LimitPeriod.yearly;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: Consumer2<BudgetProvider, FinanceProvider>(
        builder: (context, budgetProvider, financeProvider, child) {
          // Dynamically recalculate spending based on actual transactions
          budgetProvider.recalculateSpending(financeProvider.transactions);
          final budget = budgetProvider.budget;

          // Compute Dashboard Metrics — filtered by selected period
          final periodLimits = budget.categoryLimits.where((l) => l.period == _selectedPeriod).toList();
          double totalBudget = periodLimits.fold(0, (sum, l) => sum + l.limitAmount);
          double totalSpent = periodLimits.fold(0, (sum, l) => sum + l.spentAmount);
          double remainingBudget = (totalBudget - totalSpent).clamp(0.0, double.infinity);
          int overBudgetCount = periodLimits.where((l) => l.isOverBudget).length;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Budgets', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () => _showAddLimitSheet(context, budgetProvider),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Limit', style: TextStyle(fontWeight: FontWeight.bold)),
                              style: TextButton.styleFrom(foregroundColor: Theme.of(context).primaryColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Tab Bar for Limits
                  CustomTabBar(
                    controller: _tabController,
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    tabs: const [
                      Tab(text: 'Daily'),
                      Tab(text: 'Monthly'),
                      Tab(text: 'Yearly'),
                    ],
                  ),

                  // Dashboard Summary Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    child: _buildDashboardSummary(totalBudget, totalSpent, remainingBudget),
                  ),

                  if (totalBudget > 0)
                    _buildBudgetVsActualChart(totalBudget, totalSpent, budget, _selectedPeriod, context),

                  // Over Budget Alert Banner
                  if (overBudgetCount > 0)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: GestureDetector(
                        onTap: () => _showOverBudgetSheet(context, budget),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '$overBudgetCount categor${overBudgetCount == 1 ? 'y' : 'ies'} over budget this month',
                                  style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Colors.redAccent, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  _buildCategoryLimitsList(_selectedPeriod, budget),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }

  Widget _buildDashboardSummary(double budget, double spent, double remaining) {
    final periodLabel = _selectedPeriod == LimitPeriod.daily
        ? 'Daily'
        : _selectedPeriod == LimitPeriod.yearly
            ? 'Yearly'
            : 'Monthly';
    return PremiumGradientCard(
      builder: (context, textColor, subTextColor) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total $periodLabel Budget', style: TextStyle(color: subTextColor, fontSize: 13)),
          const SizedBox(height: 6),
          Text('₹ ${budget.toStringAsFixed(0)}', style: TextStyle(color: textColor, fontSize: 38, fontWeight: FontWeight.bold, letterSpacing: -1)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Spent', style: TextStyle(color: subTextColor, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text('₹${spent.toStringAsFixed(0)}', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 17)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Remaining', style: TextStyle(color: subTextColor, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text('₹${remaining.toStringAsFixed(0)}', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 17)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Progress', style: TextStyle(color: subTextColor, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text('${budget > 0 ? ((spent / budget) * 100).toStringAsFixed(0) : 0}%', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 17)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0,
              minHeight: 6,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(
                spent > budget
                    ? Colors.redAccent
                    : (spent / budget) > 0.8
                        ? Colors.orangeAccent
                        : Colors.greenAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOverBudgetSheet(BuildContext context, budget) {
    final overItems = (budget.categoryLimits as List).where((l) => l.isOverBudget).toList();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (ctx, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                    const SizedBox(width: 10),
                    Text('Over Budget Categories', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: overItems.length,
                  itemBuilder: (ctx, i) => _buildDetailedCategoryLimitCard(overItems[i], overItems[i].period),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildCategoryLimitsList(LimitPeriod period, BudgetModel budget) {
    final items = budget.categoryLimits.where((l) => l.period == period).toList();

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_late_outlined, size: 48, color: Colors.grey.withValues(alpha: 0.5)),
              const SizedBox(height: 12),
              Text(
                'No ${period.name} limits set yet.',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    final sorted = [...items]..sort((a, b) => b.spentAmount.compareTo(a.spentAmount));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: sorted.map((limit) => _buildDetailedCategoryLimitCard(limit, period)).toList(),
        ),
      ),
    );

  }

  Widget _buildDetailedCategoryLimitCard(CategoryLimit limit, LimitPeriod period) {
    final pct = (limit.percentUsed).clamp(0.0, 1.0);
    final isOver = limit.isOverBudget;
    final barColor = isOver ? Colors.redAccent : pct > 0.8 ? Colors.orangeAccent : Colors.greenAccent;

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
                child: Text(limit.category, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), overflow: TextOverflow.ellipsis),
              ),
              if (isOver)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.15),
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
              backgroundColor: Colors.grey.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('₹${limit.spentAmount.toStringAsFixed(0)} spent', style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6))),
              Text('of ₹${limit.limitAmount.toStringAsFixed(0)}', style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodInputRow({
    required BuildContext context,
    required String label,
    required String icon,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 48,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  hintText: 'No limit',
                  hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.5), fontSize: 13),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddLimitSheet(BuildContext context, BudgetProvider provider) {
    final presetCategories = [
      {'name': 'Food & Drink', 'emoji': '🍔'},
      {'name': 'Groceries', 'emoji': '🛒'},
      {'name': 'Rent', 'emoji': '🏠'},
      {'name': 'Transport', 'emoji': '🚕'},
      {'name': 'Shopping', 'emoji': '🛍️'},
      {'name': 'Entertainment', 'emoji': '🎬'},
      {'name': 'Health', 'emoji': '💊'},
      {'name': 'Bills', 'emoji': '📄'},
      {'name': 'Invest', 'emoji': '📈'},
      {'name': 'Other', 'emoji': '📦'},
    ];

    Map<String, String>? selectedPreset = presetCategories.first;
    bool isCustomCategory = false;

    final categoryController = TextEditingController(text: presetCategories.first['name']);
    final emojiController = TextEditingController(text: presetCategories.first['emoji']);

    final dailyController = TextEditingController();
    final monthlyController = TextEditingController();
    final yearlyController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;
          return AnimatedPadding(
            padding: EdgeInsets.only(bottom: bottomInset),
            duration: const Duration(milliseconds: 250),
            curve: Curves.fastOutSlowIn,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.fastOutSlowIn,
              height: (MediaQuery.of(context).size.height * 0.92 - bottomInset).clamp(300.0, double.infinity),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
                        Text('Add Category Limits', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                        TextButton(
                          onPressed: () {
                            final category = categoryController.text.trim();
                            final emoji = emojiController.text.isNotEmpty ? emojiController.text.trim() : '🔹';

                            if (category.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a category name')));
                              return;
                            }

                            final newLimits = <CategoryLimit>[];
                            void tryAddLimit(String text, LimitPeriod period) {
                              final val = double.tryParse(text) ?? 0.0;
                              if (val > 0) {
                                newLimits.add(CategoryLimit(category: category, emoji: emoji, limitAmount: val, period: period, spentAmount: 0.0));
                              }
                            }

                            tryAddLimit(dailyController.text, LimitPeriod.daily);
                            tryAddLimit(monthlyController.text, LimitPeriod.monthly);
                            tryAddLimit(yearlyController.text, LimitPeriod.yearly);

                            if (newLimits.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please specify at least one limit amount')));
                              return;
                            }
                            for (var limit in newLimits) { provider.addCategoryLimit(limit); }
                            Navigator.pop(ctx);
                          },
                          child: Text('Save', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          DropdownButtonFormField<Map<String, String>?>(
                            initialValue: isCustomCategory ? null : selectedPreset,
                            decoration: InputDecoration(labelText: 'Category', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                            items: [
                              ...presetCategories.map((cat) => DropdownMenuItem<Map<String, String>?>(
                                value: cat,
                                child: Row(children: [Text(cat['emoji']!, style: const TextStyle(fontSize: 18)), const SizedBox(width: 8), Text(cat['name']!)]),
                              )),
                              const DropdownMenuItem<Map<String, String>?>(
                                value: null,
                                child: Row(children: [Text('➕', style: TextStyle(fontSize: 18)), SizedBox(width: 8), Text('Custom Category...')]),
                              ),
                            ],
                            onChanged: (val) {
                              setModalState(() {
                                if (val == null) {
                                  isCustomCategory = true;
                                  categoryController.clear();
                                  emojiController.clear();
                                } else {
                                  isCustomCategory = false;
                                  selectedPreset = val;
                                  categoryController.text = val['name']!;
                                  emojiController.text = val['emoji']!;
                                }
                              });
                            },
                          ),
                          if (isCustomCategory) ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(flex: 1, child: TextField(controller: emojiController, decoration: InputDecoration(labelText: 'Emoji', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))))),
                                const SizedBox(width: 12),
                                Expanded(flex: 3, child: TextField(controller: categoryController, decoration: InputDecoration(labelText: 'Category Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))))),
                              ],
                            ),
                          ],
                          const SizedBox(height: 24),
                          Text('Set Limits for Periods', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          _buildPeriodInputRow(context: context, label: 'Daily (Day)', icon: '⏰', controller: dailyController),
                          _buildPeriodInputRow(context: context, label: 'Monthly (Month)', icon: '🗓️', controller: monthlyController),
                          _buildPeriodInputRow(context: context, label: 'Yearly (Year)', icon: '📆', controller: yearlyController),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBudgetVsActualChart(double totalBudget, double totalSpent, BudgetModel budget, LimitPeriod period, BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final isOver = totalSpent > totalBudget;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Container(
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
                Text('Budget vs Spent', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () => _showDetailedAnalyticsSheet(context, budget, period),
                  icon: const Icon(Icons.analytics, size: 16),
                  label: const Text('Detailed View', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [Container(width: 12, height: 12, decoration: BoxDecoration(color: primary, shape: BoxShape.circle)), const SizedBox(width: 8), const Text('Budget')]),
                Row(children: [Container(width: 12, height: 12, decoration: BoxDecoration(color: isOver ? Colors.redAccent : Colors.green, shape: BoxShape.circle)), const SizedBox(width: 8), const Text('Spent')]),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (totalBudget > totalSpent ? totalBudget : totalSpent) * 1.2,
                  barTouchData: BarTouchData(
                    enabled: false,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => Colors.transparent,
                      tooltipPadding: EdgeInsets.zero,
                      tooltipMargin: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '₹${rod.toY.toStringAsFixed(0)}',
                          TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyMedium?.color),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            value == 0 ? 'Budget' : 'Spent',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color),
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
                      showingTooltipIndicators: [0],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [BarChartRodData(toY: totalSpent, color: isOver ? Colors.redAccent : Colors.green, width: 44, borderRadius: BorderRadius.circular(10))],
                      showingTooltipIndicators: [0],
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

  void _showDetailedAnalyticsSheet(BuildContext context, BudgetModel budget, LimitPeriod period) {
    final items = budget.categoryLimits.where((l) => l.period == period).toList();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        return DraggableScrollableSheet(
          initialChildSize: 0.92,
          minChildSize: 0.5,
          maxChildSize: 0.92,
          builder: (ctx, scrollController) => AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.fastOutSlowIn,
            padding: EdgeInsets.only(bottom: bottomInset),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 48),
                      Text('Detailed Analytics', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Category Breakdown (${period.name})', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _buildCategoryUtilizationChart(items, context),
                        const SizedBox(height: 32),
                        Text('Utilization List', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _buildDetailedCategoryUtilizationList(items, period, context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryUtilizationChart(List<CategoryLimit> items, BuildContext context) {
    if (items.isEmpty) {
       return const Center(child: Text('No categories set.', style: TextStyle(color: Colors.grey)));
    }
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: items.map((limit) {
            return PieChartSectionData(
              color: limit.isOverBudget ? Colors.redAccent : Colors.primaries[items.indexOf(limit) % Colors.primaries.length],
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

  Widget _buildDetailedCategoryUtilizationList(List<CategoryLimit> items, LimitPeriod period, BuildContext context) {
    if (items.isEmpty) return const SizedBox();
    final sorted = [...items]..sort((a, b) => b.spentAmount.compareTo(a.spentAmount));
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: sorted.map((limit) => _buildDetailedCategoryLimitCard(limit, period)).toList(),
      ),
    );
  }
}
