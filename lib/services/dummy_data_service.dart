import '../models/transaction.dart';
import '../models/income_source.dart';
import '../models/budget.dart' hide IncomeFrequency; // IncomeFrequency comes from income_source.dart
import '../models/debt.dart';

class DummyDataService {
  static List<IncomeSource> getDummyIncomes() {
    return [
      IncomeSource(id: '1', name: 'Company Salary', amount: 15000, type: IncomeType.salary, frequency: IncomeFrequency.monthly),
      IncomeSource(id: '2', name: 'Freelance Design', amount: 3000, type: IncomeType.freelance, frequency: IncomeFrequency.monthly),
    ];
  }

  static List<TransactionModel> getDummyTransactions() {
    final now = DateTime.now();
    return [
      TransactionModel(id: 't1', title: 'Starbucks Reserve', amount: 8.40, date: now, category: 'Food & Drink', type: TransactionType.expense),
      TransactionModel(id: 't2', title: 'Salary Deposit', amount: 15000, date: now, category: 'Income', type: TransactionType.income),
      TransactionModel(id: 't3', title: 'Whole Foods Market', amount: 67.84, date: now.subtract(const Duration(days: 1)), category: 'Groceries', type: TransactionType.expense),
      TransactionModel(id: 't4', title: 'Swiggy Order', amount: 340, date: now.subtract(const Duration(days: 1)), category: 'Food & Drink', type: TransactionType.expense),
      TransactionModel(id: 't5', title: 'Netflix', amount: 499, date: now.subtract(const Duration(days: 2)), category: 'Entertainment', type: TransactionType.expense),
      TransactionModel(id: 't6', title: 'Electricity Bill', amount: 1200, date: now.subtract(const Duration(days: 3)), category: 'Bills', type: TransactionType.expense),
    ];
  }

  static BudgetModel getDummyBudget() {
    return BudgetModel(
      monthlySalary: 15000,
      incomes: [
        const IncomeEntry(source: 'Company Salary', amount: 15000, frequency: IncomeFrequency.monthly),
        const IncomeEntry(source: 'Freelance', amount: 3000, frequency: IncomeFrequency.monthly),
      ],
      categoryLimits: [
        CategoryLimit(category: 'Food & Dining', emoji: '🍔', limitAmount: 3000, period: LimitPeriod.monthly, spentAmount: 1840),
        CategoryLimit(category: 'Groceries', emoji: '🛒', limitAmount: 2000, period: LimitPeriod.monthly, spentAmount: 1200),
        CategoryLimit(category: 'Entertainment', emoji: '🎬', limitAmount: 1000, period: LimitPeriod.monthly, spentAmount: 499),
        CategoryLimit(category: 'Transport', emoji: '🚕', limitAmount: 1500, period: LimitPeriod.monthly, spentAmount: 600),
        CategoryLimit(category: 'Bills', emoji: '📄', limitAmount: 3000, period: LimitPeriod.monthly, spentAmount: 1200),
        CategoryLimit(category: 'Shopping', emoji: '🛍️', limitAmount: 2000, period: LimitPeriod.monthly, spentAmount: 2150), // Intentionally overbudget
      ],
      savingsGoals: [
        SavingsGoal(id: 'sg1', name: 'Vacation Fund', targetAmount: 50000, currentAmount: 15000, startDate: DateTime.now().subtract(const Duration(days: 60)), targetDate: DateTime.now().add(const Duration(days: 120))),
        SavingsGoal(id: 'sg2', name: 'Emergency Fund', targetAmount: 100000, currentAmount: 85000, startDate: DateTime.now().subtract(const Duration(days: 180)), targetDate: DateTime.now().add(const Duration(days: 30))),
        SavingsGoal(id: 'sg3', name: 'New Laptop', targetAmount: 80000, currentAmount: 20000, startDate: DateTime.now().subtract(const Duration(days: 30)), targetDate: DateTime.now().add(const Duration(days: 90))),
      ],
      globalLimits: [
        GlobalBudgetLimit(limitAmount: 40000, period: LimitPeriod.monthly, spentAmount: 25000),
        GlobalBudgetLimit(limitAmount: 10000, period: LimitPeriod.weekly, spentAmount: 7500),
      ],
    );
  }

  static List<DebtModel> getDummyDebts() {
    final now = DateTime.now();
    return [
      DebtModel(id: 'd1', personName: 'Rahul Kumar', amount: 2500, type: DebtType.theyOwe, date: now.subtract(const Duration(days: 5)), note: 'Lunch split'),
      DebtModel(id: 'd2', personName: 'Priya Sharma', amount: 1000, type: DebtType.iOwe, date: now.subtract(const Duration(days: 12)), note: 'Movie tickets'),
      DebtModel(id: 'd3', personName: 'Arjun Singh', amount: 500, type: DebtType.theyOwe, date: now.subtract(const Duration(days: 2)), note: 'Petrol money'),
      DebtModel(id: 'd4', personName: 'Mom', amount: 5000, type: DebtType.iOwe, date: now.subtract(const Duration(days: 30)), note: 'Emergency'),
    ];
  }
}
