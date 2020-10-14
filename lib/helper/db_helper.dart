import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';

class DBHelper {
  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, 'lista2.db'),
        onCreate: (db, version) async {
      await db.execute(
          'create table user(id TEXT PRIMARY KEY,email TEXT, pw TEXT, avatar TEXT, backgrounds TEXT, cartId TEXT, config TEXT, itemListId TEXT, name TEXT)');
      await db.execute(
          'create table items(id TEXT PRIMARY KEY, image TEXT, inCart INTEGER, name TEXT, quantity INTEGER)');
      await db.execute(
          'create table cart(id TEXT PRIMARY KEY, image TEXT, name TEXT, checked INTEGER)');
    }, version: 1);
  }

  static Future<void> deleteDB() async {
    final dbPath = await sql.getDatabasesPath();
    //bladList
    final pathh = path.join(dbPath, 'bladList.db');
    await sql.deleteDatabase(pathh);
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    final db = await DBHelper.database();
    db.insert(table, data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await DBHelper.database();
    return db.query(table);
  }

  static Future<void> update(String table, Map<String, Object> data) async {
    final db = await DBHelper.database();
    return db.update(table, data);
  }

  static Future<void> delete(String table) async {
    final db = await DBHelper.database();
    return db.delete(table);
  }
}
