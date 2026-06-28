import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/debt.dart';
import '../services/dummy_data_service.dart';
import '../models/income_source.dart';
import '../models/transaction.dart';
import '../models/subscription.dart';
import '../models/category.dart';
import '../services/db_helper.dart';
import '../services/notification_service.dart';

class FinanceProvider extends ChangeNotifier {
  double _totalBalance = 24500.00;
  List<DebtModel> _debts = [];
  List<IncomeSource> _incomeSources = [];
  List<TransactionModel> _transactions = [];
  List<SubscriptionModel> _subscriptions = [];
  List<CategoryModel> _categories = [];

  FinanceProvider() {
    if (!kReleaseMode) {
      _debts = DummyDataService.getDummyDebts();
      _incomeSources = [
        IncomeSource(id: 'inc1', name: 'Primary Salary', amount: 45000, type: IncomeType.salary, frequency: IncomeFrequency.monthly, creditDate: 25),
        IncomeSource(id: 'inc2', name: 'Freelance Design', amount: 15000, type: IncomeType.freelance, frequency: IncomeFrequency.monthly, creditDate: 28),
      ];
      _transactions = DummyDataService.getDummyTransactions();
    } else {
      _totalBalance = 0.0;
    }
    _initCategories();
    _initSubscriptions();
  }

  void _initCategories() {
    _categories = [
      CategoryModel(id: 'cat_food', name: 'Food & Drink', emoji: '🍔', color: Colors.orange),
      CategoryModel(id: 'cat_groceries', name: 'Groceries', emoji: '🛒', color: Colors.green),
      CategoryModel(id: 'cat_rent', name: 'Rent', emoji: '🏠', color: Colors.blue),
      CategoryModel(id: 'cat_transport', name: 'Transport', emoji: '🚕', color: Colors.purple),
      CategoryModel(id: 'cat_shopping', name: 'Shopping', emoji: '🛍️', color: Colors.pink),
      CategoryModel(id: 'cat_entertainment', name: 'Entertainment', emoji: '🎬', color: Colors.red),
      CategoryModel(id: 'cat_health', name: 'Health', emoji: '💊', color: Colors.teal),
      CategoryModel(id: 'cat_bills', name: 'Bills', emoji: '📄', color: Colors.amber),
      CategoryModel(id: 'cat_invest', name: 'Invest', emoji: '📈', color: Colors.indigo),
      CategoryModel(id: 'cat_income', name: 'Income', emoji: '💰', color: Colors.lightGreen),
      CategoryModel(id: 'cat_other', name: 'Other', emoji: '📦', color: Colors.grey),
    ];
  }

  Future<void> _initSubscriptions() async {
    _subscriptions = await DatabaseHelper().getSubscriptions();
    final now = DateTime.now();
    bool needsNotify = false;

    for (var sub in _subscriptions) {
      if (!sub.isPaused && sub.nextBilling.isBefore(now)) {
        // Auto-deduct missed payments
        while (sub.nextBilling.isBefore(now)) {
          _totalBalance -= sub.cost;
          sub.paymentHistory.add(SubscriptionPayment(date: sub.nextBilling, amount: sub.cost));
          
          if (sub.cycle == 'Monthly') {
            sub.nextBilling = DateTime(sub.nextBilling.year, sub.nextBilling.month + 1, sub.nextBilling.day);
          } else if (sub.cycle == 'Yearly') {
            sub.nextBilling = DateTime(sub.nextBilling.year + 1, sub.nextBilling.month, sub.nextBilling.day);
          } else {
            sub.nextBilling = sub.nextBilling.add(Duration(days: sub.customDays ?? 30));
          }
        }
        await DatabaseHelper().updateSubscription(sub);
        needsNotify = true;
      }
      // Reschedule reminders
      NotificationService().scheduleSubscriptionReminder(sub);
    }
    
    if (needsNotify) notifyListeners();
  }

  double get totalBalance => _totalBalance;
  List<DebtModel> get debts => _debts;
  List<IncomeSource> get incomeSources => _incomeSources;
  List<TransactionModel> get transactions => _transactions;
  List<SubscriptionModel> get subscriptions => _subscriptions;
  List<CategoryModel> get categories => _categories;

