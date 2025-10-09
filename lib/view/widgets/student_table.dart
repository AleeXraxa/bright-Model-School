import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../model/student_model.dart';
import '../../controller/students_controller.dart';
import '../../utils/custom_dialog.dart';
import '../admin/new_admission_form.dart';
import 'student_details_card.dart';

class StudentTable extends StatelessWidget {
  final List<StudentModel> rows;
  const StudentTable({super.key, required this.rows});

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
                  _HeaderCell('Name', flex: 2),
                  _HeaderCell('Roll No'),
                  _HeaderCell('Class & Section'),
                  _HeaderCell('Father\'s Name', flex: 2),
                  _HeaderCell('Contact'),
                  _HeaderCell('Status'),
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
              child: ListView.builder(
                itemCount: rows.length,
                itemBuilder: (context, i) {
                  final r = rows[i];
                  return _StudentRow(index: i, row: r);
                },
              ),
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

class _StudentRow extends StatefulWidget {
  final int index;
  final StudentModel row;
  const _StudentRow({required this.index, required this.row});

  @override
  State<_StudentRow> createState() => _StudentRowState();
}

class _StudentRowState extends State<_StudentRow>
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
                  _cell(row.name, flex: 2),
                  _cell(row.roll),
                  _cell('${row.studentClass} - ${row.section}', flex: 1),
                  _cell(row.fatherName, flex: 2),
                  _cell(row.contact),
                  _status(row.status, theme),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _iconButton(
                            Icons.visibility_outlined,
                            onTap: () {
                              Get.dialog(
                                StudentDetailsCard(student: row),
                                barrierDismissible: true,
                              );
                            },
                          ),
                          SizedBox(width: 8.w),
                          _iconButton(
                            Icons.edit_outlined,
                            onTap: () {
                              Get.dialog(
                                NewAdmissionForm(studentToEdit: row),
                                barrierDismissible: true,
                              );
                            },
                          ),
                          SizedBox(width: 8.w),
                          _iconButton(
                            Icons.delete_outlined,
                            color: const Color(0xFFEF5350),
                            onTap: () {
                              Get.dialog(
                                ConfirmationDialog(
                                  title: 'Delete Student',
                                  message:
                                      'Are you sure you want to delete ${row.name}?',
                                  confirmText: 'Delete',
                                  onConfirm: () async {
                                    await Get.find<StudentsController>()
                                        .deleteStudent(row.id!);
                                    Get.back(); // close confirmation
                                    Get.find<StudentsController>().students
                                        .removeWhere((s) => s.id == row.id);
                                    Get.dialog(
                                      SuccessDialog(
                                        message: 'Student deleted successfully',
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

  Widget _status(String status, ThemeData theme) {
    Color color;
    Color bgColor;
    switch (status) {
      case 'Active':
        color = const Color(0xFF059669);
        bgColor = const Color(0xFFD1FAE5);
        break;
      case 'Inactive':
        color = const Color(0xFF6B7280);
        bgColor = const Color(0xFFF3F4F6);
        break;
      default:
        color = const Color(0xFFD97706);
        bgColor = const Color(0xFFFEF3C7);
    }
    return Expanded(
      child: Container(
        alignment: Alignment.centerLeft,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: color.withOpacity(0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 4.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
            ),
          ),
        ),
      ),
    );
  }

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
