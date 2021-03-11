import 'dart:io';
import 'package:familia/data/eventDB.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String tableName = 'eventDB';

class DBHelper {
  DBHelper._();
  static final DBHelper _db = DBHelper._();
  factory DBHelper() => _db;

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'EventDB.db');

    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE $tableName(id INTEGER PRIMARY KEY, title TEXT, content TEXT, eventdate TEXT)');
    }, onUpgrade: (db, oldVersion, newVersion) {});
  }

// Create
  createData(EventDB eventDB) async {
    final db = await database;
    var res = await db.insert(tableName, eventDB.toJson());
    return res;
  }

// Read
  // ignore: non_constant_identifier_names
  getEvent(int id) async {
    final db = await database;
    var res = await db.query(tableName, where: 'id = ?', whereArgs: [id]);
    return res.isNotEmpty ? EventDB.fromJson(res.first) : Null;
  }

// Read All
  Future<List<EventDB>> getAllEvents() async {
    final db = await database;
    var res = await db.query(tableName);
    List<EventDB> list =
        res.isNotEmpty ? res.map((c) => EventDB.fromJson(c)).toList() : [];
    return list;
  }

// Update

  updateEvents(EventDB eventDB) async {
    final db = await database;
    var res = db.update(tableName, eventDB.toJson(),
        where: 'id = ?', whereArgs: [eventDB.id]);
    return res;
  }

// Delete
  // ignore: non_constant_identifier_names
  deleteEvent(int id) async {
    final db = await database;
    var res = db.delete(tableName, where: 'id = ?', whereArgs: [id]);
    return res;
  }

// Delete All
  deleteAllDiarys() async {
    final db = await database;
    db.delete(tableName);
  }
}