  void addCategory(CategoryModel category) {
    _categories.add(category);
    notifyListeners();
  }

  void updateCategory(CategoryModel category) {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      notifyListeners();
    }
  }

  void deleteCategory(String id) {
    _categories.removeWhere((c) => c.id == id);
    notifyListeners();
  }

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

  Future<void> addSubscription(SubscriptionModel sub) async {
    _subscriptions.add(sub);
    await DatabaseHelper().insertSubscription(sub);
    NotificationService().scheduleSubscriptionReminder(sub);
    notifyListeners();
  }

  Future<void> updateSubscription(String id, SubscriptionModel sub) async {
    final index = _subscriptions.indexWhere((s) => s.id == id);
    if (index != -1) {
      _subscriptions[index] = sub;
      await DatabaseHelper().updateSubscription(sub);
      NotificationService().cancelReminder(id);
      NotificationService().scheduleSubscriptionReminder(sub);
      notifyListeners();
    }
  }

  Future<void> deleteSubscription(String id) async {
    _subscriptions.removeWhere((s) => s.id == id);
    await DatabaseHelper().deleteSubscription(id);
    NotificationService().cancelReminder(id);
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
      _transactions.add(TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: inc.name,
        amount: actualAmount,
        date: DateTime.now(),
        category: 'Income',
        type: TransactionType.income,
      ));
      notifyListeners();
    }
  }

  // ─── TRANSACTION CRUD ────────────────────────────────────────────────────────
  void addTransaction(TransactionModel tx) {
    _transactions.add(tx);
    if (tx.type == TransactionType.income) {
      _totalBalance += tx.amount;
    } else {
      _totalBalance -= tx.amount;
    }
    notifyListeners();
  }

  void deleteTransaction(String id) {
    final tx = _transactions.firstWhere((t) => t.id == id, orElse: () => throw Exception('Not found'));
    if (tx.type == TransactionType.income) {
      _totalBalance -= tx.amount;
    } else {
      _totalBalance += tx.amount;
    }
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void updateTransaction(TransactionModel updated) {
    final index = _transactions.indexWhere((t) => t.id == updated.id);
    if (index == -1) return;
    final old = _transactions[index];
    // Reverse old effect
    if (old.type == TransactionType.income) {
      _totalBalance -= old.amount;
    } else {
      _totalBalance += old.amount;
    }
    // Apply new effect
    if (updated.type == TransactionType.income) {
      _totalBalance += updated.amount;
    } else {
      _totalBalance -= updated.amount;
    }
    _transactions[index] = updated;
    notifyListeners();
  }

  // ─── PERIOD HELPERS ──────────────────────────────────────────────────────────
  List<TransactionModel> _expensesInRange(DateTime start, DateTime end) {
    return _transactions.where((t) {
      final d = DateTime(t.date.year, t.date.month, t.date.day);
      final s = DateTime(start.year, start.month, start.day);
      final e = DateTime(end.year, end.month, end.day);
      return t.type == TransactionType.expense &&
          !d.isBefore(s) && !d.isAfter(e);
    }).toList();
  }


  double _totalFor(List<TransactionModel> txs) => txs.fold(0.0, (s, t) => s + t.amount);

  /// Percentage change of [current] vs [prior]. Returns null if prior is 0.
  double? percentageChange(double current, double prior) {
    if (prior == 0) return null;
    return ((current - prior) / prior) * 100;
  }

  // ─── PERIOD TRANSACTION LISTS ─────────────────────────────────────────────
  List<TransactionModel> get transactionsToday {
    final now = DateTime.now();
    return _expensesInRange(now, now);
  }

  List<TransactionModel> get transactionsThisWeek {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    return _expensesInRange(start, now);
  }

  List<TransactionModel> get transactionsThisMonth {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    return _expensesInRange(start, now);
  }

  List<TransactionModel> get transactionsThisYear {
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    return _expensesInRange(start, now);
  }

  List<TransactionModel> get transactionsAllTime {
    return _transactions.where((t) => t.type == TransactionType.expense).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // ─── PERIOD METADATA ─────────────────────────────────────────────────────
  Map<String, dynamic> spendingSummary(String period) {
    final now = DateTime.now();
    DateTime start, end, priorStart, priorEnd;

    switch (period) {
      case 'Today':
        start = end = now;
        priorStart = priorEnd = now.subtract(const Duration(days: 1));
        break;
      case 'This Week':
        start = now.subtract(Duration(days: now.weekday - 1));
        end = now;
        priorEnd = start.subtract(const Duration(days: 1));
        priorStart = priorEnd.subtract(Duration(days: now.weekday - 1));
        break;
      case 'This Month':
        start = DateTime(now.year, now.month, 1);
        end = now;
        priorEnd = start.subtract(const Duration(days: 1));
        priorStart = DateTime(priorEnd.year, priorEnd.month, 1);
        break;
      case 'This Year':
        start = DateTime(now.year, 1, 1);
        end = now;
        priorEnd = DateTime(now.year - 1, 12, 31);
        priorStart = DateTime(now.year - 1, 1, 1);
        break;
      case 'All Time':
      default:
        final txs = transactionsAllTime;
        final total = _totalFor(txs);
        return {
          'total': total,
          'count': txs.length,
          'pctChange': null,
          'transactions': txs,
          'categoryBreakdown': _categoryBreakdown(txs),
        };
    }

    final current = _expensesInRange(start, end);
    final prior = _expensesInRange(priorStart, priorEnd);
    final currentTotal = _totalFor(current);
    final priorTotal = _totalFor(prior);

    return {
      'total': currentTotal,
      'count': current.length,
      'pctChange': percentageChange(currentTotal, priorTotal),
      'transactions': current,
      'categoryBreakdown': _categoryBreakdown(current),
    };
  }

  Map<String, Map<String, dynamic>> _categoryBreakdown(List<TransactionModel> txs) {
    final Map<String, Map<String, dynamic>> result = {};
    for (final tx in txs) {
      if (!result.containsKey(tx.category)) {
        result[tx.category] = {'total': 0.0, 'count': 0, 'transactions': <TransactionModel>[]};
      }
      result[tx.category]!['total'] = (result[tx.category]!['total'] as double) + tx.amount;
      result[tx.category]!['count'] = (result[tx.category]!['count'] as int) + 1;
      (result[tx.category]!['transactions'] as List<TransactionModel>).add(tx);
    }
    return result;
  }

  // ─── ANALYTICS GETTERS ────────────────────────────────────────────────────
  // Analytics & Summary Getters
  double get totalIncome => _transactions.where((t) => t.type == TransactionType.income).fold(0, (s, t) => s + t.amount);
  double get totalExpenses => _transactions.where((t) => t.type == TransactionType.expense).fold(0, (s, t) => s + t.amount);
  double get totalSavings => totalIncome - totalExpenses;

  double get spendingToday {
    return _totalFor(transactionsToday);
  }

  double get spendingThisWeek => _totalFor(transactionsThisWeek);
  double get spendingThisMonth => _totalFor(transactionsThisMonth);
  double get spendingThisYear => _totalFor(transactionsThisYear);

  // Unified Activity Feed
  List<ActivityItem> get recentActivity {
    List<ActivityItem> activities = [];

    for (var t in _transactions) {
      activities.add(ActivityItem(
        id: t.id,
        title: t.title,
        subtitle: t.category,
        amount: t.amount,
        date: t.date,
        type: t.type == TransactionType.income ? ActivityType.income : ActivityType.transaction,
        isCredit: t.type == TransactionType.income,
      ));
    }

    for (var d in _debts) {
      for (var p in d.paymentHistory) {
        bool isCredit = (d.type == DebtType.theyOwe || d.type == DebtType.loanGiven);
        activities.add(ActivityItem(
          id: p.id,
          title: d.personName,
          subtitle: '${d.type.name.toUpperCase()} Payment',
          amount: p.amount,
          date: p.date,
          type: ActivityType.debtPayment,
          isCredit: isCredit,
        ));
      }
    }

    activities.sort((a, b) => b.date.compareTo(a.date));
    return activities;
  }
}

