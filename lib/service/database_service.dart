import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    final Database? existing = _database;
    if (existing != null) return existing;
    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String dbPath;
    if (kIsWeb) {
      // For web, use a simple path
      dbPath = 'bright_sms.db';
    } else {
      // Fall back to path_provider for app support dir; on Windows/Linux it's fine after ffi init
      final dir = await getApplicationSupportDirectory();
      dbPath = p.join(dir.path, 'bright_sms.db');
    }

    return databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 12,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS students (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              class_id INTEGER,
              name TEXT NOT NULL,
              roll TEXT NOT NULL,
              gr_no TEXT,
              class TEXT NOT NULL,
              section TEXT NOT NULL,
              father_name TEXT NOT NULL,
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
              admission_date TEXT,
              FOREIGN KEY (class_id) REFERENCES classes (id)
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS classes (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              class TEXT NOT NULL,
              section TEXT NOT NULL,
              student_count INTEGER DEFAULT 0
            )
          ''');
          // Insert dummy data for classes only
          final classes = [
            {'class': 'Class 9', 'section': 'A', 'student_count': 0},
            {'class': 'Class 9', 'section': 'B', 'student_count': 0},
            {'class': 'Class 10', 'section': 'A', 'student_count': 0},
            {'class': 'Class 10', 'section': 'B', 'student_count': 0},
            {'class': 'Class 11', 'section': 'A', 'student_count': 0},
            {'class': 'Class 11', 'section': 'B', 'student_count': 0},
            {'class': 'Class 12', 'section': 'A', 'student_count': 0},
            {'class': 'Class 12', 'section': 'B', 'student_count': 0},
          ];
          final batch = db.batch();
          for (final classData in classes) {
            batch.insert('classes', classData);
          }
          await batch.commit();
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
              paid_amount TEXT,
              payment_mode TEXT,
              remaining_amount TEXT,
              fee_month TEXT,
              FOREIGN KEY (student_id) REFERENCES students (id)
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS payments (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              fee_id INTEGER NOT NULL,
              amount TEXT NOT NULL,
              payment_mode TEXT NOT NULL,
              payment_date TEXT NOT NULL,
              notes TEXT,
              FOREIGN KEY (fee_id) REFERENCES fees (id)
            )
          ''');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            // Add new columns to students table
            await db.execute('ALTER TABLE students ADD COLUMN gr_no TEXT');
            await db.execute('ALTER TABLE students ADD COLUMN caste TEXT');
            await db.execute(
              'ALTER TABLE students ADD COLUMN place_of_birth TEXT',
            );
            await db.execute(
              'ALTER TABLE students ADD COLUMN date_of_birth_figures TEXT',
            );
            await db.execute(
              'ALTER TABLE students ADD COLUMN date_of_birth_words TEXT',
            );
            await db.execute('ALTER TABLE students ADD COLUMN gender TEXT');
            await db.execute('ALTER TABLE students ADD COLUMN religion TEXT');
            await db.execute(
              'ALTER TABLE students ADD COLUMN father_contact TEXT',
            );
            await db.execute(
              'ALTER TABLE students ADD COLUMN mother_contact TEXT',
            );
            await db.execute('ALTER TABLE students ADD COLUMN address TEXT');
            await db.execute(
              'ALTER TABLE students ADD COLUMN admission_fees TEXT',
            );
            await db.execute(
              'ALTER TABLE students ADD COLUMN monthly_fees TEXT',
            );
            await db.execute(
              'ALTER TABLE students ADD COLUMN account_number TEXT',
            );
          }
          if (oldVersion < 3) {
            // Add class_id column to students table for foreign key relationship
            await db.execute(
              'ALTER TABLE students ADD COLUMN class_id INTEGER REFERENCES classes(id)',
            );
          }
          if (oldVersion < 4) {
            // Add admission_date column to students table
            await db.execute(
              'ALTER TABLE students ADD COLUMN admission_date TEXT',
            );
          }
          if (oldVersion < 5) {
            // Create fees table
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
                paid_amount TEXT,
                payment_mode TEXT,
                remaining_amount TEXT,
                FOREIGN KEY (student_id) REFERENCES students (id)
              )
            ''');
          }
          if (oldVersion < 9) {
            // Add payment columns to fees table
            await db.execute('ALTER TABLE fees ADD COLUMN paid_amount TEXT');
            await db.execute('ALTER TABLE fees ADD COLUMN payment_mode TEXT');
            await db.execute(
              'ALTER TABLE fees ADD COLUMN remaining_amount TEXT',
            );
          }
          if (oldVersion < 10) {
            // Create payments table for tracking individual transactions
            await db.execute('''
              CREATE TABLE IF NOT EXISTS payments (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                fee_id INTEGER NOT NULL,
                amount TEXT NOT NULL,
                payment_mode TEXT NOT NULL,
                payment_date TEXT NOT NULL,
                notes TEXT,
                FOREIGN KEY (fee_id) REFERENCES fees (id)
              )
            ''');
          }
          if (oldVersion < 11) {
            // Add fee_month column to fees table
            await db.execute('ALTER TABLE fees ADD COLUMN fee_month TEXT');
          }
          if (oldVersion < 12) {
            // Ensure fee_month column exists (in case onCreate was not updated)
            try {
              await db.execute('ALTER TABLE fees ADD COLUMN fee_month TEXT');
            } catch (e) {
              // Column already exists
            }
          }
        },
      ),
    );
  }
}
