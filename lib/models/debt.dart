class DebtModel {
  final String id;
  final String personName;
  final double amount;
  double repaidAmount;
  final DebtType type;
  final DateTime date;
  final String? note;

  DebtModel({
    required this.id,
    required this.personName,
    required this.amount,
    this.repaidAmount = 0.0,
    required this.type,
    required this.date,
    this.note,
  });

  double get remainingAmount => amount - repaidAmount;
  bool get isPaid => repaidAmount >= amount;
}

/// I_OWE = I owe money to this person
/// THEY_OWE = This person owes me money
enum DebtType { iOwe, theyOwe }
