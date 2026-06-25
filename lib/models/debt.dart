class DebtModel {
  final String id;
  final String personName;
  final double amount;
  final DebtType type;
  final DateTime date;
  final String? note;
  bool isPaid;

  DebtModel({
    required this.id,
    required this.personName,
    required this.amount,
    required this.type,
    required this.date,
    this.note,
    this.isPaid = false,
  });
}

/// I_OWE = I owe money to this person
/// THEY_OWE = This person owes me money
enum DebtType { iOwe, theyOwe }
