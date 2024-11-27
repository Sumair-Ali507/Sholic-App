import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'sholic.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE buy_list(id INTEGER PRIMARY KEY, product TEXT, amount INTEGER)',
        );
      },
    );
  }

  Future<void> insertItem(String product, int amount) async {
    final db = await database;
    await db.insert(
      'buy_list',
      {'product': product, 'amount': amount},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getBuyList() async {
    final db = await database;
    return await db.query('buy_list');
  }
}