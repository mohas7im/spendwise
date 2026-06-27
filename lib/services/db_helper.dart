import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/subscription.dart';

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
      version: 1,
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
      },
    );
  }

  Future<int> insertSubscription(SubscriptionModel sub) async {
    final db = await database;
    return await db.insert(
      'subscriptions',
      sub.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SubscriptionModel>> getSubscriptions() async {
    final db = await database;
    final maps = await db.query('subscriptions');
    return List.generate(maps.length, (i) {
      return SubscriptionModel.fromMap(maps[i]);
    });
  }

  Future<int> updateSubscription(SubscriptionModel sub) async {
    final db = await database;
    return await db.update(
      'subscriptions',
      sub.toMap(),
      where: 'id = ?',
      whereArgs: [sub.id],
    );
  }

  Future<int> deleteSubscription(String id) async {
    final db = await database;
    return await db.delete(
      'subscriptions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
