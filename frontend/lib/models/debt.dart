enum DebtType { iOwe, theyOwe, loanGiven, loanTaken, emiLoan }

enum PaymentStatus { paid, missed, partial }

class DebtPayment {
  final String id;
  final DateTime date;
  final double amount;
  final PaymentStatus status;
  final String? note;

  DebtPayment({
    required this.id,
    required this.date,
    required this.amount,
    this.status = PaymentStatus.paid,
    this.note,
  });
}

class DebtModel {
  final String id;
  final String personName;
  final double amount; // Principal amount
  final DebtType type;
  final DateTime date; // Start date
  final String? note;

  // Loan & EMI specific fields
  final double? interestRate; // Annual interest rate (%)
  final int? tenureMonths; // Duration in months
  final double? emiAmount; // Monthly EMI
  DateTime? nextDueDate;

  List<DebtPayment> paymentHistory;

  DebtModel({
    required this.id,
    required this.personName,
    required this.amount,
    required this.type,
    required this.date,
    this.note,
    this.interestRate,
    this.tenureMonths,
    this.emiAmount,
    this.nextDueDate,
    List<DebtPayment>? paymentHistory,
  }) : paymentHistory = paymentHistory ?? [];

  double get repaidAmount => paymentHistory.fold(0.0, (sum, p) => sum + p.amount);
  
  double get totalPayable {
    if (emiAmount != null && tenureMonths != null) {
      return emiAmount! * tenureMonths!;
    }
    // Simplistic interest calculation for non-EMI loans if interest is provided
    if (interestRate != null && tenureMonths != null) {
      return amount + (amount * (interestRate! / 100) * (tenureMonths! / 12));
    }
    return amount;
  }

  double get remainingAmount => totalPayable - repaidAmount;
  bool get isPaid => repaidAmount >= totalPayable;
  
  bool get isOverdue {
    if (nextDueDate == null || isPaid) return false;
    return DateTime.now().isAfter(nextDueDate!);
  }
}
