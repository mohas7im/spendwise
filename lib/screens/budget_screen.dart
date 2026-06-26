import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/budget.dart';
import '../providers/budget_provider.dart';
import '../providers/finance_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common/premium_gradient_card.dart';
import '../widgets/common/custom_progress_bar.dart';
import 'budget_analytics_screen.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  LimitPeriod _selectedPeriod = LimitPeriod.monthly;

  @override
  void dispose() {
    super.dispose();
  }

  double _getCategoryListHeight(BudgetModel budget) {
    final count = budget.categoryLimits.where((l) => l.period == _selectedPeriod).length;
    if (count == 0) return 200.0;
    return count * 155.0 + 50.0;
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
          double totalSavings = budget.savingsGoals.fold(0, (sum, g) => sum + g.currentAmount);
          int overBudgetCount = periodLimits.where((l) => l.isOverBudget).length;

          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    children: [
                      Text('Budget & Goals', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.analytics_outlined),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const BudgetAnalyticsScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Global Period Filter
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _PeriodChip(
                          label: 'Daily',
                          selected: _selectedPeriod == LimitPeriod.daily,
                          onTap: () => setState(() => _selectedPeriod = LimitPeriod.daily),
                        ),
                        const SizedBox(width: 8),
                        _PeriodChip(
                          label: 'Weekly',
                          selected: _selectedPeriod == LimitPeriod.weekly,
                          onTap: () => setState(() => _selectedPeriod = LimitPeriod.weekly),
                        ),
                        const SizedBox(width: 8),
                        _PeriodChip(
                          label: 'Monthly',
                          selected: _selectedPeriod == LimitPeriod.monthly,
                          onTap: () => setState(() => _selectedPeriod = LimitPeriod.monthly),
                        ),
                        const SizedBox(width: 8),
                        _PeriodChip(
                          label: 'Yearly',
                          selected: _selectedPeriod == LimitPeriod.yearly,
                          onTap: () => setState(() => _selectedPeriod = LimitPeriod.yearly),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dashboard Summary Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          child: _buildDashboardSummary(totalBudget, totalSpent, remainingBudget),
                        ),

                        // Over Budget Alert Banner
                        if (overBudgetCount > 0)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                            child: GestureDetector(
                              onTap: () => _showOverBudgetSheet(context, budget),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
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

                        // Savings Goals Section
                        if (budget.savingsGoals.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text('Savings Goals', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                                    const SizedBox(width: 8),
                                    Text('Total: ₹${totalSavings.toStringAsFixed(0)}', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () => _showAddSavingsGoalSheet(context, budgetProvider), 
                                  child: Text('+ Add', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold))
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 160,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              scrollDirection: Axis.horizontal,
                              itemCount: budget.savingsGoals.length,
                              itemBuilder: (context, index) => _buildSavingsGoalCard(budget.savingsGoals[index]),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Category Limits Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Spending Limits', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                              TextButton(
                                onPressed: () => _showAddLimitSheet(context, budgetProvider), 
                                child: Text('+ Add Limit', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold))
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        SizedBox(
                          height: _getCategoryListHeight(budget),
                          child: _buildCategoryLimitsList(_selectedPeriod, budget),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDashboardSummary(double budget, double spent, double remaining) {
    final periodLabel = _selectedPeriod == LimitPeriod.daily
        ? 'Daily'
        : _selectedPeriod == LimitPeriod.weekly
            ? 'Weekly'
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
                spent > budget ? Colors.redAccent : Colors.greenAccent,
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
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
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

  Widget _buildSavingsGoalCard(SavingsGoal goal) {
    final dateFormat = DateFormat('MMM d, yyyy');
    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(goal.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              Icon(Icons.flag_circle, color: Theme.of(context).primaryColor),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('₹${goal.currentAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text('of ₹${goal.targetAmount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              CustomProgressBar(percent: goal.progressPercentage, minHeight: 8),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${(goal.progressPercentage * 100).toStringAsFixed(1)}%', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 11, fontWeight: FontWeight.bold)),
                  Text('Target: ${dateFormat.format(goal.targetDate)}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ],
          ),
        ],
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
              Icon(Icons.assignment_late_outlined, size: 48, color: Colors.grey.withOpacity(0.5)),
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

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildDetailedCategoryLimitCard(items[index], period),
    );
  }

  Widget _buildDetailedCategoryLimitCard(CategoryLimit limit, LimitPeriod period) {
    final periodLabel = period == LimitPeriod.daily ? 'day' : period == LimitPeriod.weekly ? 'week' : 'month';
    final isOver = limit.isOverBudget;
    final progressColor = isOver ? Colors.redAccent : limit.percentUsed > 0.9 ? Colors.red : limit.percentUsed > 0.75 ? const Color(0xFFF59E0B) : Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isOver ? Colors.redAccent.withOpacity(0.5) : Colors.grey.withOpacity(0.1), width: isOver ? 1.5 : 1),
        boxShadow: isOver ? [BoxShadow(color: Colors.redAccent.withOpacity(0.05), blurRadius: 10)] : [],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, shape: BoxShape.circle),
                child: Text(limit.emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(limit.category, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      'Budget: ₹${limit.limitAmount.toStringAsFixed(0)} / $periodLabel',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (isOver) 
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: const Text('OVERSPENT', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                )
              else 
                Text('${(limit.percentUsed * 100).toStringAsFixed(0)}%', style: TextStyle(color: progressColor, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: limit.percentUsed.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.grey.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Spent', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  Text('₹${limit.spentAmount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isOver ? Colors.redAccent : null)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(isOver ? 'Over by' : 'Remaining', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  Text(
                    '₹${isOver ? limit.overspentAmount.toStringAsFixed(0) : limit.remainingAmount.toStringAsFixed(0)}', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isOver ? Colors.redAccent : Colors.green),
                  ),
                ],
              ),
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
              border: Border.all(color: Colors.grey.withOpacity(0.15)),
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
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 13),
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
    final weeklyController = TextEditingController();
    final monthlyController = TextEditingController();
    final yearlyController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Category Limits', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                
                // Preset Category Dropdown
                DropdownButtonFormField<Map<String, String>?>(
                  value: isCustomCategory ? null : selectedPreset,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: [
                    ...presetCategories.map((cat) => DropdownMenuItem<Map<String, String>?>(
                      value: cat,
                      child: Row(
                        children: [
                          Text(cat['emoji']!, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(cat['name']!),
                        ],
                      ),
                    )),
                    const DropdownMenuItem<Map<String, String>?>(
                      value: null,
                      child: Row(
                        children: [
                          Text('➕', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text('Custom Category...'),
                        ],
                      ),
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
                
                // Show text inputs if Custom Category is selected
                if (isCustomCategory) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: emojiController,
                          decoration: InputDecoration(
                            labelText: 'Emoji', 
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: categoryController,
                          decoration: InputDecoration(
                            labelText: 'Category Name', 
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),
                Text('Set Limits for Periods', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildPeriodInputRow(context: context, label: 'Daily (Day)', icon: '⏰', controller: dailyController),
                _buildPeriodInputRow(context: context, label: 'Weekly (Week)', icon: '📅', controller: weeklyController),
                _buildPeriodInputRow(context: context, label: 'Monthly (Month)', icon: '🗓️', controller: monthlyController),
                _buildPeriodInputRow(context: context, label: 'Yearly (Year)', icon: '📆', controller: yearlyController),
                
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor, 
                      foregroundColor: Theme.of(context).colorScheme.onPrimary, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final category = categoryController.text.trim();
                      final emoji = emojiController.text.isNotEmpty ? emojiController.text.trim() : '🔹';

                      if (category.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a category name')),
                        );
                        return;
                      }

                      final newLimits = <CategoryLimit>[];

                      void tryAddLimit(String text, LimitPeriod period) {
                        final val = double.tryParse(text) ?? 0.0;
                        if (val > 0) {
                          newLimits.add(CategoryLimit(
                            category: category,
                            emoji: emoji,
                            limitAmount: val,
                            period: period,
                            spentAmount: 0.0,
                          ));
                        }
                      }

                      tryAddLimit(dailyController.text, LimitPeriod.daily);
                      tryAddLimit(weeklyController.text, LimitPeriod.weekly);
                      tryAddLimit(monthlyController.text, LimitPeriod.monthly);
                      tryAddLimit(yearlyController.text, LimitPeriod.yearly);

                      if (newLimits.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please specify at least one limit amount')),
                        );
                        return;
                      }

                      for (var limit in newLimits) {
                        provider.addCategoryLimit(limit);
                      }

                      Navigator.pop(ctx);
                    },
                    child: const Text('Add Limits', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddSavingsGoalSheet(BuildContext context, BudgetProvider provider) {
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    final currentController = TextEditingController();
    DateTime targetDate = DateTime.now().add(const Duration(days: 30));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Savings Goal', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Goal Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: targetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Target Amount (₹)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: currentController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Current Saved Amount (₹)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Target Date'),
                  subtitle: Text(DateFormat('MMM d, yyyy').format(targetDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: targetDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                    );
                    if (picked != null) setState(() => targetDate = picked);
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Theme.of(context).colorScheme.onPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () {
                      final target = double.tryParse(targetController.text) ?? 0.0;
                      final current = double.tryParse(currentController.text) ?? 0.0;
                      if (nameController.text.isNotEmpty && target > 0) {
                        provider.addSavingsGoal(SavingsGoal(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameController.text,
                          targetAmount: target,
                          currentAmount: current,
                          startDate: DateTime.now(),
                          targetDate: targetDate,
                        ));
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text('Create Goal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? primary : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
