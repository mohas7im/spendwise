import 'package:flutter/material.dart';
import '../models/budget.dart';
import '../models/income_source.dart';
import '../services/dummy_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common/premium_gradient_card.dart';
import '../widgets/common/custom_tab_bar.dart';
import '../widgets/common/custom_progress_bar.dart';
import '../widgets/common/metric_card.dart';
class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> with SingleTickerProviderStateMixin {
  late BudgetModel budget;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    budget = DummyDataService.getDummyBudget();
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
    final cardColor = Theme.of(context).cardColor;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  Text('Budget Planner', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  GestureDetector(
                    onTap: _showManageIncomeModal,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                      child: const Row(
                        children: [
                          Icon(Icons.edit_outlined, color: AppTheme.primaryColor, size: 16),
                          SizedBox(width: 6),
                          Text('Manage Income', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Salary Summary Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: _buildSalarySummaryCard(),
                    ),

                    // 50/30/20 Rule
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildRuleSection(isDark),
                    ),
                    const SizedBox(height: 24),

                    // Savings Progress
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildSavingsProgress(cardColor),
                    ),
                    const SizedBox(height: 28),

                    // Category Limits Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Spending Limits', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                          TextButton(onPressed: () {}, child: const Text('+ Add', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Period Tab Bar
                    CustomTabBar(
                      controller: _tabController,
                      tabs: const [Tab(text: 'Monthly'), Tab(text: 'Weekly'), Tab(text: 'Daily')],
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      height: budget.categoryLimits.length * 104.0,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildCategoryLimitsList(LimitPeriod.monthly),
                          _buildCategoryLimitsList(LimitPeriod.weekly),
                          _buildCategoryLimitsList(LimitPeriod.daily),
                        ],
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

  Widget _buildSalarySummaryCard() {
    return PremiumGradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Monthly Income', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 6),
          Text('₹ ${budget.totalIncome.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold, letterSpacing: -1)),
          const SizedBox(height: 16),
          Row(
            children: budget.incomes.map((income) => Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(income.source, style: const TextStyle(color: Colors.white60, fontSize: 11)),
                  Text('₹${income.amount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
            )).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildRuleSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('50 / 30 / 20 Rule', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              child: const Text('Recommended', style: TextStyle(color: AppTheme.primaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text('A proven formula to allocate your income wisely', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 14),
        Row(
          children: [
            _buildRuleCard('50%', 'Needs', '₹${budget.needsBudget.toStringAsFixed(0)}', 'Rent, Bills, Food', const Color(0xFF6366F1)),
            const SizedBox(width: 10),
            _buildRuleCard('30%', 'Wants', '₹${budget.wantsBudget.toStringAsFixed(0)}', 'Fun & Shopping', const Color(0xFFF59E0B)),
            const SizedBox(width: 10),
            _buildRuleCard('20%', 'Savings', '₹${budget.savingsBudget.toStringAsFixed(0)}', 'Invest & Save', AppTheme.primaryColor),
          ],
        ),
      ],
    );
  }

  Widget _buildRuleCard(String percent, String label, String amount, String subtitle, Color color) {
    return Expanded(
      child: MetricCard(
        baseColor: color,
        padding: const EdgeInsets.all(14),
        borderWidth: 1.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(percent, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 20)),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 8),
            Text(amount, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 9), maxLines: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsProgress(Color cardColor) {
    final savingsGoal = budget.savingsBudget;
    final currentSavings = savingsGoal * 0.6;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('🏦  Savings This Month', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
              Text('₹${currentSavings.toStringAsFixed(0)} / ₹${savingsGoal.toStringAsFixed(0)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 14),
          const CustomProgressBar(percent: 0.6, minHeight: 10),
          const SizedBox(height: 8),
          const Text('60% of your savings goal reached this month 🎯', style: TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildCategoryLimitsList(LimitPeriod period) {
    final divisor = period == LimitPeriod.weekly ? 4.0 : period == LimitPeriod.daily ? 30.0 : 1.0;
    final items = budget.categoryLimits.map((l) => CategoryLimit(
      category: l.category, emoji: l.emoji,
      limitAmount: l.limitAmount / divisor, period: period,
      spentAmount: l.spentAmount / divisor,
    )).toList();

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildCategoryLimitCard(items[index], period),
    );
  }

  Widget _buildCategoryLimitCard(CategoryLimit limit, LimitPeriod period) {
    final periodLabel = period == LimitPeriod.daily ? 'day' : period == LimitPeriod.weekly ? 'week' : 'month';
    final isOver = limit.isOverBudget;
    final progressColor = isOver ? Colors.redAccent : limit.percentUsed > 0.7 ? const Color(0xFFF59E0B) : Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isOver ? Colors.redAccent.withOpacity(0.3) : Colors.grey.withOpacity(0.1), width: isOver ? 1.5 : 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(limit.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(limit.category, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      isOver ? '⚠️ Over by ₹${(limit.spentAmount - limit.limitAmount).toStringAsFixed(0)}' : '₹${limit.remainingAmount.toStringAsFixed(0)} left this $periodLabel',
                      style: TextStyle(color: isOver ? Colors.redAccent : Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${limit.spentAmount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isOver ? Colors.redAccent : null)),
                  Text('/ ₹${limit.limitAmount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomProgressBar(percent: limit.percentUsed, minHeight: 8),
        ],
      ),
    );
  }

  void _showManageIncomeModal() {
    final salaryController = TextEditingController(text: budget.monthlySalary.toStringAsFixed(0));
    final sourceController = TextEditingController();
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setModalState) => Container(
          height: MediaQuery.of(ctx).size.height * 0.85,
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Text('Manage Income', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
              const SizedBox(height: 24),

              // Base Salary Edit
              Text('Base Monthly Salary', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: salaryController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),

              // Additional Income Streams
              Text('Additional Income Streams', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              
              if (budget.incomes.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('No additional income streams.', style: TextStyle(color: Colors.grey)),
                ),

              Expanded(
                child: ListView.builder(
                  itemCount: budget.incomes.length,
                  itemBuilder: (context, index) {
                    final income = budget.incomes[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(income.source, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('₹${income.amount.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () {
                              setModalState(() {
                                budget.incomes.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),
              // Add New Income
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: sourceController,
                      decoration: InputDecoration(
                        labelText: 'Source (e.g. Freelance)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        prefixText: '₹ ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    if (sourceController.text.isNotEmpty && amountController.text.isNotEmpty) {
                      setModalState(() {
                        budget.incomes.add(IncomeEntry(
                          source: sourceController.text,
                          amount: double.tryParse(amountController.text) ?? 0,
                          frequency: IncomeFrequency.monthly,
                        ));
                      });
                      sourceController.clear();
                      amountController.clear();
                    }
                  },
                  icon: const Icon(Icons.add_circle, color: AppTheme.primaryColor),
                  label: const Text('Add Income Source', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final newSalary = double.tryParse(salaryController.text) ?? budget.monthlySalary;
                    setState(() {
                      budget = BudgetModel(
                        monthlySalary: newSalary,
                        incomes: budget.incomes,
                        categoryLimits: budget.categoryLimits,
                      );
                    });
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
