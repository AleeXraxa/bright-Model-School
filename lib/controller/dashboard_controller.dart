import 'package:get/get.dart';
import '../service/student_service.dart';
import '../service/class_service.dart';
import 'students_controller.dart';
import 'classes_controller.dart';

class DashboardController extends GetxController {
  final StudentService _studentService = StudentService();
  final ClassService _classService = ClassService();

  final RxInt totalStudents = 0.obs;
  final RxInt totalClasses = 0.obs;
  final RxInt admissionThisMonth = 0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    // Setup reactive listeners after a short delay to ensure other controllers are initialized
    Future.delayed(const Duration(milliseconds: 100), _setupReactiveListeners);
  }

  Future<void> _initializeServices() async {
    await _studentService.initialize();
    await _classService.initialize();
    await _loadDashboardData();
  }

  void _setupReactiveListeners() {
    print('Debug: Setting up reactive listeners in DashboardController');
    // Listen to students changes - use a more robust approach
    ever(studentsController.students, (_) {
      print('Debug: Students list changed, updating dashboard counts');
      _updateTotalStudents();
      _updateAdmissionThisMonth();
    });

    // Listen to classes changes
    ever(classesController.classes, (_) {
      print('Debug: Classes list changed, updating classes count');
      _updateTotalClasses();
    });
  }

  StudentsController get studentsController {
    if (!Get.isRegistered<StudentsController>()) {
      Get.put(StudentsController());
    }
    return Get.find<StudentsController>();
  }

  ClassesController get classesController {
    if (!Get.isRegistered<ClassesController>()) {
      Get.put(ClassesController());
    }
    return Get.find<ClassesController>();
  }

  Future<void> _loadDashboardData() async {
    isLoading.value = true;
    try {
      await _updateTotalStudents();
      await _updateTotalClasses();
      await _updateAdmissionThisMonth();
    } catch (e) {
      print('Error loading dashboard data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _updateTotalStudents() async {
    try {
      final students = await _studentService.getStudents();
      totalStudents.value = students.length;
      print('Debug: Total students updated to: ${totalStudents.value}');
    } catch (e) {
      print('Error updating total students: $e');
    }
  }

  Future<void> _updateTotalClasses() async {
    try {
      final classes = await _classService.getClasses();
      totalClasses.value = classes.length;
    } catch (e) {
      print('Error updating total classes: $e');
    }
  }

  Future<void> _updateAdmissionThisMonth() async {
    try {
      final students = await _studentService.getStudents();
      final currentMonth = DateTime.now().month;
      final currentYear = DateTime.now().year;

      admissionThisMonth.value = students.where((student) {
        if (student.admissionDate.isEmpty) return false;
        try {
          // Parse DD/MM/YYYY format more robustly
          final parts = student.admissionDate.split('/');
          if (parts.length != 3) return false;

          final day = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final year = int.tryParse(parts[2]);

          if (day == null || month == null || year == null) return false;
          if (month < 1 || month > 12 || day < 1 || day > 31) return false;

          return month == currentMonth && year == currentYear;
        } catch (e) {
          print('Error parsing admission date "${student.admissionDate}": $e');
          return false;
        }
      }).length;

      print(
        'Debug: Admission this month count updated to: ${admissionThisMonth.value}',
      );
    } catch (e) {
      print('Error updating admission this month: $e');
    }
  }

  Future<void> refreshDashboard() async {
    await _loadDashboardData();
  }
}
