import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/pantry_item.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'smart_pantry.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pantry_items(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        category TEXT NOT NULL,
        dateAdded TEXT NOT NULL,
        expiryDate TEXT,
        notes TEXT
      )
    ''');
  }

  Future<void> insertItem(PantryItem item) async {
    final db = await database;
    await db.insert(
      'pantry_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PantryItem>> getAllItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('pantry_items');
    return List.generate(maps.length, (i) => PantryItem.fromMap(maps[i]));
  }

  Future<void> updateItem(PantryItem item) async {
    final db = await database;
    await db.update(
      'pantry_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteItem(String id) async {
    final db = await database;
    await db.delete(
      'pantry_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
} 