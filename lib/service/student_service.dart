import 'package:sqflite/sqflite.dart';
import '../model/student_model.dart';
import '../model/fee_model.dart';
import 'database_service.dart';
import 'fee_service.dart';

class StudentService {
  final DatabaseService _dbService = DatabaseService();

  Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        class_id INTEGER,
        name TEXT NOT NULL,
        roll TEXT NOT NULL,
        gr_no TEXT,
        class TEXT NOT NULL,
        section TEXT NOT NULL,
        father_name TEXT,
        caste TEXT,
        place_of_birth TEXT,
        date_of_birth_figures TEXT,
        date_of_birth_words TEXT,
        gender TEXT,
        religion TEXT,
        father_contact TEXT,
        mother_contact TEXT,
        address TEXT,
        admission_fees TEXT,
        monthly_fees TEXT,
        account_number TEXT,
        contact TEXT NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY (class_id) REFERENCES classes (id)
      )
    ''');
  }

  Future<void> initialize() async {
    final db = await _dbService.database;
    await createTable(db);
  }

  Future<List<StudentModel>> getStudents({
    String? search,
    List<String>? classes,
    int? limit,
    int? offset,
  }) async {
    final db = await _dbService.database;
    String where = '';
    List<dynamic> whereArgs = [];

    if (search != null && search.isNotEmpty) {
      where += '(name LIKE ? OR roll LIKE ? OR class LIKE ?)';
      whereArgs.addAll(['%$search%', '%$search%', '%$search%']);
    }

    if (classes != null && classes.isNotEmpty) {
      if (where.isNotEmpty) where += ' AND ';
      where += 'class IN (${List.filled(classes.length, '?').join(',')})';
      whereArgs.addAll(classes);
    }

    final maps = await db.query(
      'students',
      where: where.isEmpty ? null : where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      limit: limit,
      offset: offset,
      orderBy: 'id ASC',
    );

    return maps.map((map) => StudentModel.fromMap(map)).toList();
  }

  Future<int> getTotalCount({String? search, List<String>? classes}) async {
    final db = await _dbService.database;
    String where = '';
    List<dynamic> whereArgs = [];

    if (search != null && search.isNotEmpty) {
      where += '(name LIKE ? OR roll LIKE ? OR class LIKE ?)';
      whereArgs.addAll(['%$search%', '%$search%', '%$search%']);
    }

    if (classes != null && classes.isNotEmpty) {
      if (where.isNotEmpty) where += ' AND ';
      where += 'class IN (${List.filled(classes.length, '?').join(',')})';
      whereArgs.addAll(classes);
    }

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM students ${where.isEmpty ? '' : 'WHERE $where'}',
      whereArgs,
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<StudentModel?> getStudentById(int id) async {
    final db = await _dbService.database;
    final maps = await db.query('students', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return StudentModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertStudent(StudentModel student) async {
    final db = await _dbService.database;
    final studentId = await db.insert('students', student.toMap());

    // Auto-create fee records
    final feeService = FeeService();
    await feeService.initialize();

    // Create admission fee record
    if (student.admissionFees.isNotEmpty && student.admissionFees != '0') {
      final admissionFee = FeeModel(
        studentId: studentId,
        feeType: 'admission',
        amount: student.admissionFees,
        status: 'pending',
        dueDate: student.admissionDate.isNotEmpty
            ? student.admissionDate
            : null,
      );
      await feeService.insertFee(admissionFee);
    }

    // Create monthly fee record
    if (student.monthlyFees.isNotEmpty && student.monthlyFees != '0') {
      final monthlyFee = FeeModel(
        studentId: studentId,
        feeType: 'monthly',
        amount: student.monthlyFees,
        status: 'pending',
        dueDate: student.admissionDate.isNotEmpty
            ? student.admissionDate
            : null,
      );
      await feeService.insertFee(monthlyFee);
    }

    return studentId;
  }

  Future<int> updateStudent(StudentModel student) async {
    final db = await _dbService.database;
    return await db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> deleteStudent(int id) async {
    final db = await _dbService.database;
    return await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }
}
