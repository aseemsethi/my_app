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
  //  DB initDatabase: path to DB:/data/user/0/com.example.my_app/app_flutter/mqtt.db
  Future _onCreate(Database db, int version) async {
    print('DB: onCreate called.....');
    // Gatweays Table
    await db.execute('''
          CREATE TABLE Gateways (
            $columnName TEXT PRIMARY KEY,
            $columnLog TEXT NOT NULL
          )
          ''');
    // Doors Table
    await db.execute('''
          CREATE TABLE Doors (
            $columnName TEXT PRIMARY KEY,
            $columnLog TEXT NOT NULL
          )
          ''');
    // Temperature Table
    await db.execute('''
          CREATE TABLE Temp (
            $columnName TEXT PRIMARY KEY,
            $columnLog TEXT NOT NULL
          )
          ''');
    // Temperature Table
    await db.execute('''
          CREATE TABLE State (
            state TEXT PRIMARY KEY,
            status TEXT NOT NULL,
            connTime TEXT NOT NULL
          )
          ''');
  }

  // Helper methods
  clean() async {
    print('dbhelper: removed DB');
    //await File(path!).delete();
    await deleteDatabase(path!);
  }

  Future<int> updateState(String status) async {
    String timeNow = "now";
    Database? db = await instance.database;
    print('DB helper: updateState: status');
    return await db!.rawUpdate(
        'REPLACE INTO State (state, status, connTime) VALUES (\'state\', \'$status\', \'$timeNow\')');
  }

  Future<List<Map<String, dynamic>>> getState() async {
    Database? db = await instance.database;
    var res = await db!.rawQuery('SELECT status FROM State');
    print('DB: getState: ${res[0]['status']}');
    return res;
  }

  Future<int> updateGw(String dev, Map<String, dynamic> log) async {
    Database? db = await instance.database;
    print('DB helper: updateGw: $dev, $log');
    return await db!.rawUpdate(
        'REPLACE INTO Gateways (device, log) VALUES (\'$dev\', \'$log\')');
  }

  Future<int> updateDoors(String dev, Map<String, dynamic> log) async {
    Database? db = await instance.database;
    print('DB helper: updateDoors: $dev, $log');
    return await db!.rawUpdate(
        'REPLACE INTO Doors (device, log) VALUES (\'$dev\', \'$log\')');
  }

  Future<int> updateTemp(String dev, Map<String, dynamic> log) async {
    Database? db = await instance.database;
    print('DB helper: updateDoors: $dev, $log');
    return await db!.rawUpdate(
        'REPLACE INTO Temp (device, log) VALUES (\'$dev\', \'$log\')');
  }

  Future<List<Map<String, dynamic>>> queryTemp() async {
    Database? db = await instance.database;
    var res = await db!.rawQuery(
        'SELECT log FROM my_table where device = \'temperature\' OR device = \'door\' OR device = \'esp32\'');
    print('DB: queryTemp: $res');
    print('DB: ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
    //print('DB: ${res[0]['log']}');
    return res;
  }

  Future<List<Map<String, dynamic>>> getGwList() async {
    Database? db = await instance.database;
    var res = await db!.rawQuery('SELECT log FROM Gateways');
    //print('DB: getGwList: $res');
    return res;
  }

  Future<List<Map<String, dynamic>>> getDoorList() async {
    Database? db = await instance.database;
    var res = await db!.rawQuery('SELECT log FROM Doors');
    //print('DB: getDoorList: $res');
    return res;
  }

  Future<List<Map<String, dynamic>>> getTempList() async {
    Database? db = await instance.database;
    var res = await db!.rawQuery('SELECT log FROM Temp');
    //print('DB: getTempList: $res');
    return res;
  }

  Future<Map<String, dynamic>> queryDoor() async {
    Database? db = await instance.database;
    var res =
        await db!.rawQuery('SELECT log FROM my_table where device = \'door\'');
    print('DB: queryDoor: $res');
    //print('DB: ${res[0]['log']}');
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
}
