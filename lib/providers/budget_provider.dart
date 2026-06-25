import 'package:flutter/material.dart';
import '../models/budget.dart';
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

  void updateBudget(BudgetModel newBudget) {
    _budget = newBudget;
    notifyListeners();
  }
}
