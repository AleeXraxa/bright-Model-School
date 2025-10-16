import 'package:get/get.dart';
import '../model/fee_model.dart';
import '../model/payment_model.dart';
import '../model/class_model.dart';
import '../service/fee_service.dart';
import '../service/payment_service.dart';
import 'classes_controller.dart';

class FeesController extends GetxController {
  final FeeService _feeService = FeeService();
  final PaymentService _paymentService = PaymentService();

  final RxList<Map<String, dynamic>> admissionFees =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> monthlyFees = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> examFees = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> miscFees = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> paidAdmissionFees =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> paidMonthlyFees =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> paidExamFees =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> paidMiscFees =
      <Map<String, dynamic>>[].obs;
  final RxString selectedMonth = ''.obs;
  ClassModel? selectedClassModel;
  final RxList<ClassModel> classList = <ClassModel>[].obs;
  final RxList<String> monthList = <String>[].obs;
  final RxBool isLoading = false.obs;

  static const List<String> _monthAbbrs = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _monthAbbr(int month) => _monthAbbrs[month - 1];

  @override
  void onInit() {
    super.onInit();
    _initializeService();
  }

  Future<void> _initializeService() async {
    await _feeService.initialize();
    await _paymentService.initialize();
    _loadClasses();
    _loadFees();
  }

  void _loadClasses() {
    if (!Get.isRegistered<ClassesController>()) {
      Get.put(ClassesController());
    }
    final classesController = Get.find<ClassesController>();
    // Initial assignment
    classList.assignAll(classesController.classes);
    // Listen for changes
    classesController.classes.listen((classes) {
      classList.assignAll(classes);
      update();
    });
    _generateMonthList();
  }

  void _generateMonthList() {
    final now = DateTime.now();
    final months = <String>[];
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    for (int i = -6; i <= 6; i++) {
      final date = DateTime(now.year, now.month + i, 1);
      months.add('${monthNames[date.month - 1]} ${date.year}');
    }
    monthList.assignAll(months);
  }

  Future<void> _loadFees() async {
    isLoading.value = true;
    try {
      // Set current month in full format
      final now = DateTime.now();
      const monthNames = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      selectedMonth.value = '${monthNames[now.month - 1]} ${now.year}';

      // Load recent pending admission fees (limit 5)
      final admissionData = await _feeService.getPendingFeesWithStudentInfo(
        'admission',
        limit: 5,
      );
      admissionFees.value = admissionData;

      // Monthly fees will be loaded when class and month are selected

      // Load recent pending exam fees (limit 5)
      final examData = await _feeService.getPendingFeesWithStudentInfo(
        'exam',
        limit: 5,
      );
      examFees.value = examData;

      // Load recent pending misc fees (limit 5)
      final miscData = await _feeService.getPendingFeesWithStudentInfo(
        'misc',
        limit: 5,
      );
      miscFees.value = miscData;

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

      // Load recent paid exam fees (limit 5)
      final paidExamData = await _feeService.getPaidFeesWithStudentInfo(
        'exam',
        limit: 5,
      );
      paidExamFees.value = paidExamData;

      // Load recent paid misc fees (limit 5)
      final paidMiscData = await _feeService.getPaidFeesWithStudentInfo(
        'misc',
        limit: 5,
      );
      paidMiscFees.value = paidMiscData;
    } catch (e) {
      print('Error loading fees: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> getAllPendingFees(
    String feeType, {
    String? month,
    int? classId,
  }) async {
    return await _feeService.getPendingFeesWithStudentInfo(
      feeType,
      month: month,
      classId: classId,
    );
  }

  Future<List<Map<String, dynamic>>> getAllPaidFees(
    String feeType, {
    String? month,
    int? classId,
  }) async {
    return await _feeService.getPaidFeesWithStudentInfo(
      feeType,
      month: month,
      classId: classId,
    );
  }

  Future<void> _loadMonthlyFees() async {
    final monthKey = _displayToMonthKey(selectedMonth.value);
    final data = await _feeService.getPendingFeesWithStudentInfo(
      'monthly',
      limit: 5,
    );
    final filtered = data.where((fee) {
      final dueDate = fee['due_date'];
      if (dueDate == null) return false;
      return dueDate.toString().startsWith(monthKey);
    }).toList();
    monthlyFees.value = filtered;
  }

  String _displayToMonthKey(String display) {
    final parts = display.split(' ');
    if (parts.length != 2) return '';
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final monthName = parts[0];
    final yearStr = parts[1];
    final month = monthNames.indexOf(monthName) + 1;
    final year = int.tryParse(yearStr)!;
    return '${year}-${month.toString().padLeft(2, '0')}';
  }

  Future<void> loadMonthlyFeesForMonth(String displayMonth) async {
    selectedMonth.value = displayMonth;
    await _loadMonthlyFees();
  }

  Future<void> fetchMonthlyFeesData() async {
    if (selectedClassModel == null || selectedMonth.isEmpty) {
      monthlyFees.value = [];
      paidMonthlyFees.value = [];
      update();
      return;
    }
    final classId = selectedClassModel!.id;

    print(
      'Debug: Filtering monthly fees - selectedClassId: $classId, selectedMonth: ${selectedMonth.value}',
    );

    final monthKey = _displayToMonthKey(selectedMonth.value);
    print('Debug: Month key: $monthKey');

    // Debug: Check all monthly fees for this class
    final allMonthlyFees = await _feeService.getPendingFeesWithStudentInfo(
      'monthly',
      classId: classId,
    );
    print(
      'Debug: Total monthly fees for class $classId: ${allMonthlyFees.length}',
    );
    for (var fee in allMonthlyFees) {
      print(
        'Debug: Fee - due_date: ${fee['due_date']}, status: ${fee['status']}',
      );
    }
    final monthFees = allMonthlyFees
        .where((f) => f['due_date']?.toString().startsWith(monthKey) ?? false)
        .toList();
    print(
      'Debug: Monthly fees for ${selectedMonth.value} ($monthKey): ${monthFees.length}',
    );

    final allPending = await _feeService.getPendingFeesWithStudentInfo(
      'monthly',
      classId: classId,
    );
    final allPaid = await _feeService.getPaidFeesWithStudentInfo(
      'monthly',
      classId: classId,
    );

    final pending = allPending; // TODO: filter by due_date when set properly
    final paid = allPaid; // TODO: filter by due_date when set properly

    print(
      'Debug: Found ${pending.length} pending and ${paid.length} paid monthly fees',
    );

    monthlyFees.value = [...pending];
    paidMonthlyFees.value = [...paid];
    update();
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
