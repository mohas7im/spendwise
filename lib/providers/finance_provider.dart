import 'package:flutter/material.dart';
import '../models/debt.dart';
import '../services/dummy_data_service.dart';
import '../models/income_source.dart';

class FinanceProvider extends ChangeNotifier {
  double _totalBalance = 24500.00;
  List<DebtModel> _debts = [];
  List<IncomeSource> _incomeSources = [];

  FinanceProvider() {
    _debts = DummyDataService.getDummyDebts();
    _incomeSources = [
      IncomeSource(id: 'inc1', name: 'Primary Salary', amount: 45000, type: IncomeType.salary, frequency: IncomeFrequency.monthly, creditDate: 25),
      IncomeSource(id: 'inc2', name: 'Freelance Design', amount: 15000, type: IncomeType.freelance, frequency: IncomeFrequency.monthly, creditDate: 28),
    ];
  }

  double get totalBalance => _totalBalance;
  List<DebtModel> get debts => _debts;
  List<IncomeSource> get incomeSources => _incomeSources;

  void recordDebtPayment(String debtId, double paymentAmount, {PaymentStatus status = PaymentStatus.paid, String? note}) {
    final debtIndex = _debts.indexWhere((d) => d.id == debtId);
    if (debtIndex == -1) return;

    final debt = _debts[debtIndex];
    
    // Ensure we don't overpay for paid status (unless partial)
    final amountToPay = paymentAmount > debt.remainingAmount ? debt.remainingAmount : paymentAmount;
    
    final payment = DebtPayment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      amount: amountToPay,
      status: status,
      note: note,
    );
    
    debt.paymentHistory.add(payment);

    // Advance next due date if it's a structured loan/EMI and the payment was successful
    if (debt.nextDueDate != null && status == PaymentStatus.paid) {
      debt.nextDueDate = DateTime(
        debt.nextDueDate!.year, 
        debt.nextDueDate!.month + 1, 
        debt.nextDueDate!.day
      );
    }

    if (status == PaymentStatus.paid || status == PaymentStatus.partial) {
      if (debt.type == DebtType.iOwe || debt.type == DebtType.loanTaken || debt.type == DebtType.emiLoan) {
        _totalBalance -= amountToPay;
      } else {
        _totalBalance += amountToPay;
      }
    }

    notifyListeners();
  }

  void addDebt(DebtModel debt) {
    _debts.add(debt);
    notifyListeners();
  }

  void addIncomeSource(IncomeSource source) {
    _incomeSources.add(source);
    notifyListeners();
  }

  void updateIncomeSource(IncomeSource source) {
    final index = _incomeSources.indexWhere((s) => s.id == source.id);
    if (index != -1) {
      _incomeSources[index] = source;
      notifyListeners();
    }
  }

  void deleteIncomeSource(String id) {
    _incomeSources.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  List<IncomeSource> getPendingIncomes() {
    final now = DateTime.now();
    return _incomeSources.where((inc) {
      if (inc.creditDate == null || inc.frequency != IncomeFrequency.monthly) return false;
      
      // Check if already credited this month
      if (inc.lastCredited != null && inc.lastCredited!.month == now.month && inc.lastCredited!.year == now.year) {
        return false;
      }

      // Check if we are within 2 days of credit date
      // We will handle edge cases simply for now
      final expectedDate = DateTime(now.year, now.month, inc.creditDate!);
      final diff = expectedDate.difference(now).inDays;
      
      return diff >= -2 && diff <= 2; // Show if within a +/- 2 days window
    }).toList();
  }

  void creditIncome(String id, double actualAmount) {
    final index = _incomeSources.indexWhere((s) => s.id == id);
    if (index != -1) {
      final inc = _incomeSources[index];
      _incomeSources[index] = inc.copyWith(lastCredited: DateTime.now());
      _totalBalance += actualAmount;
      // TODO: Log transaction history here if needed
      notifyListeners();
    }
  }
}

