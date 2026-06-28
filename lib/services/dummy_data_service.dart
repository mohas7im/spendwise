import '../models/transaction.dart';
import '../models/income_source.dart';
import '../models/budget.dart';
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
    // Helper to get date at start of current week (Monday)
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final lastWeekStart = weekStart.subtract(const Duration(days: 7));

    return [
      // --- TODAY ---
      TransactionModel(id: 't1', title: 'Starbucks Coffee', amount: 340, date: now, category: 'Food & Drink', type: TransactionType.expense, paymentMethod: 'UPI'),
      TransactionModel(id: 't2', title: 'Metro Card Recharge', amount: 200, date: now, category: 'Transport', type: TransactionType.expense, paymentMethod: 'UPI'),
      TransactionModel(id: 't3', title: 'Salary Deposit', amount: 45000, date: now, category: 'Income', type: TransactionType.income, paymentMethod: 'Bank Transfer'),

      // --- THIS WEEK (but not today) ---
      TransactionModel(id: 't4', title: 'Swiggy Order – Biryani', amount: 480, date: weekStart.add(const Duration(days: 1, hours: 13)), category: 'Food & Drink', type: TransactionType.expense, paymentMethod: 'UPI'),
      TransactionModel(id: 't5', title: 'Big Bazaar Groceries', amount: 1250, date: weekStart.add(const Duration(days: 1, hours: 10)), category: 'Groceries', type: TransactionType.expense, paymentMethod: 'Card'),
      TransactionModel(id: 't6', title: 'Netflix Subscription', amount: 649, date: weekStart.add(const Duration(days: 2, hours: 9)), category: 'Entertainment', type: TransactionType.expense, paymentMethod: 'Card'),
      TransactionModel(id: 't7', title: 'Ola Cab Ride', amount: 230, date: weekStart.add(const Duration(days: 2, hours: 8)), category: 'Transport', type: TransactionType.expense, paymentMethod: 'UPI'),
      TransactionModel(id: 't8', title: 'Electricity Bill', amount: 1850, date: weekStart.add(const Duration(days: 3, hours: 11)), category: 'Bills', type: TransactionType.expense, paymentMethod: 'UPI'),
      TransactionModel(id: 't9', title: 'H&M T-Shirt', amount: 999, date: weekStart.add(const Duration(days: 3, hours: 15)), category: 'Shopping', type: TransactionType.expense, paymentMethod: 'Card'),
      TransactionModel(id: 't10', title: 'Pharmacy – Vitamins', amount: 380, date: weekStart.add(const Duration(days: 4, hours: 12)), category: 'Health', type: TransactionType.expense, paymentMethod: 'Cash'),
      TransactionModel(id: 't11', title: 'Zepto Groceries', amount: 875, date: weekStart.add(const Duration(days: 4, hours: 19)), category: 'Groceries', type: TransactionType.expense, paymentMethod: 'UPI'),

      // --- LAST WEEK ---
      TransactionModel(id: 't12', title: 'Dominos Pizza', amount: 620, date: lastWeekStart.add(const Duration(days: 0, hours: 20)), category: 'Food & Drink', type: TransactionType.expense, paymentMethod: 'UPI'),
      TransactionModel(id: 't13', title: 'Nykaa Skincare', amount: 1499, date: lastWeekStart.add(const Duration(days: 1, hours: 14)), category: 'Shopping', type: TransactionType.expense, paymentMethod: 'Card'),
      TransactionModel(id: 't14', title: 'Rapido Bike Taxi', amount: 95, date: lastWeekStart.add(const Duration(days: 2, hours: 9)), category: 'Transport', type: TransactionType.expense, paymentMethod: 'Cash'),
      TransactionModel(id: 't15', title: 'Water Bill', amount: 450, date: lastWeekStart.add(const Duration(days: 3, hours: 10)), category: 'Bills', type: TransactionType.expense, paymentMethod: 'UPI'),
      TransactionModel(id: 't16', title: 'PVR Cinemas', amount: 780, date: lastWeekStart.add(const Duration(days: 4, hours: 18)), category: 'Entertainment', type: TransactionType.expense, paymentMethod: 'Card'),
      TransactionModel(id: 't17', title: 'Apollo Pharmacy', amount: 260, date: lastWeekStart.add(const Duration(days: 5, hours: 11)), category: 'Health', type: TransactionType.expense, paymentMethod: 'Cash'),
      TransactionModel(id: 't18', title: 'Reliance Fresh', amount: 1100, date: lastWeekStart.add(const Duration(days: 6, hours: 8)), category: 'Groceries', type: TransactionType.expense, paymentMethod: 'Card'),
      TransactionModel(id: 't19', title: 'Freelance Payment', amount: 15000, date: lastWeekStart.add(const Duration(days: 2, hours: 16)), category: 'Income', type: TransactionType.income, paymentMethod: 'Bank Transfer'),

      // --- EARLIER THIS MONTH ---
      TransactionModel(id: 't20', title: 'SIP Investment', amount: 5000, date: now.subtract(const Duration(days: 18)), category: 'Invest', type: TransactionType.expense, paymentMethod: 'Bank Transfer'),
      TransactionModel(id: 't21', title: 'House Rent', amount: 12000, date: now.subtract(const Duration(days: 22)), category: 'Rent', type: TransactionType.expense, paymentMethod: 'Bank Transfer'),
      TransactionModel(id: 't22', title: 'Zomato Dinner', amount: 550, date: now.subtract(const Duration(days: 19)), category: 'Food & Drink', type: TransactionType.expense, paymentMethod: 'UPI'),
      TransactionModel(id: 't23', title: 'Amazon – Headphones', amount: 2499, date: now.subtract(const Duration(days: 20)), category: 'Shopping', type: TransactionType.expense, paymentMethod: 'Card'),
      TransactionModel(id: 't24', title: 'Internet Bill', amount: 799, date: now.subtract(const Duration(days: 21)), category: 'Bills', type: TransactionType.expense, paymentMethod: 'UPI'),

      // --- LAST MONTH ---
      TransactionModel(id: 't25', title: 'Gym Membership', amount: 1500, date: now.subtract(const Duration(days: 35)), category: 'Health', type: TransactionType.expense, paymentMethod: 'Card'),
      TransactionModel(id: 't26', title: 'Flipkart Sale', amount: 3200, date: now.subtract(const Duration(days: 38)), category: 'Shopping', type: TransactionType.expense, paymentMethod: 'Card'),
      TransactionModel(id: 't27', title: 'Cab to Airport', amount: 850, date: now.subtract(const Duration(days: 40)), category: 'Transport', type: TransactionType.expense, paymentMethod: 'Cash'),
      TransactionModel(id: 't28', title: 'Medical Checkup', amount: 1200, date: now.subtract(const Duration(days: 45)), category: 'Health', type: TransactionType.expense, paymentMethod: 'Card'),
      TransactionModel(id: 't29', title: 'Mutual Fund', amount: 3000, date: now.subtract(const Duration(days: 32)), category: 'Invest', type: TransactionType.expense, paymentMethod: 'Bank Transfer'),
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
        CategoryLimit(id: 'cl1', category: 'Food', emoji: '🍔', limitAmount: 15000, period: LimitPeriod.monthly, spentAmount: 12000, allowRollover: false),
        CategoryLimit(id: 'cl2', category: 'Transport', emoji: '🚗', limitAmount: 5000, period: LimitPeriod.monthly, spentAmount: 4800, allowRollover: false),
        CategoryLimit(id: 'cl3', category: 'Shopping', emoji: '🛍️', limitAmount: 10000, period: LimitPeriod.monthly, spentAmount: 11500, allowRollover: false),
        CategoryLimit(id: 'cl4', category: 'Entertainment', emoji: '🍿', limitAmount: 4000, period: LimitPeriod.monthly, spentAmount: 2000, allowRollover: true), // Intentionally overbudget
        // Weekly Limits
        CategoryLimit(id: 'cl5', category: 'Food & Drink', emoji: '🍔', limitAmount: 750, period: LimitPeriod.weekly, spentAmount: 450, allowRollover: false),
        CategoryLimit(id: 'cl6', category: 'Transport', emoji: '🚕', limitAmount: 350, period: LimitPeriod.weekly, spentAmount: 150, allowRollover: false),
        // Daily Limits
        CategoryLimit(id: 'cl7', category: 'Food & Drink', emoji: '🍔', limitAmount: 100, period: LimitPeriod.daily, spentAmount: 40, allowRollover: false),
      ],
      savingsGoals: [
        SavingsGoal(id: 'sg1', name: 'Vacation Fund', targetAmount: 50000, currentAmount: 15000, startDate: DateTime.now().subtract(const Duration(days: 60)), targetDate: DateTime.now().add(const Duration(days: 120))),
        SavingsGoal(id: 'sg2', name: 'Emergency Fund', targetAmount: 100000, currentAmount: 85000, startDate: DateTime.now().subtract(const Duration(days: 180)), targetDate: DateTime.now().add(const Duration(days: 30))),
        SavingsGoal(id: 'sg3', name: 'New Laptop', targetAmount: 80000, currentAmount: 20000, startDate: DateTime.now().subtract(const Duration(days: 30)), targetDate: DateTime.now().add(const Duration(days: 90))),
      ],
      globalLimits: [
        GlobalBudgetLimit(id: 'gl1', limitAmount: 40000, period: LimitPeriod.monthly, spentAmount: 25000),
        GlobalBudgetLimit(id: 'gl2', limitAmount: 10000, period: LimitPeriod.weekly, spentAmount: 7500),
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
