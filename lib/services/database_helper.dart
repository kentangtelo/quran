import 'dart:developer';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'qurannew.db');
    return await openDatabase(path, version: 1);
  }

  Future<List<Map<String, dynamic>>> getQuranPage(int pageNumber) async {
    final db = await database;
    return await db.query(
      'words',
      where: 'page_number = ?',
      whereArgs: [pageNumber],
      columns: [
        'page_number',
        'line_number',
        'aya',
        'text_indopak',
        // 'text_madani',
        'char_type',
        'sura',
      ],
    );
  }

  Future<List<Map<String, dynamic>>> getQuranSurah(int surahNumber) async {
    final db = await database;

    return await db.rawQuery(
      'SELECT sura,aya,text,indonesian,transliteration_id FROM ayas WHERE sura = $surahNumber ORDER BY aya',
    );
  }

  Future<List<Map<String, dynamic>>> getAllSurahInfo() async {
    final db = await database;

    return await db.rawQuery('SELECT * FROM suras');
  }

  Future<int> getFirstPageOfSurah(int surahNumber) async {
    log('surahNumber $surahNumber');
    final db = await database;
    var data = await db
        .rawQuery("SELECT MIN(page) FROM ayas WHERE sura = ${surahNumber}");

    int firstPage = data[0]["MIN(page)"] as int;
    return firstPage;
  }

  Future<int> getNumberSurahFromPage(int noPage) async {
    final db = await database;

    var data = await db.rawQuery("SELECT sura FROM ayas WHERE page=$noPage");

    int noSurah = data[0]["sura"] as int;

    return noSurah;
  }

  Future<List<Map<String, dynamic>>> getSurahAyat(
      {required int surahNumber}) async {
    log('surahNumber $surahNumber');

    final db = await database;

    return await db.rawQuery(
        "SELECT kemenag as ayat,transliteration_id as latin,indonesian as translate FROM ayas WHERE sura=$surahNumber");
  }
}
