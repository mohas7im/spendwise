import 'package:flutter/material.dart';

enum TransactionStatus { completed, pending, failed, cancelled }
enum GlobalTransactionType { income, expense, transfer }

class GlobalTransaction {
  final String id;
  final String title;
  final String category;
  final double amount;
  final GlobalTransactionType type;
  final DateTime date;
  final String paymentMethod;
  final String? person;
  final TransactionStatus status;
  final String notes;
  final bool hasAttachment;
  final List<String> tags;
  final String sourceModule;

  GlobalTransaction({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.type,
    required this.date,
    this.paymentMethod = 'Cash',
    this.person,
    this.status = TransactionStatus.completed,
    this.notes = '',
    this.hasAttachment = false,
    this.tags = const [],
    required this.sourceModule,
  });

  Color get color {
    if (status == TransactionStatus.pending) return Colors.orange;
    switch (type) {
      case GlobalTransactionType.income:
        return Colors.green;
      case GlobalTransactionType.expense:
        return Colors.red;
      case GlobalTransactionType.transfer:
        return Colors.blue;
    }
  }

  IconData get icon {
    switch (type) {
      case GlobalTransactionType.income:
        return Icons.arrow_downward;
      case GlobalTransactionType.expense:
        return Icons.arrow_upward;
      case GlobalTransactionType.transfer:
        return Icons.swap_horiz;
    }
  }

  GlobalTransaction copyWith({
    String? id,
    String? title,
    String? category,
    double? amount,
    GlobalTransactionType? type,
    DateTime? date,
    String? paymentMethod,
    String? person,
    TransactionStatus? status,
    String? notes,
    bool? hasAttachment,
    List<String>? tags,
    String? sourceModule,
  }) {
    return GlobalTransaction(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      person: person ?? this.person,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      hasAttachment: hasAttachment ?? this.hasAttachment,
      tags: tags ?? this.tags,
      sourceModule: sourceModule ?? this.sourceModule,
    );
  }
}
