import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controller/fees_controller.dart';
import '../widgets/full_fees_list_dialog.dart';
import '../widgets/pay_fee_dialog.dart';
import '../widgets/payment_history_dialog.dart';

class FeesView extends StatefulWidget {
  const FeesView({super.key});

  @override
  State<FeesView> createState() => _FeesViewState();
}

class _FeesViewState extends State<FeesView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  String activeSection = 'admission';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setActiveSection(String section) {
    setState(() {
      activeSection = section;
    });
  }

  @override
  Widget build(BuildContext context) {
    final FeesController controller = Get.find<FeesController>();
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      color: theme.colorScheme.primary,
                      size: 32.sp,
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fees Management',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Manage student fee payments and track outstanding balances',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),

                // Main Buttons
                Row(
                  children: [
                    _FeeTypeButton(
                      icon: '🎓',
                      title: 'Admission Fees',
                      isActive: activeSection == 'admission',
                      onTap: () => _setActiveSection('admission'),
                      theme: theme,
                    ),
                    SizedBox(width: 16.w),
                    _FeeTypeButton(
                      icon: '📅',
                      title: 'Monthly Fees',
                      isActive: activeSection == 'monthly',
                      onTap: () => _setActiveSection('monthly'),
                      theme: theme,
                    ),
                    SizedBox(width: 16.w),
                    _FeeTypeButton(
                      icon: '🧾',
                      title: 'Exam Fees',
                      isActive: activeSection == 'exam',
                      onTap: () => _setActiveSection('exam'),
                      theme: theme,
                    ),
                    SizedBox(width: 16.w),
                    _FeeTypeButton(
                      icon: '💰',
                      title: 'Misc Fees',
                      isActive: activeSection == 'misc',
                      onTap: () => _setActiveSection('misc'),
                      theme: theme,
                    ),
                  ],
                ),
                SizedBox(height: 32.h),

                // Content wrapped in Obx to observe data changes
                Obx(() {
                  if (controller.isLoading.value) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(48.w),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.1),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _buildActiveSection(controller, theme),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveSection(FeesController controller, ThemeData theme) {
    switch (activeSection) {
      case 'admission':
        return _FeeSubsection(
          key: const ValueKey('admission'),
          pendingFees: controller.admissionFees,
          paidFees: controller.paidAdmissionFees,
          feeType: 'admission',
          theme: theme,
        );
      case 'monthly':
        return _FeeSubsection(
          key: const ValueKey('monthly'),
          pendingFees: controller.monthlyFees,
          paidFees: controller.paidMonthlyFees,
          feeType: 'monthly',
          theme: theme,
        );
      case 'exam':
        return _FeeSubsection(
          key: const ValueKey('exam'),
          pendingFees: controller.examFees,
          paidFees: controller.paidExamFees,
          feeType: 'exam',
          theme: theme,
        );
      case 'misc':
        return _FeeSubsection(
          key: const ValueKey('misc'),
          pendingFees: controller.miscFees,
          paidFees: controller.paidMiscFees,
          feeType: 'misc',
          theme: theme,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _FeesSection extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<Map<String, dynamic>> fees;
  final List<Map<String, dynamic>> fullFees;
  final ThemeData theme;
  final Duration delay;
  final bool isPending;
  final String feeType;
  final Widget? trailing;

  const _FeesSection({
    required this.title,
    required this.subtitle,
    required this.fees,
    required this.fullFees,
    required this.theme,
    required this.delay,
    this.isPending = true,
    required this.feeType,
    this.trailing,
  });

  @override
  State<_FeesSection> createState() => _FeesSectionState();
}

class _FeesSectionState extends State<_FeesSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          decoration: BoxDecoration(
            color: widget.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: widget.theme.colorScheme.shadow.withOpacity(0.08),
                blurRadius: 20.r,
                offset: Offset(0, 8.h),
              ),
              BoxShadow(
                color: widget.theme.colorScheme.shadow.withOpacity(0.04),
                blurRadius: 40.r,
                offset: Offset(0, 16.h),
              ),
            ],
            border: Border.all(
              color: widget.theme.colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.theme.colorScheme.primary.withOpacity(0.05),
                      widget.theme.colorScheme.primary.withOpacity(0.02),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.title,
                                  style: widget.theme.textTheme.titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            widget.theme.colorScheme.onSurface,
                                      ),
                                ),
                              ),
                              if (widget.trailing != null) ...[
                                SizedBox(width: 16.w),
                                widget.trailing!,
                              ],
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            widget.subtitle,
                            style: widget.theme.textTheme.bodyMedium?.copyWith(
                              color: widget.theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final controller = Get.find<FeesController>();
                        final subtitle = _getFullFeesSubtitle(widget.title);
                        List<Map<String, dynamic>> fullFees;
                        if (widget.isPending) {
                          fullFees = await controller.getAllPendingFees(
                            widget.feeType,
                            month: widget.feeType == 'monthly'
                                ? controller.selectedMonth.value
                                : null,
                            classId: widget.feeType == 'monthly'
                                ? controller.selectedClassModel?.id
                                : null,
                          );
                        } else {
                          fullFees = await controller.getAllPaidFees(
                            widget.feeType,
                            month: widget.feeType == 'monthly'
                                ? controller.selectedMonth.value
                                : null,
                            classId: widget.feeType == 'monthly'
                                ? controller.selectedClassModel?.id
                                : null,
                          );
                        }
                        Get.dialog(
                          FullFeesListDialog(
                            title: 'All ${widget.title}',
                            subtitle: subtitle,
                            fees: fullFees,
                            isPending: widget.isPending,
                          ),
                        );
                      },
                      icon: Icon(Icons.visibility_outlined, size: 18.sp),
                      label: const Text('Show All'),
                      style: TextButton.styleFrom(
                        foregroundColor: widget.theme.colorScheme.primary,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Table
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.all(24.w),
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    widget.theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  ),
                  dataRowColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return widget.theme.colorScheme.primary.withOpacity(0.1);
                    }
                    if (states.contains(MaterialState.hovered)) {
                      return widget.theme.colorScheme.primary.withOpacity(0.05);
                    }
                    return null;
                  }),
                  border: TableBorder(
                    horizontalInside: BorderSide(
                      color: widget.theme.colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  columnSpacing: 24.w,
                  columns: const [
                    DataColumn(label: Text('Roll No')),
                    DataColumn(label: Text('Student Name')),
                    DataColumn(label: Text('Fees Type')),
                    DataColumn(label: Text('Fee Month')),
                    DataColumn(label: Text('Total Fees')),
                    DataColumn(label: Text('Paid Amount')),
                    DataColumn(label: Text('Remaining Amount')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: widget.fees.map((fee) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            fee['roll'] ?? '',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        DataCell(Text(fee['student_name'] ?? '')),
                        DataCell(
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: fee['fee_type'] == 'admission'
                                  ? widget.theme.colorScheme.primary
                                        .withOpacity(0.1)
                                  : widget.theme.colorScheme.secondary
                                        .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              (fee['fee_type'] ?? '').toUpperCase(),
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: fee['fee_type'] == 'admission'
                                    ? widget.theme.colorScheme.primary
                                    : widget.theme.colorScheme.secondary,
                              ),
                            ),
                          ),
                        ),
                        DataCell(Text(fee['fee_month'] ?? '')),
                        DataCell(
                          Text(
                            'Rs. ${fee['amount'] ?? ''}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: widget.theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        DataCell(
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Rs. ${fee['paid_amount'] ?? '0'}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: (fee['paid_amount'] ?? '0') != '0'
                                      ? widget.theme.colorScheme.primary
                                      : widget
                                            .theme
                                            .colorScheme
                                            .onSurfaceVariant,
                                ),
                              ),
                              if ((fee['paid_amount'] ?? '0') != '0') ...[
                                SizedBox(height: 4.h),
                                Container(
                                  width: 60.w,
                                  height: 4.h,
                                  decoration: BoxDecoration(
                                    color:
                                        widget.theme.colorScheme.surfaceVariant,
                                    borderRadius: BorderRadius.circular(2.r),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: _calculateProgress(fee),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: widget.theme.colorScheme.primary,
                                        borderRadius: BorderRadius.circular(
                                          2.r,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        DataCell(
                          Text(
                            'Rs. ${fee['remaining_amount'] ?? fee['amount'] ?? ''}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: widget.isPending
                                  ? widget.theme.colorScheme.error
                                  : Colors.green,
                            ),
                          ),
                        ),
                        DataCell(
                          widget.isPending
                              ? ElevatedButton(
                                  onPressed: () {
                                    Get.dialog(PayFeeDialog(fee: fee));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 8.h,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                  child: const Text('Pay Fees'),
                                )
                              : IconButton(
                                  onPressed: () {
                                    Get.dialog(PaymentHistoryDialog(fee: fee));
                                  },
                                  icon: Icon(
                                    Icons.visibility_outlined,
                                    size: 20.sp,
                                    color: widget.theme.colorScheme.secondary,
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: widget
                                        .theme
                                        .colorScheme
                                        .secondary
                                        .withOpacity(0.1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                  tooltip: 'View Payment History',
                                ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateProgress(Map<String, dynamic> fee) {
    final total = double.tryParse(fee['amount'] ?? '0') ?? 0;
    final paid = double.tryParse(fee['paid_amount'] ?? '0') ?? 0;
    if (total == 0) return 0;
    return (paid / total).clamp(0.0, 1.0);
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return '';
    }
  }

  String _getFullFeesSubtitle(String title) {
    switch (title) {
      case 'Pending Admission Fees':
        return 'Complete list of all pending admission fee payments';
      case 'Pending Monthly Fees':
        return 'Complete list of all pending monthly fee payments';
      case 'Pending Exam Fees':
        return 'Complete list of all pending exam fee payments';
      case 'Pending Misc Fees':
        return 'Complete list of all pending misc fee payments';
      case 'Paid Admission Fees':
        return 'Complete list of all completed admission fee payments';
      case 'Paid Monthly Fees':
        return 'Complete list of all completed monthly fee payments';
      case 'Paid Exam Fees':
        return 'Complete list of all completed exam fee payments';
      case 'Paid Misc Fees':
        return 'Complete list of all completed misc fee payments';
      default:
        return '';
    }
  }
}

class _FeeTypeButton extends StatefulWidget {
  final String icon;
  final String title;
  final bool isActive;
  final VoidCallback onTap;
  final ThemeData theme;

  const _FeeTypeButton({
    required this.icon,
    required this.title,
    required this.isActive,
    required this.onTap,
    required this.theme,
  });

  @override
  State<_FeeTypeButton> createState() => _FeeTypeButtonState();
}

class _FeeTypeButtonState extends State<_FeeTypeButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) => _animationController.reverse(),
        onTapCancel: () => _animationController.reverse(),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _scaleAnimation.value,
          duration: const Duration(milliseconds: 200),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.isActive
                    ? [
                        widget.theme.colorScheme.primary.withOpacity(0.2),
                        widget.theme.colorScheme.primary.withOpacity(0.1),
                      ]
                    : [
                        widget.theme.colorScheme.surfaceVariant.withOpacity(
                          0.5,
                        ),
                        widget.theme.colorScheme.surfaceVariant.withOpacity(
                          0.2,
                        ),
                      ],
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: widget.isActive
                    ? widget.theme.colorScheme.primary.withOpacity(0.3)
                    : widget.theme.colorScheme.outline.withOpacity(0.2),
                width: widget.isActive ? 2 : 1,
              ),
              boxShadow: widget.isActive
                  ? [
                      BoxShadow(
                        color: widget.theme.colorScheme.primary.withOpacity(
                          0.2,
                        ),
                        blurRadius: 12.r,
                        offset: Offset(0, 6.h),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.icon, style: TextStyle(fontSize: 32.sp)),
                SizedBox(height: 8.h),
                Text(
                  widget.title,
                  style: widget.theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: widget.isActive
                        ? widget.theme.colorScheme.primary
                        : widget.theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeeSubsection extends StatelessWidget {
  final List<Map<String, dynamic>> pendingFees;
  final List<Map<String, dynamic>> paidFees;
  final String feeType;
  final ThemeData theme;

  const _FeeSubsection({
    super.key,
    required this.pendingFees,
    required this.paidFees,
    required this.feeType,
    required this.theme,
  });

  String _getFeeTypeTitle(String type, bool isPending) {
    final status = isPending ? 'Pending' : 'Paid';
    final feeName = type == 'admission'
        ? 'Admission'
        : type == 'monthly'
        ? 'Monthly'
        : type == 'exam'
        ? 'Exam'
        : 'Misc';
    return '$status $feeName Fees';
  }

  String _getFeeTypeSubtitle(String type, bool isPending) {
    final status = isPending ? 'awaiting completion' : 'completed';
    final feeName = type == 'admission'
        ? 'admission'
        : type == 'monthly'
        ? 'monthly'
        : type == 'exam'
        ? 'exam'
        : 'misc';
    return 'Recent $feeName fee payments $status';
  }

  Widget _buildFilters() {
    final controller = Get.find<FeesController>();

    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Class Grid
          Text(
            'Select Class',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 16.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 2.5,
            ),
            itemCount: controller.classList.length,
            itemBuilder: (context, index) {
              final classModel = controller.classList[index];
              final isSelected =
                  controller.selectedClassModel?.id == classModel.id;
              return GestureDetector(
                onTap: () {
                  controller.selectedClassModel = classModel;
                  controller.update();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withOpacity(0.1)
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.2),
                              blurRadius: 8.r,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${classModel.className} ${classModel.section}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${classModel.studentCount.value} students',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 24.h),
          // Month Dropdown and View Fees Button
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select Month',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                  value: controller.selectedMonth.value.isEmpty
                      ? null
                      : controller.selectedMonth.value,
                  items: controller.monthList.map((month) {
                    return DropdownMenuItem<String>(
                      value: month,
                      child: Text(
                        month,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.selectedMonth.value = value;
                    }
                  },
                  dropdownColor: theme.colorScheme.surface,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              ElevatedButton.icon(
                onPressed: () {
                  if (controller.selectedClassModel != null &&
                      controller.selectedMonth.value.isNotEmpty) {
                    controller.fetchMonthlyFeesData();
                  } else {
                    Get.snackbar(
                      'Selection Required',
                      'Please select both class and month',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: theme.colorScheme.error,
                      colorText: theme.colorScheme.onError,
                    );
                  }
                },
                icon: Icon(Icons.search, size: 20.sp),
                label: const Text('View Fees'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FeesController>(
      builder: (controller) {
        final showSections =
            feeType != 'monthly' ||
            (controller.selectedClassModel != null &&
                controller.selectedMonth.value.isNotEmpty);

        return Column(
          children: [
            if (feeType == 'monthly') ...[
              _buildFilters(),
              SizedBox(height: 32.h),
            ],
            // Pending Fees Section
            _FeesSection(
              title: _getFeeTypeTitle(feeType, true),
              subtitle: _getFeeTypeSubtitle(feeType, true),
              fees: showSections ? pendingFees : [],
              fullFees: pendingFees,
              theme: theme,
              delay: const Duration(milliseconds: 200),
              isPending: true,
              feeType: feeType,
            ),

            SizedBox(height: 32.h),

            // Paid Fees Section
            _FeesSection(
              title: _getFeeTypeTitle(feeType, false),
              subtitle: _getFeeTypeSubtitle(feeType, false),
              fees: showSections ? paidFees : [],
              fullFees: paidFees,
              theme: theme,
              delay: const Duration(milliseconds: 400),
              isPending: false,
              feeType: feeType,
            ),
          ],
        );
      },
    );
  }
}
