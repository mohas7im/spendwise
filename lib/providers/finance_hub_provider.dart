import 'package:flutter/material.dart';
import '../models/finance_module_models.dart';

class FinanceHubProvider extends ChangeNotifier {
  final List<DebtItem> _debts = [
    DebtItem(
      id: 'd1',
      name: 'Sarah Connor',
      type: 'They Owe Me',
      totalAmount: 5000,
      paidAmount: 2500,
      dueDate: '15 Aug 2026',
    ),
    DebtItem(
      id: 'd2',
      name: 'HDFC Car Loan',
      type: 'I Owe',
      totalAmount: 500000,
      paidAmount: 120000,
      dueDate: '5th of Every Month',
    ),
  ];

  final List<SavingsGoalItem> _savingsGoals = [
    SavingsGoalItem(
      id: 'g1',
      name: 'New Car',
      targetAmount: 800000,
      currentSaved: 350000,
      deadline: 'Dec 2026',
      colorValue: Colors.blue.toARGB32(),
    ),
  ];

  final List<SavingsGrowthItem> _growthItems = [
    SavingsGrowthItem(
      id: 'gr1',
      name: 'HDFC Fixed Deposit',
      type: 'Fixed Deposit',
      principal: 100000,
      currentAmount: 112000,
      returnRate: 7.1,
      colorValue: Colors.green.toARGB32(),
    ),
  ];

  List<DebtItem> get debts => [..._debts];
  List<SavingsGoalItem> get savingsGoals => [..._savingsGoals];
  List<SavingsGrowthItem> get growthItems => [..._growthItems];

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

  // --- Savings Growth ---
  void addGrowthItem(SavingsGrowthItem item) {
    _growthItems.add(item);
    notifyListeners();
  }
  void updateGrowthItem(SavingsGrowthItem item) {
    final idx = _growthItems.indexWhere((i) => i.id == item.id);
    if (idx >= 0) {
      _growthItems[idx] = item;
      notifyListeners();
    }
  }
  void deleteGrowthItem(String id) {
    _growthItems.removeWhere((i) => i.id == id);
    notifyListeners();
  }
}
