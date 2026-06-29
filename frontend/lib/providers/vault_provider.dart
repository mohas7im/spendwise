import 'package:flutter/material.dart';
import '../models/vault_models.dart';
import '../services/db_helper.dart';
import '../services/notification_service.dart';

class VaultProvider extends ChangeNotifier {
  List<VaultDocument> _documents = [];
  List<BankAccount> _bankAccounts = [];
  List<PaymentCard> _paymentCards = [];
  List<VaultCertificate> _certificates = [];

  List<VaultNote> _notes = [];
  List<VaultReminder> _reminders = [];
  List<ImportantDate> _importantDates = [];

  List<VaultDocument> get documents => _documents;
  List<BankAccount> get bankAccounts => _bankAccounts;
  List<PaymentCard> get paymentCards => _paymentCards;
  List<VaultCertificate> get certificates => _certificates;
  List<VaultNote> get notes => _notes;
  List<VaultReminder> get reminders => _reminders;
  List<ImportantDate> get importantDates => _importantDates;

  VaultProvider() {
    _loadAll();
  }

  Future<void> _loadAll() async {
    final db = DatabaseHelper();
    _documents = await db.getDocuments();
    _bankAccounts = await db.getBankAccounts();
    _paymentCards = await db.getPaymentCards();
    _certificates = await db.getCertificates();
    _notes = await db.getVaultNotes();
    _reminders = await db.getVaultReminders();
    _importantDates = await db.getImportantDates();
    notifyListeners();
  }

  // --- Documents ---
  Future<void> addDocument(VaultDocument doc) async {
    await DatabaseHelper().insertDocument(doc);
    _documents.add(doc);
    if (doc.expiryDate != null) {
      await NotificationService().scheduleVaultExpiryReminder(id: doc.id, name: doc.name, type: 'Document', expiryDate: doc.expiryDate!);
    }
    notifyListeners();
  }
  Future<void> updateDocument(VaultDocument doc) async {
    await DatabaseHelper().updateDocument(doc);
    final index = _documents.indexWhere((d) => d.id == doc.id);
    if (index != -1) {
      _documents[index] = doc;
      if (doc.expiryDate != null) {
        await NotificationService().scheduleVaultExpiryReminder(id: doc.id, name: doc.name, type: 'Document', expiryDate: doc.expiryDate!);
      } else {
        await NotificationService().cancelReminder(doc.id);
      }
      notifyListeners();
    }
  }
  Future<void> deleteDocument(String id) async {
    await DatabaseHelper().deleteDocument(id);
    _documents.removeWhere((d) => d.id == id);
    await NotificationService().cancelReminder(id);
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
    // Parse expiry (MM/YY)
    if (card.expiryDate.isNotEmpty && card.expiryDate.contains('/')) {
      try {
        final parts = card.expiryDate.split('/');
        final month = int.parse(parts[0]);
        // Assume YY means 20YY
        final year = 2000 + int.parse(parts[1]);
        // Set expiry to last day of that month
        final expiry = DateTime(year, month + 1, 0);
        await NotificationService().scheduleVaultExpiryReminder(id: card.id, name: card.cardName, type: 'Payment Card', expiryDate: expiry);
      } catch (e) {
        // ignore format errors
      }
    }
    notifyListeners();
  }
  Future<void> updatePaymentCard(PaymentCard card) async {
    await DatabaseHelper().updatePaymentCard(card);
    final index = _paymentCards.indexWhere((c) => c.id == card.id);
    if (index != -1) {
      _paymentCards[index] = card;
      if (card.expiryDate.isNotEmpty && card.expiryDate.contains('/')) {
        try {
          final parts = card.expiryDate.split('/');
          final month = int.parse(parts[0]);
          final year = 2000 + int.parse(parts[1]);
          final expiry = DateTime(year, month + 1, 0);
          await NotificationService().scheduleVaultExpiryReminder(id: card.id, name: card.cardName, type: 'Payment Card', expiryDate: expiry);
        } catch (e) {
           await NotificationService().cancelReminder(card.id);
        }
      } else {
        await NotificationService().cancelReminder(card.id);
      }
      notifyListeners();
    }
  }
  Future<void> deletePaymentCard(String id) async {
    await DatabaseHelper().deletePaymentCard(id);
    _paymentCards.removeWhere((c) => c.id == id);
    await NotificationService().cancelReminder(id);
    notifyListeners();
  }

  // --- Certificates ---
  Future<void> addCertificate(VaultCertificate cert) async {
    await DatabaseHelper().insertCertificate(cert);
    _certificates.add(cert);
    if (cert.expiryDate != null) {
      await NotificationService().scheduleVaultExpiryReminder(id: cert.id, name: cert.name, type: 'Certificate', expiryDate: cert.expiryDate!);
    }
    notifyListeners();
  }
  Future<void> updateCertificate(VaultCertificate cert) async {
    await DatabaseHelper().updateCertificate(cert);
    final index = _certificates.indexWhere((c) => c.id == cert.id);
    if (index != -1) {
      _certificates[index] = cert;
      if (cert.expiryDate != null) {
        await NotificationService().scheduleVaultExpiryReminder(id: cert.id, name: cert.name, type: 'Certificate', expiryDate: cert.expiryDate!);
      } else {
        await NotificationService().cancelReminder(cert.id);
      }
      notifyListeners();
    }
  }
  Future<void> deleteCertificate(String id) async {
    await DatabaseHelper().deleteCertificate(id);
    _certificates.removeWhere((c) => c.id == id);
    await NotificationService().cancelReminder(id);
    notifyListeners();
  }

