import 'package:sqflite/sqflite.dart';
import '../model/class_model.dart';
import 'database_service.dart';

class ClassService {
  final DatabaseService _dbService = DatabaseService();

  Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS classes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        class TEXT NOT NULL,
        section TEXT NOT NULL,
        student_count INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> initialize() async {
    final db = await _dbService.database;
    await createTable(db);
    // Data inserted in database_service onCreate
  }

  Future<List<ClassModel>> getClasses({
    String? search,
    int? limit,
    int? offset,
  }) async {
    final db = await _dbService.database;
    String where = '';
    List<dynamic> whereArgs = [];

    if (search != null && search.isNotEmpty) {
      where += '(class LIKE ? OR section LIKE ?)';
      whereArgs.addAll(['%$search%', '%$search%']);
    }

    final maps = await db.query(
      'classes',
      where: where.isEmpty ? null : where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      limit: limit,
      offset: offset,
      orderBy: 'id ASC',
    );

    return maps.map((map) => ClassModel.fromMap(map)).toList();
  }

  Future<int> getTotalCount({String? search}) async {
    final db = await _dbService.database;
    String where = '';
    List<dynamic> whereArgs = [];

    if (search != null && search.isNotEmpty) {
      where += '(class LIKE ? OR section LIKE ?)';
      whereArgs.addAll(['%$search%', '%$search%']);
    }

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM classes ${where.isEmpty ? '' : 'WHERE $where'}',
      whereArgs,
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<ClassModel?> getClassById(int id) async {
    final db = await _dbService.database;
    final maps = await db.query('classes', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return ClassModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertClass(ClassModel classModel) async {
    final db = await _dbService.database;
    return await db.insert('classes', classModel.toMap());
  }

  Future<int> updateClass(ClassModel classModel) async {
    final db = await _dbService.database;
    return await db.update(
      'classes',
      classModel.toMap(),
      where: 'id = ?',
      whereArgs: [classModel.id],
    );
  }

  Future<int> deleteClass(int id) async {
    final db = await _dbService.database;
    return await db.delete('classes', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> isClassUnique(
    String className,
    String section, {
    int? excludeId,
  }) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'classes',
      where:
          'class = ? AND section = ? ${excludeId != null ? 'AND id != ?' : ''}',
      whereArgs: [className, section, if (excludeId != null) excludeId],
    );
    return maps.isEmpty;
  }
}
