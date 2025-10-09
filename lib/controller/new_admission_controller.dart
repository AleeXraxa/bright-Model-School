import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/date_to_words.dart';
import '../utils/custom_dialog.dart';
import '../model/class_model.dart';
import '../model/student_model.dart';
import '../service/class_service.dart';
import '../service/student_service.dart';
import '../controller/students_controller.dart';

class NewAdmissionController extends GetxController {
  final ClassService _classService = ClassService();
  final StudentService _studentService = StudentService();

  // Editing mode
  final Rx<StudentModel?> editingStudent = Rx<StudentModel?>(null);

  // Reactive Variables
  final RxList<ClassModel> classes = <ClassModel>[].obs;
  final Rx<ClassModel?> selectedClassModel = Rx<ClassModel?>(null);
  final RxBool isLoadingClasses = false.obs;

  // Text Controllers
  final TextEditingController rollNumberController = TextEditingController();
  final TextEditingController grNumberController = TextEditingController();
  final TextEditingController studentNameController = TextEditingController();
  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController casteController = TextEditingController();
  final TextEditingController placeOfBirthController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController dateOfBirthWordsController =
      TextEditingController();
  final TextEditingController fatherContactController = TextEditingController();
  final TextEditingController motherContactController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController admissionFeesController = TextEditingController();
  final TextEditingController monthlyFeesController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();

  // Reactive Variables
  final RxString selectedGender = ''.obs;
  final RxString selectedReligion = 'Islam'.obs;
  final RxString selectedSection = 'A'.obs;

  // Validation Errors
  final RxString studentNameError = ''.obs;
  final RxString fatherNameError = ''.obs;
  final RxString fatherContactError = ''.obs;
  final RxString motherContactError = ''.obs;
  final RxString addressError = ''.obs;
  final RxString admissionFeesError = ''.obs;
  final RxString monthlyFeesError = ''.obs;
  final RxString accountNumberError = ''.obs;
  final RxString classError = ''.obs;
  final RxString genderError = ''.obs;
  final RxString grNoError = ''.obs;
  final RxString casteError = ''.obs;
  final RxString placeOfBirthError = ''.obs;
  final RxString dateOfBirthError = ''.obs;
  final RxString religionError = ''.obs;

  // Computed sections based on selected class
  List<String> get sectionsForSelectedClass {
    if (selectedClassModel.value == null) {
      return ['A'];
    }
    // Group classes by className and collect unique sections
    final className = selectedClassModel.value!.className;
    final sections = classes
        .where((c) => c.className == className)
        .map((c) => c.section)
        .toSet()
        .toList();
    return sections.isNotEmpty ? sections : ['A'];
  }

  final List<String> religions = [
    'Islam',
    'Hinduism',
    'Christianity',
    'Sikhism',
    'Buddhism',
    'Other',
  ];

  @override
  void onInit() {
    super.onInit();
    _loadClasses();
    // Generate roll number (auto-generated)
    rollNumberController.text =
        'AUTO-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    // Listen to class changes to update sections
    ever(selectedClassModel, (_) => updateSections());
  }

  Future<void> _loadClasses() async {
    isLoadingClasses.value = true;
    try {
      print('Debug: Initializing class service...');
      await _classService.initialize();
      print('Debug: Fetching classes from database...');
      final fetchedClasses = await _classService.getClasses();
      print('Debug: Fetched ${fetchedClasses.length} classes');
      classes.assignAll(fetchedClasses);
      print(
        'Debug: Assigned classes to RxList. Current length: ${classes.length}',
      );
      // Set default selected class if available
      if (classes.isNotEmpty && selectedClassModel.value == null) {
        selectedClassModel.value = classes.first;
        print(
          'Debug: Set default selected class: ${selectedClassModel.value?.className}',
        );
      } else {
        print('Debug: No classes to set as default or already selected');
      }
    } catch (e) {
      print('Error loading classes: $e');
    } finally {
      isLoadingClasses.value = false;
    }
  }

