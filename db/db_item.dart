import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/item_model.dart';
import '../models/riwayat_model.dart';


class DBItem {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'transaksi.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE item (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT,
            harga INTEGER,
            stok INTEGER,
            keterangan TEXT,
            isChecked INTEGER DEFAULT 0           
          )
        ''');
        await db.execute('''
          CREATE TABLE transaksi (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tanggal TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE riwayat(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            total INTEGER,
            items TEXT
          )
        ''');
      },
    );
  }

// === Item ===
  Future<int> insertItem(Item item) async {
    final db = await database;
    return await db.insert('item', item.toMap());
  }

  Future<List<Item>> getItemList() async {
    final db = await database;
    final maps = await db.query('item');
    return maps.map((map) => Item.fromMap(map)).toList();
  }

  Future<int> updateItem(Item item) async {
    final db = await database;
    return await db.update('item', item.toMap(),
        where: 'id = ?', whereArgs: [item.id]);
  }

  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete('item', where: 'id = ?', whereArgs: [id]);
  }

// === Transaksi ===
  Future<void> insertHistory(TransactionHistory h) async {
    final db = await database;
    await db.insert('riwayat', h.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<TransactionHistory>> getHistoryList() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('riwayat', orderBy: 'id DESC');
    return List.generate(maps.length, (i) => TransactionHistory.fromMap(maps[i]));
  }

  Future<List<TransactionHistory>> getHistoryForChart() async {
    final db = await database;
    final result = await db.query('riwayat', orderBy: 'date ASC');
    return result.map((e) => TransactionHistory.fromMap(e)).toList();
  }

  Future<int> deleteHistory(int id) async {
    final db = await database;
    return await db.delete('riwayat', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateStok(int id, int newStok) async {
    final db = await database;
    return await db.update(
      'item',
      {'stok': newStok},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}
