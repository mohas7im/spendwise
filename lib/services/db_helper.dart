import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/subscription.dart';
import '../models/vault_models.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'spendwise.db');

    return await openDatabase(
      path,
      version: 3, // Upgraded version for new tables
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createVaultTables(db);
        }
        if (oldVersion < 3) {
          await _createVaultV3Tables(db);
        }
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS subscriptions (
            id TEXT PRIMARY KEY,
            name TEXT,
            cost REAL,
            cycle TEXT,
            customDays INTEGER,
            nextBilling TEXT,
            colorValue INTEGER,
            iconCodePoint INTEGER,
            iconFontFamily TEXT,
            isPaused INTEGER,
            currency TEXT,
            paymentHistory TEXT
          )
        ''');
        await _createVaultTables(db);
        await _createVaultV3Tables(db);
      },
    );
  }

  Future<void> _createVaultV3Tables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS vault_notes (
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        checklist TEXT,
        colorValue INTEGER,
        tags TEXT,
        imagePaths TEXT,
        pdfPath TEXT,
        createdDate TEXT,
        updatedDate TEXT,
        isPinned INTEGER,
        isFavorite INTEGER,
        isArchived INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS vault_reminders (
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        date TEXT,
        repeat TEXT,
        priority TEXT,
        category TEXT,
        notes TEXT,
        attachments TEXT,
        isCompleted INTEGER,
        isSnoozed INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS important_dates (
        id TEXT PRIMARY KEY,
        title TEXT,
        date TEXT,
        recurringType TEXT,
        notes TEXT
      )
    ''');
  }

  Future<void> _createVaultTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS documents (
        id TEXT PRIMARY KEY,
        name TEXT,
        category TEXT,
        documentNumber TEXT,
        issueDate TEXT,
        expiryDate TEXT,
        issuingAuthority TEXT,
        notes TEXT,
        tags TEXT,
        frontImagePath TEXT,
        backImagePath TEXT,
        pdfPath TEXT,
        isFavorite INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS bank_accounts (
        id TEXT PRIMARY KEY,
        bankName TEXT,
        holderName TEXT,
        accountNumber TEXT,
        ifscCode TEXT,
        branch TEXT,
        accountType TEXT,
        upiId TEXT,
        nickname TEXT,
        notes TEXT,
        isPrimary INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS payment_cards (
        id TEXT PRIMARY KEY,
        cardName TEXT,
        bank TEXT,
        cardType TEXT,
        cardNumber TEXT,
        holderName TEXT,
        expiryDate TEXT,
        network TEXT,
        colorValue INTEGER,
        cvv TEXT,
        signature TEXT,
        notes TEXT,
        isFavorite INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS certificates (
        id TEXT PRIMARY KEY,
        name TEXT,
        organization TEXT,
        issueDate TEXT,
        expiryDate TEXT,
        certNumber TEXT,
        filePath TEXT,
        notes TEXT,
        isFavorite INTEGER
      )
    ''');
  }

  // --- Subscriptions ---
  Future<int> insertSubscription(SubscriptionModel sub) async {
    final db = await database;
    return await db.insert('subscriptions', sub.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<List<SubscriptionModel>> getSubscriptions() async {
    final db = await database;
    final maps = await db.query('subscriptions');
    return List.generate(maps.length, (i) => SubscriptionModel.fromMap(maps[i]));
  }
  Future<int> updateSubscription(SubscriptionModel sub) async {
    final db = await database;
    return await db.update('subscriptions', sub.toMap(), where: 'id = ?', whereArgs: [sub.id]);
  }
  Future<int> deleteSubscription(String id) async {
    final db = await database;
    return await db.delete('subscriptions', where: 'id = ?', whereArgs: [id]);
  }

  // --- Documents ---
  Future<int> insertDocument(VaultDocument doc) async {
    final db = await database;
    return await db.insert('documents', doc.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<List<VaultDocument>> getDocuments() async {
    final db = await database;
    final maps = await db.query('documents');
    return List.generate(maps.length, (i) => VaultDocument.fromMap(maps[i]));
  }
  Future<int> updateDocument(VaultDocument doc) async {
    final db = await database;
    return await db.update('documents', doc.toMap(), where: 'id = ?', whereArgs: [doc.id]);
  }
  Future<int> deleteDocument(String id) async {
    final db = await database;
    return await db.delete('documents', where: 'id = ?', whereArgs: [id]);
  }

  // --- Bank Accounts ---
  Future<int> insertBankAccount(BankAccount account) async {
    final db = await database;
    return await db.insert('bank_accounts', account.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<List<BankAccount>> getBankAccounts() async {
    final db = await database;
    final maps = await db.query('bank_accounts');
    return List.generate(maps.length, (i) => BankAccount.fromMap(maps[i]));
  }
  Future<int> updateBankAccount(BankAccount account) async {
    final db = await database;
    return await db.update('bank_accounts', account.toMap(), where: 'id = ?', whereArgs: [account.id]);
  }
  Future<int> deleteBankAccount(String id) async {
    final db = await database;
    return await db.delete('bank_accounts', where: 'id = ?', whereArgs: [id]);
  }

  // --- Payment Cards ---
  Future<int> insertPaymentCard(PaymentCard card) async {
    final db = await database;
    return await db.insert('payment_cards', card.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<List<PaymentCard>> getPaymentCards() async {
    final db = await database;
    final maps = await db.query('payment_cards');
    return List.generate(maps.length, (i) => PaymentCard.fromMap(maps[i]));
  }
  Future<int> updatePaymentCard(PaymentCard card) async {
    final db = await database;
    return await db.update('payment_cards', card.toMap(), where: 'id = ?', whereArgs: [card.id]);
  }
  Future<int> deletePaymentCard(String id) async {
    final db = await database;
    return await db.delete('payment_cards', where: 'id = ?', whereArgs: [id]);
  }

  // --- Certificates ---
  Future<int> insertCertificate(VaultCertificate cert) async {
    final db = await database;
    return await db.insert('certificates', cert.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<List<VaultCertificate>> getCertificates() async {
    final db = await database;
    final maps = await db.query('certificates');
    return List.generate(maps.length, (i) => VaultCertificate.fromMap(maps[i]));
  }
  Future<int> updateCertificate(VaultCertificate cert) async {
    final db = await database;
    return await db.update('certificates', cert.toMap(), where: 'id = ?', whereArgs: [cert.id]);
  }
  Future<int> deleteCertificate(String id) async {
    final db = await database;
    return await db.delete('certificates', where: 'id = ?', whereArgs: [id]);
  }

  // --- Notes ---
  Future<int> insertVaultNote(VaultNote note) async {
    final db = await database;
    return await db.insert('vault_notes', note.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<List<VaultNote>> getVaultNotes() async {
    final db = await database;
    final maps = await db.query('vault_notes');
    return List.generate(maps.length, (i) => VaultNote.fromMap(maps[i]));
  }
  Future<int> updateVaultNote(VaultNote note) async {
    final db = await database;
    return await db.update('vault_notes', note.toMap(), where: 'id = ?', whereArgs: [note.id]);
  }
  Future<int> deleteVaultNote(String id) async {
    final db = await database;
    return await db.delete('vault_notes', where: 'id = ?', whereArgs: [id]);
  }

  // --- Reminders ---
  Future<int> insertVaultReminder(VaultReminder reminder) async {
    final db = await database;
    return await db.insert('vault_reminders', reminder.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<List<VaultReminder>> getVaultReminders() async {
    final db = await database;
    final maps = await db.query('vault_reminders');
    return List.generate(maps.length, (i) => VaultReminder.fromMap(maps[i]));
  }
  Future<int> updateVaultReminder(VaultReminder reminder) async {
    final db = await database;
    return await db.update('vault_reminders', reminder.toMap(), where: 'id = ?', whereArgs: [reminder.id]);
  }
  Future<int> deleteVaultReminder(String id) async {
    final db = await database;
    return await db.delete('vault_reminders', where: 'id = ?', whereArgs: [id]);
  }

  // --- Important Dates ---
  Future<int> insertImportantDate(ImportantDate date) async {
    final db = await database;
    return await db.insert('important_dates', date.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<List<ImportantDate>> getImportantDates() async {
    final db = await database;
    final maps = await db.query('important_dates');
    return List.generate(maps.length, (i) => ImportantDate.fromMap(maps[i]));
  }
  Future<int> updateImportantDate(ImportantDate date) async {
    final db = await database;
    return await db.update('important_dates', date.toMap(), where: 'id = ?', whereArgs: [date.id]);
  }
  Future<int> deleteImportantDate(String id) async {
    final db = await database;
    return await db.delete('important_dates', where: 'id = ?', whereArgs: [id]);
  }
}

