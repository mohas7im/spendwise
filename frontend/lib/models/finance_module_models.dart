class DebtItem {
  final String id;
  final String name;
  final String type; // 'I Owe', 'They Owe Me', 'EMI'
  final double totalAmount;
  final double paidAmount;
  final String dueDate;
  final String notes;
  final double interestRate;
  final double emiAmount;
  final int tenureMonths;
  final List<Map<String, dynamic>> paymentHistory;

  DebtItem({
    required this.id,
    required this.name,
    required this.type,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueDate,
    this.notes = '',
    this.interestRate = 0.0,
    this.emiAmount = 0.0,
    this.tenureMonths = 0,
    this.paymentHistory = const [],
  });

  DebtItem copyWith({
    String? name,
    String? type,
    double? totalAmount,
    double? paidAmount,
    String? dueDate,
    String? notes,
    double? interestRate,
    double? emiAmount,
    int? tenureMonths,
    List<Map<String, dynamic>>? paymentHistory,
  }) {
    return DebtItem(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
      interestRate: interestRate ?? this.interestRate,
      emiAmount: emiAmount ?? this.emiAmount,
      tenureMonths: tenureMonths ?? this.tenureMonths,
      paymentHistory: paymentHistory ?? this.paymentHistory,
    );
  }
}

class SavingsGoalItem {
  final String id;
  final String name;
  final double targetAmount;
  final double currentSaved;
  final String deadline;
  final String notes;
  final int colorValue;
  final List<Map<String, dynamic>> depositHistory;

  SavingsGoalItem({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentSaved,
    required this.deadline,
    this.notes = '',
    required this.colorValue,
    this.depositHistory = const [],
  });

  SavingsGoalItem copyWith({
    String? name,
    double? targetAmount,
    double? currentSaved,
    String? deadline,
    String? notes,
    int? colorValue,
    List<Map<String, dynamic>>? depositHistory,
  }) {
    return SavingsGoalItem(
      id: id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentSaved: currentSaved ?? this.currentSaved,
      deadline: deadline ?? this.deadline,
      notes: notes ?? this.notes,
      colorValue: colorValue ?? this.colorValue,
      depositHistory: depositHistory ?? this.depositHistory,
    );
  }
}
