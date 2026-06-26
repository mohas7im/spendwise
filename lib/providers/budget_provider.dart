import 'package:flutter/material.dart';
import '../models/budget.dart';
import '../models/transaction.dart';
import '../services/dummy_data_service.dart';

class BudgetProvider with ChangeNotifier {
  late BudgetModel _budget;

  BudgetProvider() {
    _budget = DummyDataService.getDummyBudget();
  }

  BudgetModel get budget => _budget;

  void addCategoryLimit(CategoryLimit limit) {
    _budget.categoryLimits.add(limit);
    notifyListeners();
  }

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

  void recalculateSpending(List<TransactionModel> transactions) {
    for (var limit in _budget.categoryLimits) {
      limit.spentAmount = 0;
    }
    for (var gl in _budget.globalLimits) {
      gl.spentAmount = 0;
    }

    final now = DateTime.now();
    for (var tx in transactions) {
      if (tx.type != TransactionType.expense) continue;

      for (var limit in _budget.categoryLimits.where((l) => l.category == tx.category)) {
        if (_isDateInPeriod(tx.date, limit.period, limit.customStartDate, limit.customEndDate, now)) {
          limit.spentAmount += tx.amount;
        }
      }
      
      for (var gl in _budget.globalLimits) {
        if (_isDateInPeriod(tx.date, gl.period, gl.customStartDate, gl.customEndDate, now)) {
          gl.spentAmount += tx.amount;
        }
      }
    }
    // We intentionally do not call notifyListeners() here if this is called during build 
    // to avoid infinite loops, but since it modifies state, it should be called outside build phase.
  }

  bool _isDateInPeriod(DateTime date, LimitPeriod period, DateTime? customStart, DateTime? customEnd, DateTime now) {
    switch (period) {
      case LimitPeriod.daily:
        return date.year == now.year && date.month == now.month && date.day == now.day;
      case LimitPeriod.weekly:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        final normalizedDate = DateTime(date.year, date.month, date.day);
        final normalizedStart = DateTime(weekStart.year, weekStart.month, weekStart.day);
        final normalizedEnd = DateTime(weekEnd.year, weekEnd.month, weekEnd.day);
        return normalizedDate.compareTo(normalizedStart) >= 0 && normalizedDate.compareTo(normalizedEnd) <= 0;
      case LimitPeriod.monthly:
        return date.year == now.year && date.month == now.month;
      case LimitPeriod.quarterly:
        final currentQuarter = (now.month - 1) ~/ 3;
        final txQuarter = (date.month - 1) ~/ 3;
        return date.year == now.year && txQuarter == currentQuarter;
      case LimitPeriod.yearly:
        return date.year == now.year;
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
