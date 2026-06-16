/// SQLite edge database for offline-first kiosk operation.
/// Uses WAL mode for concurrent reads during recognition.
library;

import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants.dart';

class EdgeDatabase {
  static Database? _db;
  static final EdgeDatabase instance = EdgeDatabase._();

  EdgeDatabase._();

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: (db) async {
        // Enable WAL mode for better concurrent performance
        await db.execute('PRAGMA journal_mode=WAL');
        await db.execute('PRAGMA synchronous=NORMAL');
        await db.execute('PRAGMA cache_size=2000');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Employee cache
    await db.execute('''
      CREATE TABLE employees (
        id TEXT PRIMARY KEY,
        employee_code TEXT NOT NULL,
        name TEXT NOT NULL,
        department TEXT,
        designation TEXT,
        gender TEXT,
        photo_url TEXT,
        shift_name TEXT DEFAULT 'Morning Shift',
        shift_start_hour INTEGER DEFAULT 9,
        shift_start_minute INTEGER DEFAULT 0,
        updated_at TEXT,
        synced_at TEXT NOT NULL
      )
    ''');

    // Face embeddings cache
    await db.execute('''
      CREATE TABLE embeddings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        employee_id TEXT NOT NULL,
        angle TEXT NOT NULL DEFAULT 'front',
        embedding TEXT NOT NULL,
        day_slot INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE
      )
    ''');

    // Attendance queue (offline-first)
    await db.execute('''
      CREATE TABLE attendance_queue (
        id TEXT PRIMARY KEY,
        employee_id TEXT NOT NULL,
        action TEXT NOT NULL,
        confidence REAL NOT NULL DEFAULT 1.0,
        detected_at TEXT NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0,
        sync_attempts INTEGER NOT NULL DEFAULT 0,
        last_sync_error TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Local attendance log (for UI display)
    await db.execute('''
      CREATE TABLE local_attendance (
        id TEXT PRIMARY KEY,
        employee_id TEXT NOT NULL,
        employee_name TEXT NOT NULL,
        action TEXT NOT NULL,
        confidence REAL,
        timestamp TEXT NOT NULL
      )
    ''');

    // Kiosk settings & state
    await db.execute('''
      CREATE TABLE kiosk_state (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_embeddings_employee ON embeddings(employee_id)');
    await db.execute('CREATE INDEX idx_queue_synced ON attendance_queue(synced)');
    await db.execute('CREATE INDEX idx_attendance_timestamp ON local_attendance(timestamp)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE employees ADD COLUMN designation TEXT');
      await db.execute('ALTER TABLE employees ADD COLUMN shift_name TEXT DEFAULT \'Morning Shift\'');
      await db.execute('ALTER TABLE employees ADD COLUMN shift_start_hour INTEGER DEFAULT 9');
      await db.execute('ALTER TABLE employees ADD COLUMN shift_start_minute INTEGER DEFAULT 0');
    }
  }

  // === Employee Operations ===

  Future<void> upsertEmployee(Map<String, dynamic> employee) async {
    final db = await database;
    await db.insert(
      'employees',
      {
        'id': employee['employee_id'],
        'employee_code': employee['employee_code'],
        'name': employee['name'],
        'department': employee['department'],
        'designation': employee['designation'],
        'gender': employee['gender'],
        'photo_url': employee['photo_url'],
        'shift_name': employee['shift_name'] ?? 'Morning Shift',
        'shift_start_hour': employee['shift_start_hour'] ?? 9,
        'shift_start_minute': employee['shift_start_minute'] ?? 0,
        'updated_at': employee['updated_at'],
        'synced_at': DateTime.now().toUtc().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> upsertEmbeddings(String employeeId, List<dynamic> embeddings) async {
    final db = await database;
    // Remove old embeddings for this employee
    await db.delete('embeddings', where: 'employee_id = ?', whereArgs: [employeeId]);

    for (final emb in embeddings) {
      await db.insert('embeddings', {
        'employee_id': employeeId,
        'angle': emb['angle'] ?? 'front',
        'embedding': jsonEncode(emb['embedding']),
        'day_slot': emb['day_slot'] ?? 0,
      });
    }
  }

  /// Load all embeddings into memory for fast recognition.
  Future<Map<String, EmployeeEmbeddings>> loadAllEmbeddings() async {
    final db = await database;
    final employees = await db.query('employees');
    final allEmbeddings = await db.query('embeddings');

    final result = <String, EmployeeEmbeddings>{};

    for (final emp in employees) {
      final empId = emp['id'] as String;
      final empEmbeddings = allEmbeddings
          .where((e) => e['employee_id'] == empId)
          .map((e) {
            final List<dynamic> parsed = jsonDecode(e['embedding'] as String);
            return parsed.map((v) => (v as num).toDouble()).toList();
          })
          .toList();

      if (empEmbeddings.isNotEmpty) {
        result[empId] = EmployeeEmbeddings(
          employeeId: empId,
          employeeCode: emp['employee_code'] as String,
          name: emp['name'] as String,
          department: emp['department'] as String?,
          designation: emp['designation'] as String?,
          gender: emp['gender'] as String?,
          photoUrl: emp['photo_url'] as String?,
          shiftName: (emp['shift_name'] as String?) ?? 'Morning Shift',
          shiftStartHour: (emp['shift_start_hour'] as int?) ?? 9,
          shiftStartMinute: (emp['shift_start_minute'] as int?) ?? 0,
          embeddings: empEmbeddings,
        );
      }
    }

    return result;
  }

  // === Attendance Queue Operations ===

  Future<void> enqueueAttendance({
    required String id,
    required String employeeId,
    required String action,
    required double confidence,
  }) async {
    final db = await database;
    final now = DateTime.now().toUtc().toIso8601String();
    await db.insert('attendance_queue', {
      'id': id,
      'employee_id': employeeId,
      'action': action,
      'confidence': confidence,
      'detected_at': now,
      'synced': 0,
      'sync_attempts': 0,
      'created_at': now,
    });
  }

  Future<List<Map<String, dynamic>>> getUnsyncedAttendance({int limit = 50}) async {
    final db = await database;
    return await db.query(
      'attendance_queue',
      where: 'synced = 0',
      orderBy: 'created_at ASC',
      limit: limit,
    );
  }

  Future<void> markSynced(List<String> ids) async {
    final db = await database;
    final batch = db.batch();
    for (final id in ids) {
      batch.update(
        'attendance_queue',
        {'synced': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> incrementSyncAttempt(String id, String error) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE attendance_queue SET sync_attempts = sync_attempts + 1, last_sync_error = ? WHERE id = ?',
      [error, id],
    );
  }

  Future<int> getQueueDepth() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM attendance_queue WHERE synced = 0');
    return (result.first['count'] as int?) ?? 0;
  }

  // === Local Attendance Log ===

  Future<void> addLocalAttendance({
    required String id,
    required String employeeId,
    required String employeeName,
    required String action,
    double? confidence,
  }) async {
    final db = await database;
    await db.insert('local_attendance', {
      'id': id,
      'employee_id': employeeId,
      'employee_name': employeeName,
      'action': action,
      'confidence': confidence,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getRecentAttendance({int limit = 20}) async {
    final db = await database;
    return await db.query(
      'local_attendance',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
  }

  // === State Management ===

  Future<void> setState(String key, String value) async {
    final db = await database;
    await db.insert(
      'kiosk_state',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getState(String key) async {
    final db = await database;
    final result = await db.query('kiosk_state', where: 'key = ?', whereArgs: [key]);
    return result.isEmpty ? null : result.first['value'] as String?;
  }

  // === Cleanup ===

  Future<void> cleanOldSyncedRecords({int keepDays = 7}) async {
    final db = await database;
    final cutoff = DateTime.now().subtract(Duration(days: keepDays)).toUtc().toIso8601String();
    await db.delete(
      'attendance_queue',
      where: 'synced = 1 AND created_at < ?',
      whereArgs: [cutoff],
    );
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}

/// In-memory representation of an employee's embeddings for fast matching.
class EmployeeEmbeddings {
  final String employeeId;
  final String employeeCode;
  final String name;
  final String? department;
  final String? designation;
  final String? gender;
  final String? photoUrl;
  final String shiftName;
  final int shiftStartHour;
  final int shiftStartMinute;
  final List<List<double>> embeddings;

  EmployeeEmbeddings({
    required this.employeeId,
    required this.employeeCode,
    required this.name,
    this.department,
    this.designation,
    this.gender,
    this.photoUrl,
    this.shiftName = 'Morning Shift',
    this.shiftStartHour = 9,
    this.shiftStartMinute = 0,
    required this.embeddings,
  });
}