  void updateSections() {
    final availableSections = sectionsForSelectedClass;
    if (!availableSections.contains(selectedSection.value)) {
      selectedSection.value = availableSections.first;
    }
  }

  void updateDOBWords(DateTime date) {
    dateOfBirthWordsController.text = convertDateToWords(date);
  }

  bool validateForm() {
    bool isValid = true;

    // Gender Selection
    if (selectedGender.value.isEmpty) {
      genderError.value = 'Gender is required';
      isValid = false;
    } else {
      genderError.value = '';
    }

    // GR No
    if (grNumberController.text.isEmpty) {
      grNoError.value = 'GR No is required';
      isValid = false;
    } else {
      grNoError.value = '';
    }

    // Caste
    if (casteController.text.isEmpty) {
      casteError.value = 'Caste is required';
      isValid = false;
    } else {
      casteError.value = '';
    }

    // Place of Birth
    if (placeOfBirthController.text.isEmpty) {
      placeOfBirthError.value = 'Place of Birth is required';
      isValid = false;
    } else {
      placeOfBirthError.value = '';
    }

    // Date of Birth
    if (dateOfBirthController.text.isEmpty) {
      dateOfBirthError.value = 'Date of Birth is required';
      isValid = false;
    } else {
      dateOfBirthError.value = '';
    }

    // Religion
    if (selectedReligion.value.isEmpty) {
      religionError.value = 'Religion is required';
      isValid = false;
    } else {
      religionError.value = '';
    }

    // Class Selection
    if (selectedClassModel.value == null) {
      classError.value = 'Class is required';
      isValid = false;
    } else {
      classError.value = '';
    }

    // Student Name
    if (studentNameController.text.isEmpty) {
      studentNameError.value = 'Student name is required';
      isValid = false;
    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(studentNameController.text)) {
      studentNameError.value = 'Only alphabets allowed';
      isValid = false;
    } else {
      studentNameError.value = '';
    }

    // Father Name
    if (fatherNameController.text.isEmpty) {
      fatherNameError.value = 'Father name is required';
      isValid = false;
    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(fatherNameController.text)) {
      fatherNameError.value = 'Only alphabets allowed';
      isValid = false;
    } else {
      fatherNameError.value = '';
    }

    // Father Contact
    if (fatherContactController.text.isEmpty) {
      fatherContactError.value = 'Father contact is required';
      isValid = false;
    } else if (!RegExp(r'^\d{11}$').hasMatch(fatherContactController.text)) {
      fatherContactError.value = 'Must be exactly 11 digits';
      isValid = false;
    } else {
      fatherContactError.value = '';
    }

    // Mother Contact (optional)
    if (motherContactController.text.isNotEmpty &&
        !RegExp(r'^\d{11}$').hasMatch(motherContactController.text)) {
      motherContactError.value = 'Must be exactly 11 digits';
      isValid = false;
    } else {
      motherContactError.value = '';
    }

    // Address
    if (addressController.text.isEmpty) {
      addressError.value = 'Address is required';
      isValid = false;
    } else {
      addressError.value = '';
    }

    // Admission Fees
    if (admissionFeesController.text.isEmpty) {
      admissionFeesError.value = 'Admission fees is required';
      isValid = false;
    } else if (double.tryParse(admissionFeesController.text) == null) {
      admissionFeesError.value = 'Must be a valid number';
      isValid = false;
    } else {
      admissionFeesError.value = '';
    }

    // Monthly Fees
    if (monthlyFeesController.text.isEmpty) {
      monthlyFeesError.value = 'Monthly fees is required';
      isValid = false;
    } else if (double.tryParse(monthlyFeesController.text) == null) {
      monthlyFeesError.value = 'Must be a valid number';
      isValid = false;
    } else {
      monthlyFeesError.value = '';
    }

    // Account Number (optional)
    if (accountNumberController.text.isNotEmpty) {
      if (!RegExp(r'^\d{1,7}$').hasMatch(accountNumberController.text)) {
        accountNumberError.value = 'Must be 1-7 digits';
        isValid = false;
      } else {
        accountNumberError.value = '';
      }
    } else {
      accountNumberError.value = '';
    }

    return isValid;
  }

