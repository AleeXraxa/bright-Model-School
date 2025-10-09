class FeeModel {
  final int? id;
  final int studentId;
  final String feeType; // 'admission', 'monthly', 'exam', 'misc'
  final String amount;
  final String status; // 'pending', 'paid', 'partial'
  final String? dueDate;
  final String? paidDate;
  final String? description;
  final String? paidAmount; // For partial payments
  final String? paymentMode; // 'cash', 'online'
  final String? remainingAmount; // For partial payments

  FeeModel({
    this.id,
    required this.studentId,
    required this.feeType,
    required this.amount,
    required this.status,
    this.dueDate,
    this.paidDate,
    this.description,
    this.paidAmount,
    this.paymentMode,
    this.remainingAmount,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'student_id': studentId,
    'fee_type': feeType,
    'amount': amount,
    'status': status,
    if (dueDate != null) 'due_date': dueDate,
    if (paidDate != null) 'paid_date': paidDate,
    if (description != null) 'description': description,
    if (paidAmount != null) 'paid_amount': paidAmount,
    if (paymentMode != null) 'payment_mode': paymentMode,
    if (remainingAmount != null) 'remaining_amount': remainingAmount,
  };

  factory FeeModel.fromMap(Map<String, dynamic> map) => FeeModel(
    id: map['id'] as int?,
    studentId: map['student_id'] as int,
    feeType: map['fee_type'] as String,
    amount: map['amount'] as String,
    status: map['status'] as String,
    dueDate: map['due_date'] as String?,
    paidDate: map['paid_date'] as String?,
    description: map['description'] as String?,
    paidAmount: map['paid_amount'] as String?,
    paymentMode: map['payment_mode'] as String?,
    remainingAmount: map['remaining_amount'] as String?,
  );

  // Helper methods
  double get totalAmount => double.tryParse(amount) ?? 0.0;
  double get paidAmountValue => double.tryParse(paidAmount ?? '0') ?? 0.0;
  double get remainingAmountValue =>
      double.tryParse(remainingAmount ?? amount) ?? totalAmount;

  bool get isFullyPaid => status == 'paid';
  bool get isPartiallyPaid => status == 'partial';
  bool get isPending => status == 'pending';
}
