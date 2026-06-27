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

  SavingsGoalItem({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentSaved,
    required this.deadline,
    this.notes = '',
    required this.colorValue,
  });

  SavingsGoalItem copyWith({
    String? name,
    double? targetAmount,
    double? currentSaved,
    String? deadline,
    String? notes,
    int? colorValue,
  }) {
    return SavingsGoalItem(
      id: id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentSaved: currentSaved ?? this.currentSaved,
      deadline: deadline ?? this.deadline,
      notes: notes ?? this.notes,
      colorValue: colorValue ?? this.colorValue,
    );
  }
}

class SavingsGrowthItem {
  final String id;
  final String name;
  final String type; // 'Fixed Deposit', 'Mutual Fund', 'Stock', 'Other'
  final double principal;
  final double currentAmount;
  final double returnRate; // Percentage
  final String notes;
  final int colorValue;

  SavingsGrowthItem({
    required this.id,
    required this.name,
    required this.type,
    required this.principal,
    required this.currentAmount,
    required this.returnRate,
    this.notes = '',
    required this.colorValue,
  });

  SavingsGrowthItem copyWith({
    String? name,
    String? type,
    double? principal,
    double? currentAmount,
    double? returnRate,
    String? notes,
    int? colorValue,
  }) {
    return SavingsGrowthItem(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      principal: principal ?? this.principal,
      currentAmount: currentAmount ?? this.currentAmount,
      returnRate: returnRate ?? this.returnRate,
      notes: notes ?? this.notes,
      colorValue: colorValue ?? this.colorValue,
    );
  }
}
