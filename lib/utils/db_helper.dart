import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper with ChangeNotifier {
  static final _databaseName = "mqtt.db";
  static final _databaseVersion = 1;
  static final table = 'my_table';

  static final columnId = '_id';
  static final columnName = 'device';
  static final columnLog = 'log';
  String? path;
  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database? _database = null;
  Future<Database?> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  // DB:/data/user/0/com.example.my_app/app_flutter/mqt.db
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    path = join(documentsDirectory.path, _databaseName);
    print('DB initDatabase: path to DB:$path');
    return await openDatabase(
      path!,
      version: _databaseVersion,
      onCreate: _onCreate,
      readOnly: false,
    );
  }

  //$columnId INTEGER PRIMARY KEY,
  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnName TEXT PRIMARY KEY,
            $columnLog TEXT NOT NULL
          )
          ''');
    print('DB: onCreate called.....');
    var resp = await db.rawInsert(
        'INSERT INTO my_table(device, log) VALUES("temperature", "0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10")');
    resp = await db.rawInsert(
        'INSERT INTO my_table(device, log) VALUES("door", "0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10")');
    resp = await db.rawInsert(
        'INSERT INTO my_table(device, log) VALUES("esp32", "0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10")');
    print('DB: entering 3 rows');
  }

  // Helper methods
  clean() async {
    print('dbhelper: removed DB');
    await File(path!).delete();
    await deleteDatabase(path!);
  }

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    return await db!.insert(table, row);
  }

  Future<int> insertRaw(String dev, Map<String, dynamic> log) async {
    Database? db = await instance.database;
    print('DB helper: insertRaw: $dev, $log');
    return await db!.rawUpdate(
        'UPDATE my_table SET $columnLog = \'$log\' WHERE $columnName = \'$dev\'');
  }

  Future<List<Map<String, dynamic>>> queryTemp() async {
    Database? db = await instance.database;
    var res = await db!.rawQuery(
        'SELECT log FROM my_table where device = \'temperature\' OR device = \'door\' OR device = \'esp32\'');
    print('DB: queryTemp: $res');
    print('DB: ${res[0]['log']}');
    return res; // res[0];
  }

  Future<Map<String, dynamic>> queryDoor() async {
    Database? db = await instance.database;
    var res =
        await db!.rawQuery('SELECT log FROM my_table where device = \'door\'');
    print('DB: queryDoor: $res');
    print('DB: ${res[0]['log']}');
    return res[0];
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database? db = await instance.database;
    return await db!.query(table);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int?> queryRowCount() async {
    Database? db = await instance.database;
    return Sqflite.firstIntValue(
        await db!.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    int id = row[columnId];
    return await db!
        .update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database? db = await instance.database;
    return await db!.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}
