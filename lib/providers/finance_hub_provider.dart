import 'package:flutter/material.dart';
import '../models/finance_module_models.dart';

class FinanceHubProvider extends ChangeNotifier {
  final List<DebtItem> _debts = [];
  final List<SavingsGoalItem> _savingsGoals = [];



  List<DebtItem> get debts => [..._debts];
  List<SavingsGoalItem> get savingsGoals => [..._savingsGoals];

  // --- Debts ---
  void addDebt(DebtItem debt) {
    _debts.add(debt);
    notifyListeners();
  }
  void updateDebt(DebtItem debt) {
    final idx = _debts.indexWhere((d) => d.id == debt.id);
    if (idx >= 0) {
      _debts[idx] = debt;
      notifyListeners();
    }
  }
  void deleteDebt(String id) {
    _debts.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  // --- Savings Goals ---
  void addSavingsGoal(SavingsGoalItem goal) {
    _savingsGoals.add(goal);
    notifyListeners();
  }
  void updateSavingsGoal(SavingsGoalItem goal) {
    final idx = _savingsGoals.indexWhere((g) => g.id == goal.id);
    if (idx >= 0) {
      _savingsGoals[idx] = goal;
      notifyListeners();
    }
  }
  void deleteSavingsGoal(String id) {
    _savingsGoals.removeWhere((g) => g.id == id);
    notifyListeners();
  }


}
