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

class VaultNote {
  String id;
  String title;
  String description;
  List<String> checklist;
  int colorValue;
  List<String> tags;
  List<String> imagePaths;
  String? pdfPath;
  DateTime createdDate;
  DateTime updatedDate;
  bool isPinned;
  bool isFavorite;
  bool isArchived;

  VaultNote({
    required this.id,
    required this.title,
    this.description = '',
    this.checklist = const [],
    this.colorValue = 0xFFFFFFFF,
    this.tags = const [],
    this.imagePaths = const [],
    this.pdfPath,
    required this.createdDate,
    required this.updatedDate,
    this.isPinned = false,
    this.isFavorite = false,
    this.isArchived = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'checklist': jsonEncode(checklist),
      'colorValue': colorValue,
      'tags': jsonEncode(tags),
      'imagePaths': jsonEncode(imagePaths),
      'pdfPath': pdfPath,
      'createdDate': createdDate.toIso8601String(),
      'updatedDate': updatedDate.toIso8601String(),
      'isPinned': isPinned ? 1 : 0,
      'isFavorite': isFavorite ? 1 : 0,
      'isArchived': isArchived ? 1 : 0,
    };
  }

  factory VaultNote.fromMap(Map<String, dynamic> map) {
    return VaultNote(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      checklist: List<String>.from(jsonDecode(map['checklist'] ?? '[]')),
      colorValue: map['colorValue'],
      tags: List<String>.from(jsonDecode(map['tags'] ?? '[]')),
      imagePaths: List<String>.from(jsonDecode(map['imagePaths'] ?? '[]')),
      pdfPath: map['pdfPath'],
      createdDate: DateTime.parse(map['createdDate']),
      updatedDate: DateTime.parse(map['updatedDate']),
      isPinned: map['isPinned'] == 1,
      isFavorite: map['isFavorite'] == 1,
      isArchived: map['isArchived'] == 1,
    );
  }
}

class VaultReminder {
  String id;
  String title;
  String description;
  DateTime date;
  String repeat;
  String priority;
  String category;
  String notes;
  List<String> attachments;
  bool isCompleted;
  bool isSnoozed;

  VaultReminder({
    required this.id,
    required this.title,
    this.description = '',
    required this.date,
    this.repeat = 'None',
    this.priority = 'Medium',
    required this.category,
    this.notes = '',
    this.attachments = const [],
    this.isCompleted = false,
    this.isSnoozed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'repeat': repeat,
      'priority': priority,
      'category': category,
      'notes': notes,
      'attachments': jsonEncode(attachments),
      'isCompleted': isCompleted ? 1 : 0,
      'isSnoozed': isSnoozed ? 1 : 0,
    };
  }

  factory VaultReminder.fromMap(Map<String, dynamic> map) {
    return VaultReminder(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      repeat: map['repeat'],
      priority: map['priority'],
      category: map['category'],
      notes: map['notes'],
      attachments: List<String>.from(jsonDecode(map['attachments'] ?? '[]')),
      isCompleted: map['isCompleted'] == 1,
      isSnoozed: map['isSnoozed'] == 1,
    );
  }
}

class ImportantDate {
  String id;
  String title;
  DateTime date;
  String recurringType;
  String notes;

  ImportantDate({
    required this.id,
    required this.title,
    required this.date,
    this.recurringType = 'Yearly',
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'recurringType': recurringType,
      'notes': notes,
    };
  }

  factory ImportantDate.fromMap(Map<String, dynamic> map) {
    return ImportantDate(
      id: map['id'],
      title: map['title'],
      date: DateTime.parse(map['date']),
      recurringType: map['recurringType'],
      notes: map['notes'],
    );
  }
}
