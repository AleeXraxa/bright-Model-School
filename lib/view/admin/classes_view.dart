import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controller/classes_controller.dart';
import '../widgets/search_bar.dart';
import '../widgets/classes_table.dart';
import 'add_class_form.dart';

class ClassesView extends StatefulWidget {
  const ClassesView({super.key});

  @override
  State<ClassesView> createState() => _ClassesViewState();
}

class _ClassesViewState extends State<ClassesView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.02),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showAddClassDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const AddClassForm(classToEdit: null),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ClassesController c = Get.put(ClassesController());
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DesktopSearchBar(
                      controller: c.searchController,
                      hint: 'Search classes...',
                      onSubmit: () {},
                    ),
                  ),
                  SizedBox(width: 16.w),
                  _AddClassButton(
                    onPressed: () => _showAddClassDialog(context),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Expanded(child: ClassesTable()),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() {
                    final start =
                        (c.currentPage.value - 1) * c.rowsPerPage.value + 1;
                    final end = start + c.classes.length - 1;
                    return Text(
                      'Showing $start-$end of ${c.totalClasses.value} classes',
                    );
                  }),
                  Row(
                    children: [
                      DropdownButton<int>(
                        value: c.rowsPerPage.value,
                        items: const [
                          DropdownMenuItem(value: 10, child: Text('10')),
                          DropdownMenuItem(value: 25, child: Text('25')),
                          DropdownMenuItem(value: 50, child: Text('50')),
                        ],
                        onChanged: (v) => c.setRowsPerPage(v ?? 10),
                      ),
                      SizedBox(width: 8.w),
                      Obx(
                        () => TextButton(
                          onPressed: c.canGoPrevious ? c.previousPage : null,
                          child: const Text('Prev'),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Obx(() => Text('${c.currentPage.value}')),
                      SizedBox(width: 6.w),
                      Obx(
                        () => TextButton(
                          onPressed: c.canGoNext ? c.nextPage : null,
                          child: const Text('Next'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddClassButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _AddClassButton({required this.onPressed});

  @override
  State<_AddClassButton> createState() => _AddClassButtonState();
}

class _AddClassButtonState extends State<_AddClassButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: _isHovered
            ? (Matrix4.identity()..translate(0.0, -2.0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primaryContainer,
            ],
          ),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 12.r,
                    offset: Offset(0, 6.h),
                  ),
                ]
              : [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    blurRadius: 8.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: widget.onPressed,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: theme.colorScheme.onPrimary,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Add New Class',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
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
}
