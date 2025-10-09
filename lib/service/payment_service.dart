import 'package:sqflite/sqflite.dart';
import '../model/payment_model.dart';
import 'database_service.dart';

class PaymentService {
  final DatabaseService _dbService = DatabaseService();

  Future<void> createTable(Database db) async {
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

  Future<void> initialize() async {
    final db = await _dbService.database;
    await createTable(db);
  }

  Future<List<PaymentModel>> getPaymentsByFeeId(int feeId) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'payments',
      where: 'fee_id = ?',
      whereArgs: [feeId],
      orderBy: 'payment_date DESC', // Most recent first
    );

    return maps.map((map) => PaymentModel.fromMap(map)).toList();
  }

  Future<int> insertPayment(PaymentModel payment) async {
    final db = await _dbService.database;
    return await db.insert('payments', payment.toMap());
  }

  Future<int> updatePayment(PaymentModel payment) async {
    final db = await _dbService.database;
    return await db.update(
      'payments',
      payment.toMap(),
      where: 'id = ?',
      whereArgs: [payment.id],
    );
  }

  Future<int> deletePayment(int id) async {
    final db = await _dbService.database;
    return await db.delete('payments', where: 'id = ?', whereArgs: [id]);
  }

  // Get payment history with remaining amount calculation
  Future<List<Map<String, dynamic>>> getPaymentHistoryWithRemaining(
    int feeId,
  ) async {
    final db = await _dbService.database;

    // Get the fee details first
    final feeResult = await db.query(
      'fees',
      where: 'id = ?',
      whereArgs: [feeId],
    );
    if (feeResult.isEmpty) return [];

    final fee = feeResult.first;
    final totalAmount = double.tryParse((fee['amount'] as String?) ?? '0') ?? 0;

    // Get all payments for this fee
    final payments = await getPaymentsByFeeId(feeId);

    // Calculate remaining amount after each payment
    double runningTotal = 0;
    final history = <Map<String, dynamic>>[];

    for (final payment in payments) {
      runningTotal += double.tryParse(payment.amount) ?? 0;
      final remainingAfterPayment = totalAmount - runningTotal;

      history.add({
        'id': payment.id,
        'fee_id': payment.feeId,
        'amount': payment.amount,
        'payment_mode': payment.paymentMode,
        'payment_date': payment.paymentDate,
        'remaining_after_payment': remainingAfterPayment.toStringAsFixed(2),
        'notes': payment.notes,
      });
    }

    return history;
  }
}
