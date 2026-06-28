enum IncomeType { salary, freelance, investment, other }
enum IncomeFrequency { monthly, yearly, oneTime }

class IncomeCreditRecord {
  final String id;
  final DateTime creditedAt;
  final double amount;
  final String? note;

  IncomeCreditRecord({
    required this.id,
    required this.creditedAt,
    required this.amount,
    this.note,
  });
}

class IncomeSource {
  final String id;
  final String name;
  final double amount;
  final IncomeType type;
  final IncomeFrequency frequency;
  final int? creditDate; // Day of the month (1-31)
  DateTime? lastCredited;
  final List<IncomeCreditRecord> creditHistory;

  IncomeSource({
    required this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.frequency,
    this.creditDate,
    this.lastCredited,
    List<IncomeCreditRecord>? creditHistory,
  }) : creditHistory = creditHistory ?? [];

  IncomeSource copyWith({
    String? id,
    String? name,
    double? amount,
    IncomeType? type,
    IncomeFrequency? frequency,
    int? creditDate,
    DateTime? lastCredited,
    List<IncomeCreditRecord>? creditHistory,
  }) {
    return IncomeSource(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      creditDate: creditDate ?? this.creditDate,
      lastCredited: lastCredited ?? this.lastCredited,
      creditHistory: creditHistory ?? this.creditHistory,
    );
  }
}
