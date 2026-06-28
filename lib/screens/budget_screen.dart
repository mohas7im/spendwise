import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/budget.dart';
import '../models/transaction.dart';
import '../providers/budget_provider.dart';
import '../providers/finance_provider.dart';
import '../widgets/common/premium_gradient_card.dart';
import '../widgets/common/custom_tab_bar.dart';
import '../widgets/common/custom_bottom_sheet.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> with SingleTickerProviderStateMixin {
  LimitPeriod _selectedPeriod = LimitPeriod.monthly;
  late TabController _tabController;
  FinanceProvider? _financeProvider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 2); // 2 = monthly
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          if (_tabController.index == 0) {
            _selectedPeriod = LimitPeriod.daily;
          } else if (_tabController.index == 1) {
            _selectedPeriod = LimitPeriod.weekly;
          } else if (_tabController.index == 2) {
            _selectedPeriod = LimitPeriod.monthly;
          } else {
            _selectedPeriod = LimitPeriod.yearly;
          }
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _financeProvider = Provider.of<FinanceProvider>(context, listen: false);
      final budget = Provider.of<BudgetProvider>(context, listen: false);
      budget.setTransactions(_financeProvider!.transactions);
      _financeProvider!.addListener(_onFinanceChanged);
    });
  }

  void _onFinanceChanged() {
    if (mounted && _financeProvider != null) {
      Provider.of<BudgetProvider>(context, listen: false).setTransactions(_financeProvider!.transactions);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _financeProvider?.removeListener(_onFinanceChanged);
    super.dispose();
  }

  void _navigateTime(BudgetProvider provider, int direction) {
    final cur = provider.currentViewDate;
    DateTime next;
    switch (_selectedPeriod) {
      case LimitPeriod.daily:
        next = cur.add(Duration(days: direction));
        break;
      case LimitPeriod.weekly:
        next = cur.add(Duration(days: 7 * direction));
        break;
      case LimitPeriod.monthly:
        next = DateTime(cur.year, cur.month + direction, cur.day);
        break;
      case LimitPeriod.yearly:
        next = DateTime(cur.year + direction, cur.month, cur.day);
        break;
      default:
        next = cur;
    }
    provider.changeViewDate(next);
  }

  String _getPeriodLabel(DateTime date) {
    switch (_selectedPeriod) {
      case LimitPeriod.daily: return DateFormat('MMM d, yyyy').format(date);
      case LimitPeriod.weekly: return 'Week of ${DateFormat('MMM d').format(date)}';
      case LimitPeriod.monthly: return DateFormat('MMMM yyyy').format(date);
      case LimitPeriod.yearly: return DateFormat('yyyy').format(date);
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: Consumer<BudgetProvider>(
        builder: (context, budgetProvider, child) {
          final budget = budgetProvider.budget;

          // Compute Dashboard Metrics
          final periodLimits = budget.categoryLimits.where((l) => l.period == _selectedPeriod).toList();
          
          final double totalLimitAmount = periodLimits.fold(0.0, (sum, l) => sum + l.limitAmount);
          final double totalSpentAmount = periodLimits.fold(0.0, (sum, l) => sum + l.spentAmount);
          
          final globalLimit = periodLimits.isNotEmpty ? GlobalBudgetLimit(
            id: 'computed_${_selectedPeriod.name}',
            period: _selectedPeriod,
            limitAmount: totalLimitAmount,
            spentAmount: totalSpentAmount,
          ) : null;

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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Budgets', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.add_circle, color: Theme.of(context).primaryColor, size: 28),
                              onPressed: () => _showAddLimitSheet(context, budgetProvider),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Tab Bar for Limits
                  CustomTabBar(
                    controller: _tabController,
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                    tabs: const [
                      Tab(text: 'Daily'),
                      Tab(text: 'Weekly'),
                      Tab(text: 'Monthly'),
                      Tab(text: 'Yearly'),
                    ],
                  ),

                  // Historical Navigation Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () => _navigateTime(budgetProvider, -1),
                        ),
                        Text(
                          _getPeriodLabel(budgetProvider.currentViewDate),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () => _navigateTime(budgetProvider, 1),
                        ),
                      ],
                    ),
                  ),

                  // Master Global Budget Tracker
                  if (globalLimit != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: PremiumGradientCard(
                          builder: (ctx, textColor, subTextColor) {
                            final pct = (globalLimit.percentUsed).clamp(0.0, 1.0);
                            final color = globalLimit.isOverBudget ? Colors.red.shade900 : pct > 0.85 ? Colors.orangeAccent : Colors.greenAccent;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Master Budget', style: TextStyle(color: subTextColor, fontSize: 14)),

                                    Text('${(pct * 100).toStringAsFixed(0)}%', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('₹${globalLimit.spentAmount.toStringAsFixed(0)} / ₹${globalLimit.effectiveLimit.toStringAsFixed(0)}', style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 16),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: pct,
                                    minHeight: 12,
                                    backgroundColor: Colors.white24,
                                    valueColor: AlwaysStoppedAnimation<Color>(color),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      )
                  else
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Text('Add a category budget to see your master tracker.'),
                    ),

                  const SizedBox(height: 16),

                  // Over Budget Alert Banner
                  if (overBudgetCount > 0)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade900.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.red.shade900.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.red.shade900, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '$overBudgetCount categor${overBudgetCount == 1 ? 'y' : 'ies'} over budget this period',
                                style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  if (periodLimits.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Text('Budget vs Actual', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                    _buildBudgetActualChart(periodLimits, Theme.of(context).brightness == Brightness.dark),
                    const SizedBox(height: 16),
                  ],

                  _buildCategoryLimitsList(_selectedPeriod, budgetProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryLimitsList(LimitPeriod period, BudgetProvider provider) {
    final items = provider.budget.categoryLimits.where((l) => l.period == period).toList();

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
          children: sorted.map((limit) => _buildDetailedCategoryLimitCard(limit, provider)).toList(),
        ),
      ),
    );
  }

  Widget _buildDetailedCategoryLimitCard(CategoryLimit limit, BudgetProvider provider) {
    final pct = (limit.percentUsed).clamp(0.0, 1.0);
    final isOver = limit.isOverBudget;
    final barColor = isOver ? Colors.red.shade900 : pct > 0.85 ? Colors.orangeAccent : Colors.greenAccent;

    return GestureDetector(
      onTap: () => _showAddLimitSheet(context, provider, existingLimit: limit),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          color: Colors.transparent, // for tap area
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
                      decoration: BoxDecoration(color: Colors.red.shade900.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                      child: Text('OVER', style: TextStyle(color: Colors.red.shade900, fontSize: 10, fontWeight: FontWeight.bold)),
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
                  Text('of ₹${limit.effectiveLimit.toStringAsFixed(0)}', style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddLimitSheet(BuildContext context, BudgetProvider provider, {CategoryLimit? existingLimit}) {
    final financeProvider = Provider.of<FinanceProvider>(context, listen: false);
    final presetCategories = financeProvider.categories.map((c) => {
      'name': c.name,
      'emoji': c.emoji,
    }).toList();

    String currentCategory = existingLimit?.category ?? (presetCategories.isNotEmpty ? presetCategories.first['name']! : '');
    String currentEmoji = existingLimit?.emoji ?? (presetCategories.isNotEmpty ? presetCategories.first['emoji']! : '🔹');
    
    // Fetch all existing limits for this category
    final categoryLimits = provider.budget.categoryLimits.where((l) => l.category == currentCategory).toList();
    CategoryLimit? getLimitFor(LimitPeriod period) {
      final matches = categoryLimits.where((l) => l.period == period);
      return matches.isNotEmpty ? matches.first : null;
    }

    final dailyCtrl = TextEditingController(text: getLimitFor(LimitPeriod.daily)?.limitAmount.toStringAsFixed(0) ?? '');
    final weeklyCtrl = TextEditingController(text: getLimitFor(LimitPeriod.weekly)?.limitAmount.toStringAsFixed(0) ?? '');
    final monthlyCtrl = TextEditingController(text: getLimitFor(LimitPeriod.monthly)?.limitAmount.toStringAsFixed(0) ?? '');
    final yearlyCtrl = TextEditingController(text: getLimitFor(LimitPeriod.yearly)?.limitAmount.toStringAsFixed(0) ?? '');

    bool allowRollover = categoryLimits.isNotEmpty ? categoryLimits.first.allowRollover : false;
    double? suggestedMonthlyAmount;

    // AI Suggestion Algorithm: Average of last 3 months
    void calculateSuggestion(String catName) {
      if (catName.isEmpty) return;
      final txs = financeProvider.transactions.where((t) => t.category == catName && t.type == TransactionType.expense).toList();
      if (txs.isEmpty) {
        suggestedMonthlyAmount = null;
        return;
      }
      double total = txs.fold(0, (sum, t) => sum + t.amount);
      if (total > 0) {
        suggestedMonthlyAmount = total / 3;
      } else {
        suggestedMonthlyAmount = null;
      }
    }

    // Refresh controllers if category changes
    void updateControllersForCategory() {
        final newCategoryLimits = provider.budget.categoryLimits.where((l) => l.category == currentCategory).toList();
        CategoryLimit? getNewLimitFor(LimitPeriod period) {
            final matches = newCategoryLimits.where((l) => l.period == period);
            return matches.isNotEmpty ? matches.first : null;
        }
        dailyCtrl.text = getNewLimitFor(LimitPeriod.daily)?.limitAmount.toStringAsFixed(0) ?? '';
        weeklyCtrl.text = getNewLimitFor(LimitPeriod.weekly)?.limitAmount.toStringAsFixed(0) ?? '';
        monthlyCtrl.text = getNewLimitFor(LimitPeriod.monthly)?.limitAmount.toStringAsFixed(0) ?? '';
        yearlyCtrl.text = getNewLimitFor(LimitPeriod.yearly)?.limitAmount.toStringAsFixed(0) ?? '';
        allowRollover = newCategoryLimits.isNotEmpty ? newCategoryLimits.first.allowRollover : false;
    }

    calculateSuggestion(currentCategory);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => CustomBottomSheet(
          title: existingLimit == null ? 'Add Category Budget' : 'Edit Budget',
          saveText: 'Save Budget',
          saveIcon: Icons.save,
          headerActions: existingLimit != null ? [
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // Delete all limits for this category
                final limitsToDelete = provider.budget.categoryLimits.where((l) => l.category == currentCategory).toList();
                for (var l in limitsToDelete) {
                    provider.deleteCategoryLimit(l.id);
                }
                Navigator.pop(ctx);
              },
            ),
          ] : null,
          onSave: () {
            void processLimit(TextEditingController ctrl, LimitPeriod period) {
                final val = double.tryParse(ctrl.text) ?? 0.0;
                final limit = getLimitFor(period);
                if (val > 0) {
                    if (limit == null) {
                        provider.addCategoryLimit(CategoryLimit(
                            id: DateTime.now().millisecondsSinceEpoch.toString() + period.name,
                            category: currentCategory,
                            emoji: currentEmoji,
                            limitAmount: val,
                            period: period,
                            allowRollover: allowRollover,
                        ));
                    } else {
                        provider.updateCategoryLimit(CategoryLimit(
                            id: limit.id,
                            category: currentCategory,
                            emoji: currentEmoji,
                            limitAmount: val,
                            period: period,
                            allowRollover: allowRollover,
                        ));
                    }
                } else if (limit != null) {
                    // If they cleared the field, delete the limit
                    provider.deleteCategoryLimit(limit.id);
                }
            }

            processLimit(dailyCtrl, LimitPeriod.daily);
            processLimit(weeklyCtrl, LimitPeriod.weekly);
            processLimit(monthlyCtrl, LimitPeriod.monthly);
            processLimit(yearlyCtrl, LimitPeriod.yearly);

            Navigator.pop(ctx);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (existingLimit == null)
                DropdownButtonFormField<String>(
                  initialValue: currentCategory,
                  decoration: InputDecoration(labelText: 'Category', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  items: presetCategories.map((cat) => DropdownMenuItem<String>(
                    value: cat['name'],
                    child: Row(children: [Text(cat['emoji']!, style: const TextStyle(fontSize: 18)), const SizedBox(width: 8), Text(cat['name']!)]),
                  )).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setModalState(() {
                        currentCategory = val;
                        currentEmoji = presetCategories.firstWhere((c) => c['name'] == val)['emoji']!;
                        updateControllersForCategory();
                        calculateSuggestion(currentCategory);
                      });
                    }
                  },
                )
              else
                Row(
                  children: [
                    Text(currentEmoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Text(currentCategory, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              
              const SizedBox(height: 24),
              const Text('Budget Limits', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              
              Row(
                  children: [
                      Expanded(
                          child: TextField(
                              controller: dailyCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  labelText: 'Daily (₹)',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                          ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                          child: TextField(
                              controller: weeklyCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  labelText: 'Weekly (₹)',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                          ),
                      ),
                  ]
              ),
              const SizedBox(height: 12),
              Row(
                  children: [
                      Expanded(
                          child: TextField(
                              controller: monthlyCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  labelText: 'Monthly (₹)',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                          ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                          child: TextField(
                              controller: yearlyCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  labelText: 'Yearly (₹)',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                          ),
                      ),
                  ]
              ),
              
              if (suggestedMonthlyAmount != null && suggestedMonthlyAmount! > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: GestureDetector(
                    onTap: () => setModalState(() => monthlyCtrl.text = suggestedMonthlyAmount!.toStringAsFixed(0)),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.purpleAccent, size: 16),
                        const SizedBox(width: 4),
                        Text('Suggested monthly based on history: ₹${suggestedMonthlyAmount!.toStringAsFixed(0)}', style: const TextStyle(color: Colors.purpleAccent, fontSize: 12)),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Allow Rollover'),
                subtitle: const Text('Unspent money adds to next period'),
                value: allowRollover,
                onChanged: (val) => setModalState(() => allowRollover = val),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetActualChart(List<CategoryLimit> limits, bool isDark) {
    if (limits.isEmpty) return const SizedBox();

    final double chartWidth = limits.length > 4 ? limits.length * 80.0 : MediaQuery.of(context).size.width - 48;
    final sortedLimits = [...limits]..sort((a, b) => b.limitAmount.compareTo(a.limitAmount));

    double maxY = 0;
    for (var l in sortedLimits) {
      if (l.limitAmount > maxY) maxY = l.limitAmount;
      if (l.spentAmount > maxY) maxY = l.spentAmount;
    }
    if (maxY == 0) maxY = 1000;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: chartWidth,
        height: 250,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY * 1.2,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) => isDark ? Colors.white : Colors.black87,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {

                  final isActual = rodIndex == 1;
                  return BarTooltipItem(
                    isActual ? 'Actual\n₹${rod.toY.round()}' : 'Budget\n₹${rod.toY.round()}',
                    TextStyle(
                      color: isDark ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
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
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= sortedLimits.length || value != index.toDouble()) return const SizedBox();
                    return SideTitleWidget(
                      meta: meta,
                      space: 8,
                      child: Text(
                        '${sortedLimits[index].emoji} ${sortedLimits[index].category}',
                        style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxY / 4 > 0 ? maxY / 4 : 1,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.withValues(alpha: 0.1),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(sortedLimits.length, (index) {
              final limit = sortedLimits[index];
              final pct = (limit.percentUsed).clamp(0.0, 1.0);
              final actualColor = limit.isOverBudget ? Colors.red.shade900 : pct > 0.85 ? Colors.orangeAccent : Colors.greenAccent;
              
              return BarChartGroupData(
                x: index,
                barsSpace: 4,
                barRods: [
                  BarChartRodData(
                    toY: limit.effectiveLimit,
                    color: isDark ? const Color(0xFF2A2D34) : Colors.grey.shade300,
                    width: 14,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                  ),
                  BarChartRodData(
                    toY: limit.spentAmount,
                    color: actualColor,
                    width: 14,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
