import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/patient.dart';
import '../model/urine_record.dart';
import '../utils/constant.dart';

class DbService {
  static final DbService _instance = DbService._internal();
  factory DbService() => _instance;
  DbService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ${AppConstants.tablePatients} (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            age INTEGER NOT NULL,
            weight REAL NOT NULL,
            height REAL NOT NULL,
            bedId TEXT NOT NULL,
            zone TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE ${AppConstants.tableUrineRecords} (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            patientId TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            volumeMl REAL NOT NULL,
            colorCode INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  // ---------- Patient ----------

  Future<void> insertPatient(Patient patient) async {
    final db = await database;
    await db.insert(
      AppConstants.tablePatients,
      patient.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Patient?> getPatientByBedId(String bedId) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tablePatients,
      where: 'bedId = ?',
      whereArgs: [bedId],
    );
    if (maps.isEmpty) return null;
    return Patient.fromMap(maps.first);
  }

  Future<List<Patient>> getAllPatients() async {
    final db = await database;
    final maps = await db.query(AppConstants.tablePatients);
    return maps.map((m) => Patient.fromMap(m)).toList();
  }

  Future<void> deletePatient(String id) async {
    final db = await database;
    await db.delete(
      AppConstants.tablePatients,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ---------- Urine Record ----------

  Future<void> insertUrineRecord(UrineRecord record) async {
    final db = await database;
    await db.insert(
      AppConstants.tableUrineRecords,
      record.toMap()..remove('id'),
    );
  }

  // ดึงข้อมูลทั้งหมดของผู้ป่วย เรียงจากล่าสุดไปเก่าสุด
  Future<List<UrineRecord>> getRecordsByPatient(String patientId) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableUrineRecords,
      where: 'patientId = ?',
      whereArgs: [patientId],
      orderBy: 'timestamp DESC',
    );
    return maps.map((m) => UrineRecord.fromMap(m)).toList();
  }

  // ดึงข้อมูลตามช่วงเวลา ใช้สำหรับกราฟรายชั่วโมง / หน้า History
  Future<List<UrineRecord>> getRecordsByDateRange(
      String patientId,
      DateTime start,
      DateTime end,
      ) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableUrineRecords,
      where: 'patientId = ? AND timestamp BETWEEN ? AND ?',
      whereArgs: [
        patientId,
        start.toIso8601String(),
        end.toIso8601String(),
      ],
      orderBy: 'timestamp ASC',
    );
    return maps.map((m) => UrineRecord.fromMap(m)).toList();
  }
}