import 'income_source.dart'; // Reuse IncomeFrequency from existing model

/// Budget model applying the 50/30/20 rule to a monthly salary.
class BudgetModel {
  final double monthlySalary;
  final List<IncomeEntry> incomes;
  final List<CategoryLimit> categoryLimits;

  BudgetModel({
    required this.monthlySalary,
    this.incomes = const [],
    this.categoryLimits = const [],
  });

  double get totalIncome =>
      monthlySalary + incomes.fold(0, (sum, i) => sum + i.amount);

  // 50/30/20 Rule
  double get needsBudget => totalIncome * 0.50;
  double get wantsBudget => totalIncome * 0.30;
  double get savingsBudget => totalIncome * 0.20;
}

class IncomeEntry {
  final String source;
  final double amount;
  final IncomeFrequency frequency;

  const IncomeEntry({
    required this.source,
    required this.amount,
    required this.frequency,
  });
}

class CategoryLimit {
  final String category;
  final String emoji;
  final double limitAmount;
  final LimitPeriod period;
  double spentAmount;

  CategoryLimit({
    required this.category,
    required this.emoji,
    required this.limitAmount,
    required this.period,
    this.spentAmount = 0.0,
  });

  double get remainingAmount => limitAmount - spentAmount;
  double get percentUsed =>
      limitAmount > 0 ? (spentAmount / limitAmount).clamp(0.0, 1.0) : 0.0;
  bool get isOverBudget => spentAmount > limitAmount;
}

enum LimitPeriod { daily, weekly, monthly }
