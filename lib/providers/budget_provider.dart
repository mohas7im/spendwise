import 'package:flutter/foundation.dart';
import '../models/budget.dart';
import '../models/transaction.dart';
import '../services/dummy_data_service.dart';

class BudgetProvider with ChangeNotifier {
  late BudgetModel _budget;
  DateTime _currentViewDate = DateTime.now();
  List<TransactionModel> _transactions = [];

  BudgetProvider() {
    if (!kReleaseMode) {
      _budget = DummyDataService.getDummyBudget();
    } else {
      _budget = BudgetModel(monthlySalary: 0.0);
    }
  }

  BudgetModel get budget => _budget;
  DateTime get currentViewDate => _currentViewDate;

  // Change view date for historical navigation
  void changeViewDate(DateTime newDate) {
    _currentViewDate = newDate;
    _recalculateSpendingInternal();
    notifyListeners();
  }

  // Hook for transactions
  void setTransactions(List<TransactionModel> txs) {
    _transactions = txs;
    _recalculateSpendingInternal();
    notifyListeners();
  }

  // --- CRUD for Category Limits ---
  void addCategoryLimit(CategoryLimit limit) {
    _budget.categoryLimits.add(limit);
    _recalculateSpendingInternal();
    notifyListeners();
  }

  void updateCategoryLimit(CategoryLimit updatedLimit) {
    final idx = _budget.categoryLimits.indexWhere((l) => l.id == updatedLimit.id);
    if (idx != -1) {
      _budget.categoryLimits[idx] = updatedLimit;
      _recalculateSpendingInternal();
      notifyListeners();
    }
  }

  void deleteCategoryLimit(String id) {
    _budget.categoryLimits.removeWhere((l) => l.id == id);
    notifyListeners();
  }

  // --- CRUD for Global Limits ---
  void addGlobalLimit(GlobalBudgetLimit limit) {
    _budget.globalLimits.add(limit);
    _recalculateSpendingInternal();
    notifyListeners();
  }

  void updateGlobalLimit(GlobalBudgetLimit updatedLimit) {
    final idx = _budget.globalLimits.indexWhere((l) => l.id == updatedLimit.id);
    if (idx != -1) {
      _budget.globalLimits[idx] = updatedLimit;
      _recalculateSpendingInternal();
      notifyListeners();
    }
  }

  void deleteGlobalLimit(String id) {
    _budget.globalLimits.removeWhere((l) => l.id == id);
    notifyListeners();
  }

  // --- Savings Goals ---
  void addSavingsGoal(SavingsGoal goal) {
    _budget.savingsGoals.add(goal);
    notifyListeners();
  }

  void updateSavingsGoalProgress(String id, double additionalAmount) {
    final index = _budget.savingsGoals.indexWhere((g) => g.id == id);
    if (index != -1) {
      final oldGoal = _budget.savingsGoals[index];
      _budget.savingsGoals[index] = SavingsGoal(
        id: oldGoal.id,
        name: oldGoal.name,
        targetAmount: oldGoal.targetAmount,
        currentAmount: oldGoal.currentAmount + additionalAmount,
        startDate: oldGoal.startDate,
        targetDate: oldGoal.targetDate,
      );
      notifyListeners();
    }
  }

  void updateBudget(BudgetModel newBudget) {
    _budget = newBudget;
    notifyListeners();
  }

  // Deprecated usage backward compatibility (UI won't use it directly inside build)
  void recalculateSpending(List<TransactionModel> transactions) {
    // Left empty for compatibility if it's called anywhere by mistake
  }

  // --- Rollover Engine & Spending Calculation ---
  void _recalculateSpendingInternal() {
    // 1. Reset spent and rollover amounts
    for (var limit in _budget.categoryLimits) {
      limit.spentAmount = 0;
      limit.rolloverAmount = 0;
    }
    for (var gl in _budget.globalLimits) {
      gl.spentAmount = 0;
      gl.rolloverAmount = 0;
    }

    // 2. Calculate Rollover Bonus if applicable
    _calculateRollovers();

    // 3. Calculate Spending for Current View Date
    for (var tx in _transactions) {
      if (tx.type != TransactionType.expense) continue;

      for (var limit in _budget.categoryLimits.where((l) => l.category == tx.category)) {
        if (_isDateInPeriod(tx.date, limit.period, limit.customStartDate, limit.customEndDate, _currentViewDate)) {
          limit.spentAmount += tx.amount;
        }
      }
      
      for (var gl in _budget.globalLimits) {
        if (_isDateInPeriod(tx.date, gl.period, gl.customStartDate, gl.customEndDate, _currentViewDate)) {
          gl.spentAmount += tx.amount;
        }
      }
    }
  }