  Future<void> saveAdmission() async {
    if (validateForm()) {
      try {
        // Create student model with auto-generated admission date for new students
        final now = DateTime.now();
        final admissionDate =
            editingStudent.value?.admissionDate ??
            '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

        final student = StudentModel(
          id: editingStudent.value?.id,
          classId: selectedClassModel.value!.id,
          name: studentNameController.text.trim(),
          roll: rollNumberController.text.trim(),
          grNo: grNumberController.text.trim(),
          studentClass: selectedClassModel.value!.className,
          section: selectedSection.value,
          fatherName: fatherNameController.text.trim(),
          caste: casteController.text.trim(),
          placeOfBirth: placeOfBirthController.text.trim(),
          dateOfBirthFigures: dateOfBirthController.text.trim(),
          dateOfBirthWords: dateOfBirthWordsController.text.trim(),
          gender: selectedGender.value,
          religion: selectedReligion.value,
          fatherContact: fatherContactController.text.trim(),
          motherContact: motherContactController.text.trim(),
          address: addressController.text.trim(),
          admissionFees: admissionFeesController.text.trim(),
          monthlyFees: monthlyFeesController.text.trim(),
          accountNumber: accountNumberController.text.trim(),
          contact: fatherContactController.text.trim(),
          status: editingStudent.value?.status ?? 'Active',
          admissionDate: admissionDate,
        );

        // Add or update in students list in StudentsController (handles database insertion)
        final studentsController = Get.find<StudentsController>();
        if (editingStudent.value != null) {
          await studentsController.updateStudent(student);
        } else {
          await studentsController.addStudent(student);
        }

        // Show success message and close dialog
        Get.back();
        Get.dialog(
          SuccessDialog(
            message:
                'Student ${editingStudent.value != null ? 'updated' : 'admission saved'} successfully',
            onClose: () => Get.back(),
          ),
        );
      } catch (e) {
        Get.dialog(
          ErrorDialog(
            message:
                'Failed to ${editingStudent.value != null ? 'update' : 'save'} student: $e',
            onClose: () => Get.back(),
          ),
        );
      }
    } else {
      Get.dialog(
        ErrorDialog(
          message: 'Please fix the validation errors',
          onClose: () => Get.back(),
        ),
      );
    }
  }

  @override
  void onClose() {
    // Dispose controllers
    rollNumberController.dispose();
    grNumberController.dispose();
    studentNameController.dispose();
    fatherNameController.dispose();
    casteController.dispose();
    placeOfBirthController.dispose();
    dateOfBirthController.dispose();
    dateOfBirthWordsController.dispose();
    fatherContactController.dispose();
    motherContactController.dispose();
    addressController.dispose();
    admissionFeesController.dispose();
    monthlyFeesController.dispose();
    accountNumberController.dispose();
    super.onClose();
  }

  void resetForm() {
    rollNumberController.text =
        'AUTO-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    grNumberController.clear();
    studentNameController.clear();
    fatherNameController.clear();
    casteController.clear();
    placeOfBirthController.clear();
    dateOfBirthController.clear();
    dateOfBirthWordsController.clear();
    fatherContactController.clear();
    motherContactController.clear();
    addressController.clear();
    admissionFeesController.clear();
    monthlyFeesController.clear();
    accountNumberController.clear();

    selectedGender.value = '';
    selectedReligion.value = '';
    selectedClassModel.value = null;
    selectedSection.value = '';

    // Clear errors
    classError.value = '';
    genderError.value = '';
    studentNameError.value = '';
    fatherNameError.value = '';
    fatherContactError.value = '';
    motherContactError.value = '';
    addressError.value = '';
    admissionFeesError.value = '';
    monthlyFeesError.value = '';
    accountNumberError.value = '';
    grNoError.value = '';
    casteError.value = '';
    placeOfBirthError.value = '';
    dateOfBirthError.value = '';
    religionError.value = '';
  }
}
