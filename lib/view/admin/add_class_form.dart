import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controller/classes_controller.dart';
import '../../model/class_model.dart';
import '../../utils/custom_dialog.dart';

class AddClassForm extends StatefulWidget {
  final ClassModel? classToEdit;
  const AddClassForm({super.key, this.classToEdit});

  @override
  State<AddClassForm> createState() => _AddClassFormState();
}

class _AddClassFormState extends State<AddClassForm>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  final TextEditingController classNameController = TextEditingController();
  final TextEditingController sectionController = TextEditingController();

  final RxString classNameError = ''.obs;
  final RxString sectionError = ''.obs;

  @override
  void initState() {
    super.initState();
    if (widget.classToEdit != null) {
      classNameController.text = widget.classToEdit!.className;
      sectionController.text = widget.classToEdit!.section;
    }
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    classNameController.dispose();
    sectionController.dispose();
    super.dispose();
  }

  void _validateAndSave() async {
    classNameError.value = '';
    sectionError.value = '';

    final className = classNameController.text.trim();
    final section = sectionController.text.trim();

    bool isValid = true;

    if (className.isEmpty) {
      classNameError.value = 'Class name is required';
      isValid = false;
    }

    if (section.isEmpty) {
      sectionError.value = 'Section is required';
      isValid = false;
    }

    if (!isValid) return;

    try {
      final controller = Get.find<ClassesController>();
      if (widget.classToEdit != null) {
        final updatedClass = ClassModel(
          id: widget.classToEdit!.id,
          className: className,
          section: section,
        );
        await controller.updateClass(updatedClass);
        Get.back();
        Get.dialog(
          SuccessDialog(
            message: 'Class updated successfully',
            onClose: () => Get.back(),
          ),
        );
      } else {
        await controller.addClass(className, section);
        Get.back();
        Get.dialog(
          SuccessDialog(
            message: 'Class added successfully',
            onClose: () => Get.back(),
          ),
        );
      }
    } catch (e) {
      Get.dialog(ErrorDialog(message: e.toString(), onClose: () => Get.back()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 500.w,
            constraints: BoxConstraints(maxHeight: 0.6.sh),
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
                        Icons.add_circle,
                        color: theme.colorScheme.primary,
                        size: 32.sp,
                      ),
                      SizedBox(width: 16.w),
                      Text(
                        widget.classToEdit != null
                            ? 'Edit Class'
                            : 'Add New Class',
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
                          title: 'Class Details',
                          icon: Icons.class_,
                          delay: 0,
                          children: [
                            Obx(
                              () => _buildAnimatedTextField(
                                controller: classNameController,
                                label: 'Class Name',
                                icon: Icons.school,
                                errorText: classNameError.value.isNotEmpty
                                    ? classNameError.value
                                    : null,
                                delay: 100,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Obx(
                              () => _buildAnimatedTextField(
                                controller: sectionController,
                                label: 'Section',
                                icon: Icons.group,
                                errorText: sectionError.value.isNotEmpty
                                    ? sectionError.value
                                    : null,
                                delay: 200,
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
                        delay: 300,
                      ),
                      SizedBox(width: 16.w),
                      _buildAnimatedButton(
                        label: widget.classToEdit != null
                            ? 'Update Class'
                            : 'Add Class',
                        onPressed: _validateAndSave,
                        delay: 400,
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
