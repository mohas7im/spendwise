import 'income_source.dart'; // Reuse IncomeFrequency from existing model

enum LimitPeriod { daily, weekly, monthly, quarterly, yearly, custom }

/// Budget model applying the 50/30/20 rule to a monthly salary.
class BudgetModel {
  final double monthlySalary;
  final List<IncomeEntry> incomes;
  final List<CategoryLimit> categoryLimits;
  final List<SavingsGoal> savingsGoals;
  final List<GlobalBudgetLimit> globalLimits;

  BudgetModel({
    required this.monthlySalary,
    this.incomes = const [],
    this.categoryLimits = const [],
    this.savingsGoals = const [],
    this.globalLimits = const [],
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

class SavingsGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime startDate;
  final DateTime targetDate;

  SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.startDate,
    required this.targetDate,
  });

  double get progressPercentage => targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
  double get remainingAmount => (targetAmount - currentAmount).clamp(0.0, double.infinity);
  
  DateTime? get estimatedCompletionDate {
    if (currentAmount <= 0) return null;
    final elapsedDays = DateTime.now().difference(startDate).inDays;
    if (elapsedDays <= 0) return null;
    
    final ratePerDay = currentAmount / elapsedDays;
    if (ratePerDay <= 0) return null;
    
    final daysRemaining = (remainingAmount / ratePerDay).ceil();
    return DateTime.now().add(Duration(days: daysRemaining));
  }
}

class GlobalBudgetLimit {
  final double limitAmount;
  final LimitPeriod period;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  double spentAmount;

  GlobalBudgetLimit({
    required this.limitAmount,
    required this.period,
    this.customStartDate,
    this.customEndDate,
    this.spentAmount = 0.0,
  });

  double get remainingAmount => limitAmount - spentAmount;
  double get percentUsed => limitAmount > 0 ? (spentAmount / limitAmount) : 0.0;
  bool get isOverBudget => spentAmount > limitAmount;
  double get overspentAmount => isOverBudget ? spentAmount - limitAmount : 0.0;
}

class CategoryLimit {
  final String category;
  final String emoji;
  final double limitAmount;
  final LimitPeriod period;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  double spentAmount;

  CategoryLimit({
    required this.category,
    required this.emoji,
    required this.limitAmount,
    required this.period,
    this.customStartDate,
    this.customEndDate,
    this.spentAmount = 0.0,
  });

  double get remainingAmount => limitAmount - spentAmount;
  double get percentUsed => limitAmount > 0 ? (spentAmount / limitAmount) : 0.0;
  bool get isOverBudget => spentAmount > limitAmount;
  double get overspentAmount => isOverBudget ? spentAmount - limitAmount : 0.0;
}