  // --- Notes ---
  Future<void> addNote(VaultNote note) async {
    await DatabaseHelper().insertVaultNote(note);
    _notes.add(note);
    notifyListeners();
  }
  Future<void> updateNote(VaultNote note) async {
    await DatabaseHelper().updateVaultNote(note);
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      notifyListeners();
    }
  }
  Future<void> deleteNote(String id) async {
    await DatabaseHelper().deleteVaultNote(id);
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  // --- Reminders ---
  Future<void> addReminder(VaultReminder reminder) async {
    await DatabaseHelper().insertVaultReminder(reminder);
    _reminders.add(reminder);
    await NotificationService().scheduleVaultReminder(reminder);
    notifyListeners();
  }
  Future<void> updateReminder(VaultReminder reminder) async {
    await DatabaseHelper().updateVaultReminder(reminder);
    final index = _reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      _reminders[index] = reminder;
      await NotificationService().cancelReminder(reminder.id);
      await NotificationService().scheduleVaultReminder(reminder);
      notifyListeners();
    }
  }
  Future<void> deleteReminder(String id) async {
    await DatabaseHelper().deleteVaultReminder(id);
    _reminders.removeWhere((r) => r.id == id);
    await NotificationService().cancelReminder(id);
    notifyListeners();
  }

  // --- Important Dates ---
  Future<void> addImportantDate(ImportantDate date) async {
    await DatabaseHelper().insertImportantDate(date);
    _importantDates.add(date);
    notifyListeners();
  }
  Future<void> updateImportantDate(ImportantDate date) async {
    await DatabaseHelper().updateImportantDate(date);
    final index = _importantDates.indexWhere((d) => d.id == date.id);
    if (index != -1) {
      _importantDates[index] = date;
      notifyListeners();
    }
  }
  Future<void> deleteImportantDate(String id) async {
    await DatabaseHelper().deleteImportantDate(id);
    _importantDates.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  // --- Unified Search ---
  Map<String, List<dynamic>> searchVault(String query) {
    final lowerQuery = query.toLowerCase();
    if (lowerQuery.isEmpty) return {};
    
    return {
      'documents': _documents.where((d) => d.name.toLowerCase().contains(lowerQuery) || d.notes.toLowerCase().contains(lowerQuery) || d.documentNumber.toLowerCase().contains(lowerQuery)).toList(),
      'notes': _notes.where((n) => n.title.toLowerCase().contains(lowerQuery) || n.description.toLowerCase().contains(lowerQuery)).toList(),
      'reminders': _reminders.where((r) => r.title.toLowerCase().contains(lowerQuery) || r.description.toLowerCase().contains(lowerQuery)).toList(),
      'cards': _paymentCards.where((c) => c.cardName.toLowerCase().contains(lowerQuery) || c.bank.toLowerCase().contains(lowerQuery)).toList(),
      'banks': _bankAccounts.where((b) => b.bankName.toLowerCase().contains(lowerQuery) || b.accountNumber.contains(lowerQuery)).toList(),
      'certificates': _certificates.where((c) => c.name.toLowerCase().contains(lowerQuery)).toList(),
      'importantDates': _importantDates.where((d) => d.title.toLowerCase().contains(lowerQuery)).toList(),
    };
  }

  // --- Expiry Tracker ---
  List<dynamic> get upcomingExpirations {
    final now = DateTime.now();
    final threshold = now.add(const Duration(days: 30));
    
    List<dynamic> expiringItems = [];
    
    for (var doc in _documents) {
      if (doc.expiryDate != null && doc.expiryDate!.isAfter(now) && doc.expiryDate!.isBefore(threshold)) {
        expiringItems.add({'type': 'Document', 'item': doc, 'date': doc.expiryDate});
      }
    }
    for (var cert in _certificates) {
      if (cert.expiryDate != null && cert.expiryDate!.isAfter(now) && cert.expiryDate!.isBefore(threshold)) {
        expiringItems.add({'type': 'Certificate', 'item': cert, 'date': cert.expiryDate});
      }
    }
    for (var card in _paymentCards) {
      if (card.expiryDate.isNotEmpty && card.expiryDate.contains('/')) {
        try {
          final parts = card.expiryDate.split('/');
          final month = int.parse(parts[0]);
          final year = 2000 + int.parse(parts[1]);
          final expiry = DateTime(year, month + 1, 0);
          if (expiry.isAfter(now) && expiry.isBefore(threshold)) {
            expiringItems.add({'type': 'Payment Card', 'item': card, 'date': expiry});
          }
        } catch (_) {}
      }
    }
    
    // Sort by nearest date
    expiringItems.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
    return expiringItems;
  }
}