  void _calculateRollovers() {
    // MVP Rollover implementation:
    // Only check the strictly preceding period (e.g. 1 month ago) 
    // and if there was unspent money, add it to this month's rolloverAmount.
    
    // Helper to get last period date
    DateTime getPreviousPeriod(LimitPeriod period, DateTime base) {
      switch (period) {
        case LimitPeriod.daily: return base.subtract(const Duration(days: 1));
        case LimitPeriod.weekly: return base.subtract(const Duration(days: 7));
        case LimitPeriod.monthly: return DateTime(base.year, base.month - 1, base.day);
        case LimitPeriod.quarterly: return DateTime(base.year, base.month - 3, base.day);
        case LimitPeriod.yearly: return DateTime(base.year - 1, base.month, base.day);
        case LimitPeriod.custom: return base; // Not supported
      }
    }

    for (var limit in _budget.categoryLimits.where((l) => l.allowRollover)) {
      final prevDate = getPreviousPeriod(limit.period, _currentViewDate);
      double prevSpent = 0.0;
      
      for (var tx in _transactions) {
        if (tx.type == TransactionType.expense && tx.category == limit.category) {
          if (_isDateInPeriod(tx.date, limit.period, limit.customStartDate, limit.customEndDate, prevDate)) {
            prevSpent += tx.amount;
          }
        }
      }
      
      if (limit.limitAmount > prevSpent) {
        limit.rolloverAmount = limit.limitAmount - prevSpent;
      }
    }

    // Similar for global
    for (var gl in _budget.globalLimits.where((l) => l.allowRollover)) {
      final prevDate = getPreviousPeriod(gl.period, _currentViewDate);
      double prevSpent = 0.0;
      
      for (var tx in _transactions) {
        if (tx.type == TransactionType.expense) {
          if (_isDateInPeriod(tx.date, gl.period, gl.customStartDate, gl.customEndDate, prevDate)) {
            prevSpent += tx.amount;
          }
        }
      }
      
      if (gl.limitAmount > prevSpent) {
        gl.rolloverAmount = gl.limitAmount - prevSpent;
      }
    }
  }

  bool _isDateInPeriod(DateTime date, LimitPeriod period, DateTime? customStart, DateTime? customEnd, DateTime reference) {
    switch (period) {
      case LimitPeriod.daily:
        return date.year == reference.year && date.month == reference.month && date.day == reference.day;
      case LimitPeriod.weekly:
        final weekStart = reference.subtract(Duration(days: reference.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        final normalizedDate = DateTime(date.year, date.month, date.day);
        final normalizedStart = DateTime(weekStart.year, weekStart.month, weekStart.day);
        final normalizedEnd = DateTime(weekEnd.year, weekEnd.month, weekEnd.day);
        return normalizedDate.compareTo(normalizedStart) >= 0 && normalizedDate.compareTo(normalizedEnd) <= 0;
      case LimitPeriod.monthly:
        return date.year == reference.year && date.month == reference.month;
      case LimitPeriod.quarterly:
        final currentQuarter = (reference.month - 1) ~/ 3;
        final txQuarter = (date.month - 1) ~/ 3;
        return date.year == reference.year && txQuarter == currentQuarter;
      case LimitPeriod.yearly:
        return date.year == reference.year;
      case LimitPeriod.custom:
        if (customStart != null && customEnd != null) {
          final normalizedDate = DateTime(date.year, date.month, date.day);
          final normalizedStart = DateTime(customStart.year, customStart.month, customStart.day);
          final normalizedEnd = DateTime(customEnd.year, customEnd.month, customEnd.day);
          return normalizedDate.compareTo(normalizedStart) >= 0 && normalizedDate.compareTo(normalizedEnd) <= 0;
        }
        return false;
    }
  }
}
