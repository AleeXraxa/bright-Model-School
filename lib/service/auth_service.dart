import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import '../model/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String usersTable = 'users';

  Future<void> initDB() async {
    final Database db = await DatabaseService().database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $usersTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        role TEXT
      )
    ''');

    // Seed a few users if table is empty
    final int? count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $usersTable'),
    );
    if ((count ?? 0) == 0) {
      final List<UserModel> seeds = [
        UserModel(username: 'admin', password: 'admin123', role: 'Admin'),
        UserModel(
          username: 'account',
          password: 'account123',
          role: 'Accountant',
        ),
        UserModel(username: 'staff', password: 'staff123', role: 'Staff'),
      ];
      for (final u in seeds) {
        await registerUser(u);
      }
    }
  }

  Future<UserModel?> login(String username, String password) async {
    final Database db = await DatabaseService().database;
    final List<Map<String, Object?>> rows = await db.query(
      usersTable,
      where: 'username = ? AND password = ?',
      whereArgs: [username.trim(), password],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  Future<void> registerUser(UserModel user) async {
    final Database db = await DatabaseService().database;
    await db.insert(
      usersTable,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> logout() async {
    // Placeholder for clearing session data. Hook SharedPreferences or a session table as needed.
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}
