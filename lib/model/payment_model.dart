class PaymentModel {
  final int? id;
  final int feeId;
  final String amount;
  final String paymentMode; // 'cash', 'online'
  final String paymentDate;
  final String? notes;

  PaymentModel({
    this.id,
    required this.feeId,
    required this.amount,
    required this.paymentMode,
    required this.paymentDate,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'fee_id': feeId,
    'amount': amount,
    'payment_mode': paymentMode,
    'payment_date': paymentDate,
    if (notes != null) 'notes': notes,
  };

  factory PaymentModel.fromMap(Map<String, dynamic> map) => PaymentModel(
    id: map['id'] as int?,
    feeId: map['fee_id'] as int,
    amount: map['amount'] as String,
    paymentMode: map['payment_mode'] as String,
    paymentDate: map['payment_date'] as String,
    notes: map['notes'] as String?,
  );
}
