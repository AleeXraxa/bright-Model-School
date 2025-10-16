import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../model/student_model.dart';
import '../model/fee_model.dart';
import '../service/student_service.dart';
import '../service/fee_service.dart';
import 'fees_controller.dart';

enum StudentFilter { all, class9, class10, class11, class12 }

class StudentsController extends GetxController {
  final StudentService _studentService = StudentService();
  final FeeService _feeService = FeeService();
  final Rx<StudentFilter> activeFilter = StudentFilter.all.obs;
  final RxInt rowsPerPage = 10.obs;
  final RxInt currentPage = 1.obs;
  final TextEditingController searchController = TextEditingController();

  final RxList<StudentModel> students = <StudentModel>[].obs;
  final RxInt totalStudents = 0.obs;
  final RxBool isLoading = false.obs;

  // Computed filtered students
  List<StudentModel> get filteredStudents {
    var filtered = students.toList();

    // Apply search filter
    final search = searchController.text.trim().toLowerCase();
    if (search.isNotEmpty) {
      filtered = filtered
          .where(
            (student) =>
                student.name.toLowerCase().contains(search) ||
                student.roll.toLowerCase().contains(search) ||
                student.studentClass.toLowerCase().contains(search),
          )
          .toList();
    }

    // Apply class filter
    if (activeFilter.value != StudentFilter.all) {
      final className = _filterToClass(activeFilter.value);
      filtered = filtered
          .where((student) => student.studentClass == className)
          .toList();
    }

    return filtered;
  }

  // Paginated students for UI
  List<StudentModel> get paginatedStudents {
    final start = (currentPage.value - 1) * rowsPerPage.value;
    final end = (start + rowsPerPage.value).clamp(0, filteredStudents.length);
    return filteredStudents.sublist(start, end);
  }

  // Computed total for current filter
  int get filteredTotal => filteredStudents.length;

  @override
  void onInit() {
    super.onInit();
    _initializeService();
    searchController.addListener(_onSearchChanged);
  }

  Future<void> _initializeService() async {
    await _studentService.initialize();
    await _feeService.initialize();
    _loadStudents();
  }

  void _onSearchChanged() {
    // Debounce search
    Future.delayed(const Duration(milliseconds: 300), () {
      if (searchController.text == _lastSearch) return;
      _lastSearch = searchController.text;
      _loadStudents();
    });
  }

  String _lastSearch = '';

  Future<void> _loadStudents() async {
    isLoading.value = true;
    try {
      print('Debug: Initializing student service...');
      await _studentService.initialize();
      print('Debug: Fetching students from database...');
      final result = await _studentService.getStudents();
      print('Debug: Fetched ${result.length} students');
      students.value = result;
      totalStudents.value = result.length;
      print(
        'Debug: Assigned students to RxList. Current length: ${students.length}',
      );
    } catch (e) {
      print('Error loading students: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String _filterToClass(StudentFilter filter) {
    switch (filter) {
      case StudentFilter.class9:
        return 'Class 9';
      case StudentFilter.class10:
        return 'Class 10';
      case StudentFilter.class11:
        return 'Class 11';
      case StudentFilter.class12:
        return 'Class 12';
      default:
        return '';
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void setFilter(StudentFilter filter) {
    activeFilter.value = filter;
    currentPage.value = 1;
  }

  void setRowsPerPage(int rows) {
    rowsPerPage.value = rows;
    currentPage.value = 1;
  }

  void _adjustCurrentPage() {
    final maxPage = (filteredTotal / rowsPerPage.value).ceil();
    if (currentPage.value > maxPage && maxPage > 0) {
      currentPage.value = maxPage;
    }
  }

  Future<void> addStudent(StudentModel student) async {
    try {
      final id = await _studentService.insertStudent(student);

      // Insert admission fee
      final admissionFee = FeeModel(
        studentId: id,
        feeType: 'Admission',
        amount: student.admissionFees,
        status: 'pending',
        // feeMonth: null for admission
      );
      await _feeService.insertFee(admissionFee);

      // Insert monthly fees for current and next 12 months
      final now = DateTime.now();
      for (int i = 0; i < 12; i++) {
        final feeDate = DateTime(now.year, now.month + i, 1);
        final feeMonth = _getMonthYear(feeDate);
        final monthlyFee = FeeModel(
          studentId: id,
          feeType: 'Monthly',
          amount: student.monthlyFees,
          status: 'pending',
          feeMonth: feeMonth,
        );
        await _feeService.insertFee(monthlyFee);
      }

      final newStudent = StudentModel(
        id: id,
        classId: student.classId,
        name: student.name,
        roll: student.roll,
        grNo: student.grNo,
        studentClass: student.studentClass,
        section: student.section,
        fatherName: student.fatherName,
        caste: student.caste,
        placeOfBirth: student.placeOfBirth,
        dateOfBirthFigures: student.dateOfBirthFigures,
        dateOfBirthWords: student.dateOfBirthWords,
        gender: student.gender,
        religion: student.religion,
        fatherContact: student.fatherContact,
        motherContact: student.motherContact,
        address: student.address,
        admissionFees: student.admissionFees,
        monthlyFees: student.monthlyFees,
        accountNumber: student.accountNumber,
        contact: student.contact,
        status: student.status,
        admissionDate: student.admissionDate,
      );
      students.add(newStudent);
      totalStudents.value++;
      print(
        'Debug: Student added to reactive list. New count: ${students.length}',
      );

      // Refresh fees lists to show newly created fees
      final feesController = Get.find<FeesController>();
      await feesController.refreshFees();
      print('Debug: Fees lists refreshed after student admission');
    } catch (e) {
      print('Error adding student: $e');
      rethrow;
    }
  }

  String _getMonthYear(DateTime date) {
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
    return '${monthNames[date.month - 1]} ${date.year}';
  }

  Future<void> updateStudent(StudentModel student) async {
    try {
      await _studentService.updateStudent(student);
      final index = students.indexWhere((s) => s.id == student.id);
      if (index != -1) {
        students[index] = student;
      }
    } catch (e) {
      print('Error updating student: $e');
      rethrow;
    }
  }

  Future<void> deleteStudent(int id) async {
    try {
      await _studentService.deleteStudent(id);
      students.removeWhere((s) => s.id == id);
      totalStudents.value--;
      _adjustCurrentPage();
      print(
        'Debug: Student deleted from reactive list. New count: ${students.length}',
      );
    } catch (e) {
      print('Error deleting student: $e');
      rethrow;
    }
  }

  void setPage(int page) => currentPage.value = page;

  void nextPage() {
    if (currentPage.value < _maxPage) {
      currentPage.value++;
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
    }
  }

  Future<StudentModel?> getStudentById(int id) async {
    try {
      return await _studentService.getStudentById(id);
    } catch (e) {
      print('Error getting student by id: $e');
      return null;
    }
  }

  Future<void> refreshStudents() async {
    await _loadStudents();
  }

  int get _maxPage => (totalStudents.value / rowsPerPage.value).ceil();
  bool get canGoNext => currentPage.value < _maxPage;
  bool get canGoPrevious => currentPage.value > 1;
}
