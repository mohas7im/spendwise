import 'package:flutter/material.dart';
import '../models/debt.dart';
import '../services/dummy_data_service.dart';

class FinanceProvider extends ChangeNotifier {
  double _totalBalance = 24500.00;
  List<DebtModel> _debts = [];

  FinanceProvider() {
    _debts = DummyDataService.getDummyDebts();
  }

  double get totalBalance => _totalBalance;
  List<DebtModel> get debts => _debts;

  void recordDebtPayment(String debtId, double paymentAmount) {
    final debtIndex = _debts.indexWhere((d) => d.id == debtId);
    if (debtIndex == -1) return;

    final debt = _debts[debtIndex];
    
    // Ensure we don't overpay
    final amountToPay = paymentAmount > debt.remainingAmount ? debt.remainingAmount : paymentAmount;
    
    debt.repaidAmount += amountToPay;

    // If I owe money, repaying it decreases my main balance.
    // If they owe money, repaying it increases my main balance.
    if (debt.type == DebtType.iOwe) {
      _totalBalance -= amountToPay;
    } else {
      _totalBalance += amountToPay;
    }

    notifyListeners();
  }

  void addDebt(DebtModel debt) {
    _debts.add(debt);
    notifyListeners();
  }
}

