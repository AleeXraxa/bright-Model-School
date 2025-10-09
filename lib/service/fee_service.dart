import 'package:sqflite/sqflite.dart';
import '../model/fee_model.dart';
import 'database_service.dart';

class FeeService {
  final DatabaseService _dbService = DatabaseService();

  Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS fees (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        fee_type TEXT NOT NULL,
        amount TEXT NOT NULL,
        status TEXT NOT NULL,
        due_date TEXT,
        paid_date TEXT,
        description TEXT,
        FOREIGN KEY (student_id) REFERENCES students (id)
      )
    ''');
  }

  Future<void> initialize() async {
    final db = await _dbService.database;
    await createTable(db);
  }

  Future<List<FeeModel>> getFees({
    String? feeType,
    String? status,
    int? studentId,
    int? limit,
    int? offset,
  }) async {
    final db = await _dbService.database;
    String where = '';
    List<dynamic> whereArgs = [];

    if (feeType != null && feeType.isNotEmpty) {
      where += 'fee_type = ?';
      whereArgs.add(feeType);
    }

    if (status != null && status.isNotEmpty) {
      if (where.isNotEmpty) where += ' AND ';
      where += 'status = ?';
      whereArgs.add(status);
    }

    if (studentId != null) {
      if (where.isNotEmpty) where += ' AND ';
      where += 'student_id = ?';
      whereArgs.add(studentId);
    }

    final maps = await db.query(
      'fees',
      where: where.isEmpty ? null : where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      limit: limit,
      offset: offset,
      orderBy: 'id DESC', // Most recent first
    );

    return maps.map((map) => FeeModel.fromMap(map)).toList();
  }

  Future<int> getTotalCount({
    String? feeType,
    String? status,
    int? studentId,
  }) async {
    final db = await _dbService.database;
    String where = '';
    List<dynamic> whereArgs = [];

    if (feeType != null && feeType.isNotEmpty) {
      where += 'fee_type = ?';
      whereArgs.add(feeType);
    }

    if (status != null && status.isNotEmpty) {
      if (where.isNotEmpty) where += ' AND ';
      where += 'status = ?';
      whereArgs.add(status);
    }

    if (studentId != null) {
      if (where.isNotEmpty) where += ' AND ';
      where += 'student_id = ?';
      whereArgs.add(studentId);
    }

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM fees ${where.isEmpty ? '' : 'WHERE $where'}',
      whereArgs,
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<FeeModel?> getFeeById(int id) async {
    final db = await _dbService.database;
    final maps = await db.query('fees', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return FeeModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertFee(FeeModel fee) async {
    final db = await _dbService.database;
    return await db.insert('fees', fee.toMap());
  }

  Future<int> updateFee(FeeModel fee) async {
    final db = await _dbService.database;
    return await db.update(
      'fees',
      fee.toMap(),
      where: 'id = ?',
      whereArgs: [fee.id],
    );
  }

  Future<int> deleteFee(int id) async {
    final db = await _dbService.database;
    return await db.delete('fees', where: 'id = ?', whereArgs: [id]);
  }

  // Get pending fees for a specific type, with student info (includes both pending and partial payments)
  Future<List<Map<String, dynamic>>> getPendingFeesWithStudentInfo(
    String feeType, {
    int? limit,
  }) async {
    final db = await _dbService.database;
    final query =
        '''
      SELECT f.*, s.name as student_name, s.father_name, s.roll, s.account_number, s.class, s.section
      FROM fees f
      JOIN students s ON f.student_id = s.id
      WHERE f.fee_type = ? AND f.status IN ('pending', 'partial')
      ORDER BY f.id DESC
      ${limit != null ? 'LIMIT ?' : ''}
    ''';
    final List<Object> args = [feeType];
    if (limit != null) args.add(limit);

    return await db.rawQuery(query, args);
  }

  // Get paid fees for a specific type, with student info (includes partial and fully paid)
  Future<List<Map<String, dynamic>>> getPaidFeesWithStudentInfo(
    String feeType, {
    int? limit,
  }) async {
    final db = await _dbService.database;
    final query =
        '''
      SELECT f.*, s.name as student_name, s.father_name, s.roll, s.account_number, s.class, s.section
      FROM fees f
      JOIN students s ON f.student_id = s.id
      WHERE f.fee_type = ? AND f.status IN ('partial', 'paid')
      ORDER BY f.id DESC
      ${limit != null ? 'LIMIT ?' : ''}
    ''';
    final List<Object> args = [feeType];
    if (limit != null) args.add(limit);

    return await db.rawQuery(query, args);
  }
}
