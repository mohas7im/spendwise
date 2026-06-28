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
  final String id;
  final double limitAmount;
  final LimitPeriod period;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  double spentAmount;
  final bool allowRollover;
  double rolloverAmount;
  final bool enforceLimit;

  GlobalBudgetLimit({
    required this.id,
    required this.limitAmount,
    required this.period,
    this.customStartDate,
    this.customEndDate,
    this.spentAmount = 0.0,
    this.allowRollover = false,
    this.rolloverAmount = 0.0,
    this.enforceLimit = false,
  });

  double get effectiveLimit => limitAmount + rolloverAmount;
  double get remainingAmount => effectiveLimit - spentAmount;
  double get percentUsed => effectiveLimit > 0 ? (spentAmount / effectiveLimit) : 0.0;
  bool get isOverBudget => spentAmount > effectiveLimit;
  double get overspentAmount => isOverBudget ? spentAmount - effectiveLimit : 0.0;

  int remainingDays(DateTime referenceDate, {DateTime? nextSalaryDate}) {
    if (period == LimitPeriod.custom && customEndDate != null) {
      final diff = customEndDate!.difference(referenceDate).inDays;
      return diff >= 0 ? diff + 1 : 0;
    }
    
    DateTime end;
    switch (period) {
      case LimitPeriod.daily:
        return 1;
      case LimitPeriod.weekly:
        final daysToSunday = 7 - referenceDate.weekday;
        end = referenceDate.add(Duration(days: daysToSunday));
        break;
      case LimitPeriod.monthly:
        end = DateTime(referenceDate.year, referenceDate.month + 1, 0);
        break;
      case LimitPeriod.quarterly:
        final currentQuarter = (referenceDate.month - 1) ~/ 3;
        final lastMonthOfQuarter = (currentQuarter * 3) + 3;
        end = DateTime(referenceDate.year, lastMonthOfQuarter + 1, 0);
        break;
      case LimitPeriod.yearly:
        end = DateTime(referenceDate.year, 12, 31);
        break;
      case LimitPeriod.custom:
        if (nextSalaryDate != null) {
          final diff = nextSalaryDate.difference(referenceDate).inDays;
          return diff >= 0 ? diff + 1 : 0;
        } else {
          end = DateTime(referenceDate.year, referenceDate.month + 1, 0);
        }
        break;
    }
    
    final diff = DateTime(end.year, end.month, end.day).difference(DateTime(referenceDate.year, referenceDate.month, referenceDate.day)).inDays;
    return diff >= 0 ? diff + 1 : 0;
  }

  double recommendedDailySpend(DateTime referenceDate, {DateTime? nextSalaryDate}) {
    if (remainingAmount <= 0) return 0.0;
    final days = remainingDays(referenceDate, nextSalaryDate: nextSalaryDate);
    if (days <= 0) return remainingAmount;
    return remainingAmount / days;
  }

  String get status {
    if (percentUsed >= 1.0) return "🔴 Budget Exceeded";
    if (percentUsed >= 0.8) return "🟡 Near Budget Limit";
    return "✅ On Track";
  }
}

class CategoryLimit {
  final String id;
  final String category;
  final String emoji;
  final double limitAmount;
  final LimitPeriod period;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  double spentAmount;
  final bool allowRollover;
  double rolloverAmount;
  final bool enforceLimit;

  CategoryLimit({
    required this.id,
    required this.category,
    required this.emoji,
    required this.limitAmount,
    required this.period,
    this.customStartDate,
    this.customEndDate,
    this.spentAmount = 0.0,
    this.allowRollover = false,
    this.rolloverAmount = 0.0,
    this.enforceLimit = false,
  });

  double get effectiveLimit => limitAmount + rolloverAmount;
  double get remainingAmount => effectiveLimit - spentAmount;
  double get percentUsed => effectiveLimit > 0 ? (spentAmount / effectiveLimit) : 0.0;
  bool get isOverBudget => spentAmount > effectiveLimit;
  double get overspentAmount => isOverBudget ? spentAmount - effectiveLimit : 0.0;

  int remainingDays(DateTime referenceDate, {DateTime? nextSalaryDate}) {
    if (period == LimitPeriod.custom && customEndDate != null) {
      final diff = customEndDate!.difference(referenceDate).inDays;
      return diff >= 0 ? diff + 1 : 0;
    }
    
    DateTime end;
    switch (period) {
      case LimitPeriod.daily:
        return 1;
      case LimitPeriod.weekly:
        final daysToSunday = 7 - referenceDate.weekday;
        end = referenceDate.add(Duration(days: daysToSunday));
        break;
      case LimitPeriod.monthly:
        end = DateTime(referenceDate.year, referenceDate.month + 1, 0);
        break;
      case LimitPeriod.quarterly:
        final currentQuarter = (referenceDate.month - 1) ~/ 3;
        final lastMonthOfQuarter = (currentQuarter * 3) + 3;
        end = DateTime(referenceDate.year, lastMonthOfQuarter + 1, 0);
        break;
      case LimitPeriod.yearly:
        end = DateTime(referenceDate.year, 12, 31);
        break;
      case LimitPeriod.custom:
        if (nextSalaryDate != null) {
          final diff = nextSalaryDate.difference(referenceDate).inDays;
          return diff >= 0 ? diff + 1 : 0;
        } else {
          end = DateTime(referenceDate.year, referenceDate.month + 1, 0);
        }
        break;
    }
    
    final diff = DateTime(end.year, end.month, end.day).difference(DateTime(referenceDate.year, referenceDate.month, referenceDate.day)).inDays;
    return diff >= 0 ? diff + 1 : 0;
  }

  double recommendedDailySpend(DateTime referenceDate, {DateTime? nextSalaryDate}) {
    if (remainingAmount <= 0) return 0.0;
    final days = remainingDays(referenceDate, nextSalaryDate: nextSalaryDate);
    if (days <= 0) return remainingAmount;
    return remainingAmount / days;
  }

  String get status {
    if (percentUsed >= 1.0) return "🔴 Budget Exceeded";
    if (percentUsed >= 0.8) return "🟡 Near Budget Limit";
    return "✅ On Track";
  }
}
