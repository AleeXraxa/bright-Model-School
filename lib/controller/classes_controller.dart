import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../model/class_model.dart';
import '../model/student_model.dart';
import '../service/class_service.dart';
import 'students_controller.dart';

class ClassesController extends GetxController {
  final ClassService _classService = ClassService();
  final RxInt rowsPerPage = 10.obs;
  final RxInt currentPage = 1.obs;
  final TextEditingController searchController = TextEditingController();

  final RxList<ClassModel> classes = <ClassModel>[].obs;
  final RxInt totalClasses = 0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeService();
    searchController.addListener(_onSearchChanged);
    // Listen to students changes and update counts (only if StudentsController exists)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<StudentsController>()) {
        ever(
          Get.find<StudentsController>().students,
          (_) => _recalculateStudentCounts(),
        );
      }
    });
  }

  Future<void> _initializeService() async {
    await _classService.initialize();
    _loadClasses();
  }

  void _onSearchChanged() {
    // Debounce search
    Future.delayed(const Duration(milliseconds: 300), () {
      if (searchController.text == _lastSearch) return;
      _lastSearch = searchController.text;
      _loadClasses();
    });
  }

  String _lastSearch = '';

  Future<void> _loadClasses() async {
    isLoading.value = true;
    try {
      final search = searchController.text.trim();

      final result = await _classService.getClasses(
        search: search.isEmpty ? null : search,
      );

      classes.assignAll(result);
      totalClasses.value = result.length;
      _recalculateStudentCounts();
    } catch (e) {
      print('Error loading classes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void setRowsPerPage(int rows) {
    rowsPerPage.value = rows;
    _adjustCurrentPage();
  }

  void _adjustCurrentPage() {
    final maxPage = (totalClasses.value / rowsPerPage.value).ceil();
    if (currentPage.value > maxPage && maxPage > 0) {
      currentPage.value = maxPage;
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

  int get _maxPage => (totalClasses.value / rowsPerPage.value).ceil();
  bool get canGoNext => currentPage.value < _maxPage;
  bool get canGoPrevious => currentPage.value > 1;

  // Reactive count recalculation for all classes
  void _recalculateStudentCounts() {
    if (!Get.isRegistered<StudentsController>()) return;

    try {
      final studentsController = Get.find<StudentsController>();
      final students = studentsController.students;

      // Update studentCount.value for each class reactively
      for (final classModel in classes) {
        final count = students
            .where(
              (student) =>
                  student.studentClass.trim() == classModel.className.trim() &&
                  student.section.trim() == classModel.section.trim(),
            )
            .length;
        classModel.studentCount.value = count;
      }
    } catch (e) {
      print('Error recalculating student counts: $e');
    }
  }

  Future<void> addClass(String className, String section) async {
    try {
      final isUnique = await _classService.isClassUnique(className, section);
      if (!isUnique) {
        throw Exception('Class and section combination already exists');
      }

      final newClass = ClassModel(className: className, section: section);

      final id = await _classService.insertClass(newClass);

      final insertedClass = ClassModel(
        id: id,
        className: className,
        section: section,
      );

      // Calculate initial student count for the new class
      if (Get.isRegistered<StudentsController>()) {
        final studentsController = Get.find<StudentsController>();
        final initialCount = studentsController.students
            .where(
              (student) =>
                  student.studentClass.trim() == className.trim() &&
                  student.section.trim() == section.trim(),
            )
            .length;
        insertedClass.studentCount.value = initialCount;
      }

      classes.add(insertedClass);
      totalClasses.value++;
      // Set to the page where the new class is
      final page = ((totalClasses.value - 1) ~/ rowsPerPage.value) + 1;
      currentPage.value = page;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteClass(int id) async {
    try {
      await _classService.deleteClass(id);
      classes.removeWhere((c) => c.id == id);
      totalClasses.value--;
      _adjustCurrentPage();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateClass(ClassModel updatedClass) async {
    try {
      final isUnique = await _classService.isClassUnique(
        updatedClass.className,
        updatedClass.section,
        excludeId: updatedClass.id,
      );
      if (!isUnique) {
        throw Exception('Class and section combination already exists');
      }

      await _classService.updateClass(updatedClass);
      final index = classes.indexWhere((c) => c.id == updatedClass.id);
      if (index != -1) {
        classes[index] = updatedClass;
      }
    } catch (e) {
      rethrow;
    }
  }

  RxList<StudentModel> getStudentsForClass(ClassModel classData) {
    if (!Get.isRegistered<StudentsController>()) return <StudentModel>[].obs;
    final studentsController = Get.find<StudentsController>();
    final filtered = studentsController.students
        .where(
          (s) =>
              s.studentClass.trim() == classData.className.trim() &&
              s.section.trim() == classData.section.trim(),
        )
        .toList();
    return filtered.obs;
  }
}
