import 'package:flutter/material.dart';
import 'dart:convert';

class VaultDocument {
  String id;
  String name;
  String category; // Identity, Banking, Insurance, Vehicle, Financial, Other
  String documentNumber;
  DateTime? issueDate;
  DateTime? expiryDate;
  String issuingAuthority;
  String notes;
  List<String> tags;
  String? frontImagePath;
  String? backImagePath;
  String? pdfPath;
  bool isFavorite;

  VaultDocument({
    required this.id,
    required this.name,
    required this.category,
    this.documentNumber = '',
    this.issueDate,
    this.expiryDate,
    this.issuingAuthority = '',
    this.notes = '',
    this.tags = const [],
    this.frontImagePath,
    this.backImagePath,
    this.pdfPath,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'documentNumber': documentNumber,
      'issueDate': issueDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'issuingAuthority': issuingAuthority,
      'notes': notes,
      'tags': jsonEncode(tags),
      'frontImagePath': frontImagePath,
      'backImagePath': backImagePath,
      'pdfPath': pdfPath,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory VaultDocument.fromMap(Map<String, dynamic> map) {
    return VaultDocument(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      documentNumber: map['documentNumber'],
      issueDate: map['issueDate'] != null ? DateTime.parse(map['issueDate']) : null,
      expiryDate: map['expiryDate'] != null ? DateTime.parse(map['expiryDate']) : null,
      issuingAuthority: map['issuingAuthority'],
      notes: map['notes'],
      tags: List<String>.from(jsonDecode(map['tags'] ?? '[]')),
      frontImagePath: map['frontImagePath'],
      backImagePath: map['backImagePath'],
      pdfPath: map['pdfPath'],
      isFavorite: map['isFavorite'] == 1,
    );
  }
}

class BankAccount {
  String id;
  String bankName;
  String holderName;
  String accountNumber;
  String ifscCode;
  String branch;
  String accountType; // Savings, Current, Salary, etc.
  String upiId;
  String nickname;
  String notes;
  bool isPrimary;

  BankAccount({
    required this.id,
    required this.bankName,
    required this.holderName,
    required this.accountNumber,
    this.ifscCode = '',
    this.branch = '',
    this.accountType = 'Savings',
    this.upiId = '',
    this.nickname = '',
    this.notes = '',
    this.isPrimary = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bankName': bankName,
      'holderName': holderName,
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
      'branch': branch,
      'accountType': accountType,
      'upiId': upiId,
      'nickname': nickname,
      'notes': notes,
      'isPrimary': isPrimary ? 1 : 0,
    };
  }

  factory BankAccount.fromMap(Map<String, dynamic> map) {
    return BankAccount(
      id: map['id'],
      bankName: map['bankName'],
      holderName: map['holderName'],
      accountNumber: map['accountNumber'],
      ifscCode: map['ifscCode'],
      branch: map['branch'],
      accountType: map['accountType'],
      upiId: map['upiId'],
      nickname: map['nickname'],
      notes: map['notes'],
      isPrimary: map['isPrimary'] == 1,
    );
  }
}

class PaymentCard {
  String id;
  String cardName;
  String bank;
  String cardType; // Credit, Debit, Prepaid
  String cardNumber;
  String holderName;
  String expiryDate; // MM/YY
  String network; // Visa, Mastercard, RuPay, Amex
  int colorValue;
  String cvv;
  String signature;
  String notes;
  bool isFavorite;

  PaymentCard({
    required this.id,
    required this.cardName,
    required this.bank,
    required this.cardType,
    required this.cardNumber,
    required this.holderName,
    required this.expiryDate,
    required this.network,
    required this.colorValue,
    this.cvv = '',
    this.signature = '',
    this.notes = '',
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cardName': cardName,
      'bank': bank,
      'cardType': cardType,
      'cardNumber': cardNumber,
      'holderName': holderName,
      'expiryDate': expiryDate,
      'network': network,
      'colorValue': colorValue,
      'cvv': cvv,
      'signature': signature,
      'notes': notes,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory PaymentCard.fromMap(Map<String, dynamic> map) {
    return PaymentCard(
      id: map['id'],
      cardName: map['cardName'],
      bank: map['bank'],
      cardType: map['cardType'],
      cardNumber: map['cardNumber'],
      holderName: map['holderName'],
      expiryDate: map['expiryDate'],
      network: map['network'],
      colorValue: map['colorValue'],
      cvv: map['cvv'],
      signature: map['signature'],
      notes: map['notes'],
      isFavorite: map['isFavorite'] == 1,
    );
  }

  Color get color => Color(colorValue);
}

class VaultCertificate {
  String id;
  String name;
  String organization;
  DateTime? issueDate;
  DateTime? expiryDate;
  String certNumber;
  String? filePath;
  String notes;
  bool isFavorite;

  VaultCertificate({
    required this.id,
    required this.name,
    required this.organization,
    this.issueDate,
    this.expiryDate,
    this.certNumber = '',
    this.filePath,
    this.notes = '',
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'organization': organization,
      'issueDate': issueDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'certNumber': certNumber,
      'filePath': filePath,
      'notes': notes,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory VaultCertificate.fromMap(Map<String, dynamic> map) {
    return VaultCertificate(
      id: map['id'],
      name: map['name'],
      organization: map['organization'],
      issueDate: map['issueDate'] != null ? DateTime.parse(map['issueDate']) : null,
      expiryDate: map['expiryDate'] != null ? DateTime.parse(map['expiryDate']) : null,
      certNumber: map['certNumber'],
      filePath: map['filePath'],
      notes: map['notes'],
      isFavorite: map['isFavorite'] == 1,
    );
  }
}
