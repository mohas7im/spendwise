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
      version: 2, // Upgraded version for new tables
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createVaultTables(db);
        }
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE subscriptions (
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
      },
    );
  }

  Future<void> _createVaultTables(Database db) async {
    await db.execute('''
      CREATE TABLE documents (
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
      CREATE TABLE bank_accounts (
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
      CREATE TABLE payment_cards (
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
      CREATE TABLE certificates (
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
}
