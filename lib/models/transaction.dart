enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final TransactionType type;
  final String paymentMethod;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
    this.paymentMethod = 'Cash',
  });
}

enum ActivityType { transaction, debtPayment, income, settlement }

class ActivityItem {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final DateTime date;
  final ActivityType type;
  final bool isCredit; // true if money coming in (Income, Someone paid me), false if money going out (Expense, I paid someone)

  ActivityItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.type,
    required this.isCredit,
  });
}
