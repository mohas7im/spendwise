import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/budget.dart';
import '../providers/budget_provider.dart';
import '../providers/finance_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common/premium_gradient_card.dart';
import '../widgets/common/custom_tab_bar.dart';
import '../widgets/common/custom_progress_bar.dart';
import 'budget_analytics_screen.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> with SingleTickerProviderStateMixin {
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
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: Consumer2<BudgetProvider, FinanceProvider>(
        builder: (context, budgetProvider, financeProvider, child) {
          // Dynamically recalculate spending based on actual transactions
          budgetProvider.recalculateSpending(financeProvider.transactions);
          final budget = budgetProvider.budget;

          // Compute Dashboard Metrics
          double totalBudget = budget.globalLimits.isNotEmpty ? budget.globalLimits.first.limitAmount : budget.categoryLimits.fold(0, (sum, l) => sum + l.limitAmount);
          double totalSpent = budget.globalLimits.isNotEmpty ? budget.globalLimits.first.spentAmount : budget.categoryLimits.fold(0, (sum, l) => sum + l.spentAmount);
          double remainingBudget = (totalBudget - totalSpent).clamp(0.0, double.infinity);
          double totalSavings = budget.savingsGoals.fold(0, (sum, g) => sum + g.currentAmount);
          int overBudgetCount = budget.categoryLimits.where((l) => l.isOverBudget).length;

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

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dashboard Summary Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          child: _buildDashboardSummary(totalBudget, totalSpent, remainingBudget, overBudgetCount),
                        ),

                        // Savings Goals Section
                        if (budget.savingsGoals.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Savings Goals', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                                Text('Total: ₹${totalSavings.toStringAsFixed(0)}', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
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
                        const SizedBox(height: 8),

                        // Period Tab Bar
                        CustomTabBar(
                          controller: _tabController,
                          tabs: const [Tab(text: 'Monthly'), Tab(text: 'Weekly'), Tab(text: 'Daily')],
                        ),
                        const SizedBox(height: 16),

                        SizedBox(
                          height: budget.categoryLimits.length * 155.0 + 50,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildCategoryLimitsList(LimitPeriod.monthly, budget),
                              _buildCategoryLimitsList(LimitPeriod.weekly, budget),
                              _buildCategoryLimitsList(LimitPeriod.daily, budget),
                            ],
                          ),
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

  Widget _buildDashboardSummary(double budget, double spent, double remaining, int overBudgetCount) {
    return PremiumGradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Budget (Monthly)', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 6),
          Text('₹ ${budget.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold, letterSpacing: -1)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Spent', style: TextStyle(color: Colors.white60, fontSize: 11)),
                  Text('₹${spent.toStringAsFixed(0)}', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Remaining', style: TextStyle(color: Colors.white60, fontSize: 11)),
                  Text('₹${remaining.toStringAsFixed(0)}', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Over Budget', style: TextStyle(color: Colors.white60, fontSize: 11)),
                  Text('$overBudgetCount Categories', style: TextStyle(color: overBudgetCount > 0 ? Colors.redAccent : Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
            ],
          )
        ],
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

  void _showAddLimitSheet(BuildContext context, BudgetProvider provider) {
    // Show Modal Bottom Sheet implementation
  }
}
