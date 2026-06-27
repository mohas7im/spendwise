import 'dart:convert';
import 'package:flutter/material.dart';

class SubscriptionPayment {
  final DateTime date;
  final double amount;
  final String status;

  SubscriptionPayment({
    required this.date,
    required this.amount,
    this.status = 'Paid',
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'amount': amount,
      'status': status,
    };
  }

  factory SubscriptionPayment.fromMap(Map<String, dynamic> map) {
    return SubscriptionPayment(
      date: DateTime.parse(map['date']),
      amount: map['amount'],
      status: map['status'] ?? 'Paid',
    );
  }
}

class SubscriptionModel {
  String id;
  String name;
  double cost;
  String cycle; // 'Monthly', 'Yearly', or 'Custom (Days)'
  int? customDays;
  DateTime nextBilling;
  int colorValue;
  int iconCodePoint;
  String iconFontFamily;
  bool isPaused;
  String currency;
  List<SubscriptionPayment> paymentHistory;

  SubscriptionModel({
    required this.id,
    required this.name,
    required this.cost,
    required this.cycle,
    this.customDays,
    required this.nextBilling,
    required this.colorValue,
    required this.iconCodePoint,
    this.iconFontFamily = 'MaterialIcons',
    this.isPaused = false,
    this.currency = '₹',
    List<SubscriptionPayment>? paymentHistory,
  }) : paymentHistory = paymentHistory ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cost': cost,
      'cycle': cycle,
      'customDays': customDays,
      'nextBilling': nextBilling.toIso8601String(),
      'colorValue': colorValue,
      'iconCodePoint': iconCodePoint,
      'iconFontFamily': iconFontFamily,
      'isPaused': isPaused ? 1 : 0,
      'currency': currency,
      'paymentHistory': jsonEncode(paymentHistory.map((p) => p.toMap()).toList()),
    };
  }

  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
    List<SubscriptionPayment> history = [];
    if (map['paymentHistory'] != null) {
      final decoded = jsonDecode(map['paymentHistory']) as List;
      history = decoded.map((e) => SubscriptionPayment.fromMap(e as Map<String, dynamic>)).toList();
    }
    
    return SubscriptionModel(
      id: map['id'],
      name: map['name'],
      cost: map['cost'],
      cycle: map['cycle'],
      customDays: map['customDays'],
      nextBilling: DateTime.parse(map['nextBilling']),
      colorValue: map['colorValue'],
      iconCodePoint: map['iconCodePoint'],
      iconFontFamily: map['iconFontFamily'] ?? 'MaterialIcons',
      isPaused: map['isPaused'] == 1,
      currency: map['currency'] ?? '₹',
      paymentHistory: history,
    );
  }

  Color get color => Color(colorValue);
  // ignore: non_const_argument_for_const_parameter
  IconData get icon => IconData(iconCodePoint, fontFamily: iconFontFamily);
}
