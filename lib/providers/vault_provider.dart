import 'package:flutter/material.dart';
import '../models/vault_models.dart';
import '../services/db_helper.dart';

class VaultProvider extends ChangeNotifier {
  List<VaultDocument> _documents = [];
  List<BankAccount> _bankAccounts = [];
  List<PaymentCard> _paymentCards = [];
  List<VaultCertificate> _certificates = [];

  List<VaultDocument> get documents => _documents;
  List<BankAccount> get bankAccounts => _bankAccounts;
  List<PaymentCard> get paymentCards => _paymentCards;
  List<VaultCertificate> get certificates => _certificates;

  VaultProvider() {
    _loadAll();
  }

  Future<void> _loadAll() async {
    final db = DatabaseHelper();
    _documents = await db.getDocuments();
    _bankAccounts = await db.getBankAccounts();
    _paymentCards = await db.getPaymentCards();
    _certificates = await db.getCertificates();
    notifyListeners();
  }

  // --- Documents ---
  Future<void> addDocument(VaultDocument doc) async {
    await DatabaseHelper().insertDocument(doc);
    _documents.add(doc);
    notifyListeners();
  }
  Future<void> updateDocument(VaultDocument doc) async {
    await DatabaseHelper().updateDocument(doc);
    final index = _documents.indexWhere((d) => d.id == doc.id);
    if (index != -1) {
      _documents[index] = doc;
      notifyListeners();
    }
  }
  Future<void> deleteDocument(String id) async {
    await DatabaseHelper().deleteDocument(id);
    _documents.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  // --- Bank Accounts ---
  Future<void> addBankAccount(BankAccount account) async {
    await DatabaseHelper().insertBankAccount(account);
    _bankAccounts.add(account);
    notifyListeners();
  }
  Future<void> updateBankAccount(BankAccount account) async {
    await DatabaseHelper().updateBankAccount(account);
    final index = _bankAccounts.indexWhere((a) => a.id == account.id);
    if (index != -1) {
      _bankAccounts[index] = account;
      notifyListeners();
    }
  }
  Future<void> deleteBankAccount(String id) async {
    await DatabaseHelper().deleteBankAccount(id);
    _bankAccounts.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  // --- Payment Cards ---
  Future<void> addPaymentCard(PaymentCard card) async {
    await DatabaseHelper().insertPaymentCard(card);
    _paymentCards.add(card);
    notifyListeners();
  }
  Future<void> updatePaymentCard(PaymentCard card) async {
    await DatabaseHelper().updatePaymentCard(card);
    final index = _paymentCards.indexWhere((c) => c.id == card.id);
    if (index != -1) {
      _paymentCards[index] = card;
      notifyListeners();
    }
  }
  Future<void> deletePaymentCard(String id) async {
    await DatabaseHelper().deletePaymentCard(id);
    _paymentCards.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  // --- Certificates ---
  Future<void> addCertificate(VaultCertificate cert) async {
    await DatabaseHelper().insertCertificate(cert);
    _certificates.add(cert);
    notifyListeners();
  }
  Future<void> updateCertificate(VaultCertificate cert) async {
    await DatabaseHelper().updateCertificate(cert);
    final index = _certificates.indexWhere((c) => c.id == cert.id);
    if (index != -1) {
      _certificates[index] = cert;
      notifyListeners();
    }
  }
  Future<void> deleteCertificate(String id) async {
    await DatabaseHelper().deleteCertificate(id);
    _certificates.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
