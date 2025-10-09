import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../model/class_model.dart';
import '../../controller/classes_controller.dart';
import '../admin/add_class_form.dart';
import '../../utils/custom_dialog.dart';
import 'class_details_card.dart';

class ClassesTable extends GetView<ClassesController> {
  const ClassesTable({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: 1,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceVariant.withOpacity(0.3),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.08),
              blurRadius: 20.r,
              offset: Offset(0, 8.h),
            ),
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.04),
              blurRadius: 40.r,
              offset: Offset(0, 16.h),
            ),
          ],
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.05),
                    theme.colorScheme.primary.withOpacity(0.02),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
              ),
              child: Row(
                children: const [
                  _HeaderCell('Class', flex: 2),
                  _HeaderCell('Section'),
                  _HeaderCell('Student Count'),
                  _HeaderCell('Actions', alignRight: true),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
            // Rows
            Expanded(
              child: Obx(() {
                final start =
                    (controller.currentPage.value - 1) *
                    controller.rowsPerPage.value;
                final end = (start + controller.rowsPerPage.value).clamp(
                  0,
                  controller.classes.length,
                );
                final pageClasses = controller.classes.sublist(start, end);
                return ListView.builder(
                  itemCount: pageClasses.length,
                  itemBuilder: (context, i) {
                    final r = pageClasses[i];
                    return _ClassRow(index: start + i, row: r);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  final bool alignRight;
  const _HeaderCell(this.label, {this.flex = 1, this.alignRight = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _ClassRow extends StatefulWidget {
  final int index;
  final ClassModel row;
  const _ClassRow({required this.index, required this.row});

  @override
  State<_ClassRow> createState() => _ClassRowState();
}

class _ClassRowState extends State<_ClassRow>
    with SingleTickerProviderStateMixin {
  bool _hover = false;
  bool _selected = false;
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final row = widget.row;
    final isEvenRow = widget.index % 2 == 0;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => setState(() => _selected = !_selected),
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              color: _selected
                  ? theme.colorScheme.primary.withOpacity(0.08)
                  : (_hover
                        ? theme.colorScheme.primary.withOpacity(0.04)
                        : (isEvenRow
                              ? theme.colorScheme.surfaceVariant.withOpacity(
                                  0.2,
                                )
                              : Colors.transparent)),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  _cell(row.className, flex: 2),
                  _cell(row.section),
                  Obx(() => _cell(row.studentCount.value.toString())),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _iconButton(
                            Icons.visibility_outlined,
                            onTap: () {
                              final controller = Get.find<ClassesController>();
                              final studentsInClass = controller
                                  .getStudentsForClass(row);
                              showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (context) => ClassDetailsCard(
                                  classData: row,
                                  studentsInClass: studentsInClass,
                                ),
                              );
                            },
                          ),
                          SizedBox(width: 8.w),
                          _iconButton(
                            Icons.edit_outlined,
                            onTap: () => showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (context) =>
                                  AddClassForm(classToEdit: row),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          _iconButton(
                            Icons.delete_outlined,
                            color: const Color(0xFFEF5350),
                            onTap: () {
                              Get.dialog(
                                ConfirmationDialog(
                                  title: 'Delete Class',
                                  message:
                                      'Are you sure you want to delete ${row.className} - ${row.section}?',
                                  confirmText: 'Delete',
                                  onConfirm: () async {
                                    await Get.find<ClassesController>()
                                        .deleteClass(row.id!);
                                    Get.back(); // close confirmation
                                    Get.dialog(
                                      SuccessDialog(
                                        message: 'Class deleted successfully',
                                        onClose: () => Get.back(),
                                      ),
                                    );
                                  },
                                  onCancel: () => Get.back(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cell(String text, {int flex = 1}) => Expanded(
    flex: flex,
    child: Text(text, overflow: TextOverflow.ellipsis),
  );

  Widget _iconButton(IconData icon, {Color? color, VoidCallback? onTap}) {
    return _AnimatedIconButton(icon: icon, color: color, onTap: onTap);
  }

  Widget _AnimatedIconButton({
    required IconData icon,
    Color? color,
    VoidCallback? onTap,
  }) {
    return _AnimatedIconButtonWidget(icon: icon, color: color, onTap: onTap);
  }
}

class _AnimatedIconButtonWidget extends StatefulWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const _AnimatedIconButtonWidget({required this.icon, this.color, this.onTap});

  @override
  State<_AnimatedIconButtonWidget> createState() =>
      _AnimatedIconButtonWidgetState();
}

class _AnimatedIconButtonWidgetState extends State<_AnimatedIconButtonWidget> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: _hover
            ? (Matrix4.identity()..scale(1.15))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: _hover
              ? (widget.color ?? theme.colorScheme.primary).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: _hover
              ? [
                  BoxShadow(
                    color: (widget.color ?? theme.colorScheme.primary)
                        .withOpacity(0.2),
                    blurRadius: 8.r,
                    offset: Offset(0, 4.h),
                  ),
                ]
              : [],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10.r),
          onTap: widget.onTap,
          child: Padding(
            padding: EdgeInsets.all(8.w),
            child: Icon(
              widget.icon,
              size: 20.sp,
              color: _hover
                  ? (widget.color ?? theme.colorScheme.primary)
                  : (widget.color ?? theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ),
      ),
    );
  }
}
