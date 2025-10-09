import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controller/new_admission_controller.dart';
import '../../model/student_model.dart';
import '../../model/class_model.dart';

class NewAdmissionForm extends StatefulWidget {
  final StudentModel? studentToEdit;

  const NewAdmissionForm({super.key, this.studentToEdit});

  @override
  State<NewAdmissionForm> createState() => _NewAdmissionFormState();
}

class _NewAdmissionFormState extends State<NewAdmissionForm>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();

    // Reset form fields every time the form is opened
    final controller = Get.put(NewAdmissionController());
    controller.editingStudent.value = widget.studentToEdit;
    controller.resetForm();
    if (controller.editingStudent.value != null) {
      preFillForm(controller.editingStudent.value!);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void preFillForm(StudentModel student) {
    final controller = Get.find<NewAdmissionController>();
    controller.rollNumberController.text = student.roll;
    controller.grNumberController.text = student.grNo;
    controller.studentNameController.text = student.name;
    controller.fatherNameController.text = student.fatherName;
    controller.casteController.text = student.caste;
    controller.placeOfBirthController.text = student.placeOfBirth;
    controller.dateOfBirthController.text = student.dateOfBirthFigures;
    controller.dateOfBirthWordsController.text = student.dateOfBirthWords;
    controller.selectedGender.value = student.gender;
    controller.selectedReligion.value = student.religion;
    controller.fatherContactController.text = student.fatherContact;
    controller.motherContactController.text = student.motherContact;
    controller.addressController.text = student.address;
    controller.admissionFeesController.text = student.admissionFees;
    controller.monthlyFeesController.text = student.monthlyFees;
    controller.accountNumberController.text = student.accountNumber;
    // For class - try to find by classId first, then fallback to name/section
    ClassModel? classModel;
    if (student.classId != null) {
      classModel = controller.classes.firstWhereOrNull(
        (c) => c.id == student.classId,
      );
    }
    if (classModel == null) {
      classModel = controller.classes.firstWhereOrNull(
        (c) =>
            c.className == student.studentClass && c.section == student.section,
      );
    }
    if (classModel != null) {
      controller.selectedClassModel.value = classModel;
    }
    controller.selectedSection.value = student.section;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final NewAdmissionController controller =
        Get.find<NewAdmissionController>();
    print(
      'Debug: Building NewAdmissionForm. Classes length: ${controller.classes.length}',
    );

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 900.w,
            constraints: BoxConstraints(maxHeight: 0.9.sh),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.95),
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 30.r,
                  offset: Offset(0, 15.h),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.15),
                        theme.colorScheme.primary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.r),
                      topRight: Radius.circular(24.r),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_add,
                        color: theme.colorScheme.primary,
                        size: 32.sp,
                      ),
                      SizedBox(width: 16.w),
                      Text(
                        widget.studentToEdit != null
                            ? 'Edit Student Details'
                            : 'New Student Admission',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Form Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(32.w),
                    child: Column(
                      children: [
                        _buildSection(
                          title: 'Basic Information',
                          icon: Icons.info,
                          delay: 0,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildAnimatedTextField(
                                    controller: controller.rollNumberController,
                                    label: 'Roll No',
                                    icon: Icons.numbers,
                                    enabled: false,
                                    delay: 100,
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Obx(
                                    () => _buildAnimatedTextField(
                                      controller: controller.grNumberController,
                                      label: 'GR No',
                                      icon: Icons.tag,
                                      errorText:
                                          controller.grNoError.value.isNotEmpty
                                          ? controller.grNoError.value
                                          : null,
                                      delay: 200,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            Row(
                              children: [
                                Expanded(
                                  child: Obx(
                                    () => _buildAnimatedTextField(
                                      controller:
                                          controller.studentNameController,
                                      label: 'Name of Student',
                                      icon: Icons.person,
                                      errorText:
                                          controller
                                              .studentNameError
                                              .value
                                              .isNotEmpty
                                          ? controller.studentNameError.value
                                          : null,
                                      delay: 300,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Obx(
                                    () => _buildAnimatedTextField(
                                      controller:
                                          controller.fatherNameController,
                                      label: 'Name of Father',
                                      icon: Icons.family_restroom,
                                      errorText:
                                          controller
                                              .fatherNameError
                                              .value
                                              .isNotEmpty
                                          ? controller.fatherNameError.value
                                          : null,
                                      delay: 400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 32.h),
                        _buildSection(
                          title: 'Birth Details',
                          icon: Icons.cake,
                          delay: 500,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Obx(
                                    () => _buildAnimatedTextField(
                                      controller: controller.casteController,
                                      label: 'Caste',
                                      icon: Icons.group,
                                      errorText:
                                          controller.casteError.value.isNotEmpty
                                          ? controller.casteError.value
                                          : null,
                                      delay: 600,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Obx(
                                    () => _buildAnimatedTextField(
                                      controller:
                                          controller.placeOfBirthController,
                                      label: 'Place of Birth',
                                      icon: Icons.location_on,
                                      errorText:
                                          controller
                                              .placeOfBirthError
                                              .value
                                              .isNotEmpty
                                          ? controller.placeOfBirthError.value
                                          : null,
                                      delay: 700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            Row(
                              children: [
                                Expanded(
                                  child: Obx(
                                    () => _buildAnimatedDateField(
                                      controller:
                                          controller.dateOfBirthController,
                                      label: 'Date of Birth (in figures)',
                                      icon: Icons.calendar_today,
                                      errorText:
                                          controller
                                              .dateOfBirthError
                                              .value
                                              .isNotEmpty
                                          ? controller.dateOfBirthError.value
                                          : null,
                                      onDateSelected: (date) {
                                        controller.updateDOBWords(date);
                                      },
                                      delay: 800,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: _buildAnimatedTextField(
                                    controller:
                                        controller.dateOfBirthWordsController,
                                    label: 'Date of Birth (in words)',
                                    icon: Icons.text_fields,
                                    enabled: false,
                                    delay: 900,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 32.h),
                        _buildSection(
                          title: 'Personal Details',
                          icon: Icons.person_outline,
                          delay: 1000,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Obx(
                                    () => _buildAnimatedDropdown(
                                      label: 'Gender',
                                      icon: Icons.wc,
                                      items: const ['Male', 'Female', 'Other'],
                                      value:
                                          controller
                                              .selectedGender
                                              .value
                                              .isEmpty
                                          ? null
                                          : controller.selectedGender.value,
                                      onChanged: (value) {
                                        if (value != null) {
                                          controller.selectedGender.value =
                                              value;
                                        }
                                      },
                                      errorText:
                                          controller
                                              .genderError
                                              .value
                                              .isNotEmpty
                                          ? controller.genderError.value
                                          : null,
                                      delay: 1100,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Obx(
                                    () => _buildAnimatedDropdown(
                                      label: 'Religion',
                                      icon: Icons.account_balance,
                                      items: controller.religions,
                                      value:
                                          controller
                                              .selectedReligion
                                              .value
                                              .isEmpty
                                          ? null
                                          : controller.selectedReligion.value,
                                      onChanged: (value) {
                                        if (value != null) {
                                          controller.selectedReligion.value =
                                              value;
                                        }
                                      },
                                      errorText:
                                          controller
                                              .religionError
                                              .value
                                              .isNotEmpty
                                          ? controller.religionError.value
                                          : null,
                                      delay: 1200,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            Row(
                              children: [
                                Expanded(
                                  child: Obx(
                                    () => _buildAnimatedTextField(
                                      controller:
                                          controller.fatherContactController,
                                      label: 'Father\'s Contact',
                                      icon: Icons.phone,
                                      keyboardType: TextInputType.phone,
                                      errorText:
                                          controller
                                              .fatherContactError
                                              .value
                                              .isNotEmpty
                                          ? controller.fatherContactError.value
                                          : null,
                                      delay: 1300,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Obx(
                                    () => _buildAnimatedTextField(
                                      controller:
                                          controller.motherContactController,
                                      label: 'Mother\'s Contact',
                                      icon: Icons.phone_android,
                                      keyboardType: TextInputType.phone,
                                      errorText:
                                          controller
                                              .motherContactError
                                              .value
                                              .isNotEmpty
                                          ? controller.motherContactError.value
                                          : null,
                                      delay: 1400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            Obx(
                              () => _buildAnimatedTextField(
                                controller: controller.addressController,
                                label: 'Address',
                                icon: Icons.home,
                                maxLines: 3,
                                errorText:
                                    controller.addressError.value.isNotEmpty
                                    ? controller.addressError.value
                                    : null,
                                delay: 1500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 32.h),
                        _buildSection(
                          title: 'Class Assignment',
                          icon: Icons.school,
                          delay: 1600,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Obx(() {
                                    if (controller.isLoadingClasses.value) {
                                      return TweenAnimationBuilder<double>(
                                        tween: Tween(begin: 0.0, end: 1.0),
                                        duration: const Duration(
                                          milliseconds: 600 + 1700,
                                        ),
                                        curve: Curves.easeOut,
                                        builder: (context, value, child) {
                                          final clampedValue = value.clamp(
                                            0.0,
                                            1.0,
                                          );
                                          return Transform.translate(
                                            offset: Offset(
                                              0,
                                              20 * (1 - clampedValue),
                                            ),
                                            child: Opacity(
                                              opacity: clampedValue,
                                              child: TextField(
                                                enabled: false,
                                                decoration: InputDecoration(
                                                  labelText: 'Class',
                                                  hintText:
                                                      'Loading classes...',
                                                  prefixIcon: Icon(
                                                    Icons.class_,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12.r,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }
                                    return _buildAnimatedDropdown(
                                      label: 'Class',
                                      icon: Icons.class_,
                                      items: controller.classes.isNotEmpty
                                          ? controller.classes
                                                .map((c) => c.className)
                                                .toSet()
                                                .toList()
                                          : ['No classes added yet'],
                                      value:
                                          controller
                                              .selectedClassModel
                                              .value
                                              ?.className ??
                                          (controller.classes.isNotEmpty
                                              ? controller
                                                    .classes
                                                    .first
                                                    .className
                                              : null),
                                      onChanged: (value) {
                                        if (value != null &&
                                            value != 'No classes added yet') {
                                          final selectedClass = controller
                                              .classes
                                              .firstWhere(
                                                (c) => c.className == value,
                                              );
                                          controller.selectedClassModel.value =
                                              selectedClass;
                                        }
                                      },
                                      errorText:
                                          controller.classError.value.isNotEmpty
                                          ? controller.classError.value
                                          : null,
                                      delay: 1700,
                                    );
                                  }),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Obx(
                                    () => _buildAnimatedDropdown(
                                      label: 'Section',
                                      icon: Icons.group,
                                      items:
                                          controller.sectionsForSelectedClass,
                                      value:
                                          controller
                                              .selectedSection
                                              .value
                                              .isEmpty
                                          ? null
                                          : (controller.sectionsForSelectedClass
                                                    .contains(
                                                      controller
                                                          .selectedSection
                                                          .value,
                                                    )
                                                ? controller
                                                      .selectedSection
                                                      .value
                                                : (controller
                                                          .sectionsForSelectedClass
                                                          .isNotEmpty
                                                      ? controller
                                                            .sectionsForSelectedClass
                                                            .first
                                                      : null)),
                                      onChanged: (value) {
                                        if (value != null) {
                                          controller.selectedSection.value =
                                              value;
                                        }
                                      },
                                      delay: 1800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 32.h),
                        _buildSection(
                          title: 'Fees & Amount',
                          icon: Icons.attach_money,
                          delay: 1900,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Obx(
                                    () => _buildAnimatedTextField(
                                      controller:
                                          controller.admissionFeesController,
                                      label: 'Admission Fees',
                                      icon: Icons.money,
                                      keyboardType: TextInputType.number,
                                      errorText:
                                          controller
                                              .admissionFeesError
                                              .value
                                              .isNotEmpty
                                          ? controller.admissionFeesError.value
                                          : null,
                                      delay: 2000,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Obx(
                                    () => _buildAnimatedTextField(
                                      controller:
                                          controller.monthlyFeesController,
                                      label: 'Monthly Fees',
                                      icon: Icons.calendar_view_month,
                                      keyboardType: TextInputType.number,
                                      errorText:
                                          controller
                                              .monthlyFeesError
                                              .value
                                              .isNotEmpty
                                          ? controller.monthlyFeesError.value
                                          : null,
                                      delay: 2100,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            Obx(
                              () => _buildAnimatedTextField(
                                controller: controller.accountNumberController,
                                label: 'Account No',
                                icon: Icons.account_balance,
                                keyboardType: TextInputType.number,
                                errorText:
                                    controller
                                        .accountNumberError
                                        .value
                                        .isNotEmpty
                                    ? controller.accountNumberError.value
                                    : null,
                                delay: 2200,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Footer Buttons
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.9),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24.r),
                      bottomRight: Radius.circular(24.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildAnimatedButton(
                        label: 'Cancel',
                        onPressed: () => Navigator.of(context).pop(),
                        isOutlined: true,
                        delay: 2300,
                      ),
                      SizedBox(width: 16.w),
                      _buildAnimatedButton(
                        label: 'Save',
                        onPressed: controller.saveAdmission,
                        delay: 2400,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    int? maxLines,
    bool enabled = true,
    String? errorText,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        final clampedValue = value.clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(0, 20 * (1 - clampedValue)),
          child: Opacity(opacity: clampedValue, child: child),
        );
      },
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines ?? 1,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          errorText: errorText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required int delay,
    required List<Widget> children,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        final clampedValue = value.clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(0, 30 * (1 - clampedValue)),
          child: Opacity(
            opacity: clampedValue,
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        icon,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  ...children,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedDropdown({
    required String label,
    required IconData icon,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
    required int delay,
    String? errorText,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        final clampedValue = value.clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(0, 20 * (1 - clampedValue)),
          child: Opacity(opacity: clampedValue, child: child),
        );
      },
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          errorText: errorText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem(value: item, child: Text(item));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildAnimatedDateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required int delay,
    Function(DateTime)? onDateSelected,
    String? errorText,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        final clampedValue = value.clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(0, 20 * (1 - clampedValue)),
          child: Opacity(opacity: clampedValue, child: child),
        );
      },
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          errorText: errorText,
          suffixIcon: IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2030),
              );
              if (date != null) {
                controller.text = '${date.day}/${date.month}/${date.year}';
                onDateSelected?.call(date);
              }
            },
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedButton({
    required String label,
    required VoidCallback onPressed,
    bool isOutlined = false,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        final clampedValue = value.clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(0, 20 * (1 - clampedValue)),
          child: Opacity(opacity: clampedValue, child: child),
        );
      },
      child: isOutlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                side: BorderSide(color: Theme.of(context).colorScheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ),
    );
  }
}
