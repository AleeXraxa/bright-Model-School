import 'package:get/get.dart';
import '../model/fee_model.dart';
import '../model/payment_model.dart';
import '../service/fee_service.dart';
import '../service/payment_service.dart';

class FeesController extends GetxController {
  final FeeService _feeService = FeeService();
  final PaymentService _paymentService = PaymentService();

  final RxList<Map<String, dynamic>> admissionFees =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> monthlyFees = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> paidAdmissionFees =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> paidMonthlyFees =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeService();
  }

  Future<void> _initializeService() async {
    await _feeService.initialize();
    await _paymentService.initialize();
    _loadFees();
  }

  Future<void> _loadFees() async {
    isLoading.value = true;
    try {
      // Load recent pending admission fees (limit 5)
      final admissionData = await _feeService.getPendingFeesWithStudentInfo(
        'admission',
        limit: 5,
      );
      admissionFees.value = admissionData;

      // Load recent pending monthly fees (limit 5)
      final monthlyData = await _feeService.getPendingFeesWithStudentInfo(
        'monthly',
        limit: 5,
      );
      monthlyFees.value = monthlyData;

      // Load recent paid admission fees (limit 5)
      final paidAdmissionData = await _feeService.getPaidFeesWithStudentInfo(
        'admission',
        limit: 5,
      );
      paidAdmissionFees.value = paidAdmissionData;

      // Load recent paid monthly fees (limit 5)
      final paidMonthlyData = await _feeService.getPaidFeesWithStudentInfo(
        'monthly',
        limit: 5,
      );
      paidMonthlyFees.value = paidMonthlyData;
    } catch (e) {
      print('Error loading fees: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> getAllPendingFees(String feeType) async {
    return await _feeService.getPendingFeesWithStudentInfo(feeType);
  }

  Future<List<Map<String, dynamic>>> getAllPaidFees(String feeType) async {
    return await _feeService.getPaidFeesWithStudentInfo(feeType);
  }

  Future<void> payFee(
    int feeId, {
    String? paymentAmount,
    String? paymentMode,
  }) async {
    try {
      final fee = await _feeService.getFeeById(feeId);
      if (fee != null) {
        final totalAmount = double.tryParse(fee.amount) ?? 0.0;
        final payAmount = paymentAmount != null
            ? double.tryParse(paymentAmount) ?? 0.0
            : totalAmount;

        // Record the individual payment transaction
        final payment = PaymentModel(
          feeId: feeId,
          amount: payAmount.toString(),
          paymentMode: paymentMode ?? 'cash',
          paymentDate: DateTime.now().toIso8601String(),
        );
        await _paymentService.insertPayment(payment);

        // Calculate new totals
        final existingPayments = await _paymentService.getPaymentsByFeeId(
          feeId,
        );
        final totalPaid = existingPayments.fold<double>(
          0.0,
          (sum, payment) => sum + (double.tryParse(payment.amount) ?? 0.0),
        );
        final remaining = totalAmount - totalPaid;

        String status;
        if (remaining <= 0) {
          // Full payment
          status = 'paid';
        } else {
          // Partial payment
          status = 'partial';
        }

        final updatedFee = FeeModel(
          id: fee.id,
          studentId: fee.studentId,
          feeType: fee.feeType,
          amount: fee.amount,
          status: status,
          dueDate: fee.dueDate,
          paidDate: DateTime.now().toIso8601String(),
          description: fee.description,
          paidAmount: totalPaid.toString(),
          paymentMode: paymentMode,
          remainingAmount: remaining.toString(),
        );
        await _feeService.updateFee(updatedFee);
        // Refresh the lists
        await _loadFees();
      }
    } catch (e) {
      print('Error paying fee: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPaymentHistory(int feeId) async {
    return await _paymentService.getPaymentHistoryWithRemaining(feeId);
  }

  Future<void> refreshFees() async {
    await _loadFees();
  }
}
