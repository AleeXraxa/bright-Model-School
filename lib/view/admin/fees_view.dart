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
                  return Column(
                    children: [
                      // Pending Admission Fees Section
                      _FeesSection(
                        title: 'Pending Admission Fees',
                        subtitle:
                            'Recent admission fee payments awaiting completion',
                        fees: controller.admissionFees,
                        fullFees: controller.admissionFees,
                        theme: theme,
                        delay: const Duration(milliseconds: 200),
                        isPending: true,
                      ),

                      SizedBox(height: 32.h),

                      // Pending Monthly Fees Section
                      _FeesSection(
                        title: 'Pending Monthly Fees',
                        subtitle:
                            'Recent monthly fee payments requiring attention',
                        fees: controller.monthlyFees,
                        fullFees: controller.monthlyFees,
                        theme: theme,
                        delay: const Duration(milliseconds: 400),
                        isPending: true,
                      ),

                      SizedBox(height: 32.h),

                      // Paid Admission Fees Section
                      _FeesSection(
                        title: 'Paid Admission Fees',
                        subtitle: 'Recently completed admission fee payments',
                        fees: controller.paidAdmissionFees,
                        fullFees: controller.paidAdmissionFees,
                        theme: theme,
                        delay: const Duration(milliseconds: 600),
                        isPending: false,
                      ),

                      SizedBox(height: 32.h),

                      // Paid Monthly Fees Section
                      _FeesSection(
                        title: 'Paid Monthly Fees',
                        subtitle: 'Recently completed monthly fee payments',
                        fees: controller.paidMonthlyFees,
                        fullFees: controller.paidMonthlyFees,
                        theme: theme,
                        delay: const Duration(milliseconds: 800),
                        isPending: false,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
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

  const _FeesSection({
    required this.title,
    required this.subtitle,
    required this.fees,
    required this.fullFees,
    required this.theme,
    required this.delay,
    this.isPending = true,
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
                          Text(
                            widget.title,
                            style: widget.theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: widget.theme.colorScheme.onSurface,
                            ),
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
                          if (widget.title.contains('Admission')) {
                            fullFees = await controller.getAllPendingFees(
                              'admission',
                            );
                          } else {
                            fullFees = await controller.getAllPendingFees(
                              'monthly',
                            );
                          }
                        } else {
                          if (widget.title.contains('Admission')) {
                            fullFees = await controller.getAllPaidFees(
                              'admission',
                            );
                          } else {
                            fullFees = await controller.getAllPaidFees(
                              'monthly',
                            );
                          }
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
                    DataColumn(label: Text('Account Name')),
                    DataColumn(label: Text('Fees Type')),
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
                        DataCell(Text(fee['account_number'] ?? '')),
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

  String _getFullFeesSubtitle(String title) {
    switch (title) {
      case 'Pending Admission Fees':
        return 'Complete list of all pending admission fee payments';
      case 'Pending Monthly Fees':
        return 'Complete list of all pending monthly fee payments';
      case 'Paid Admission Fees':
        return 'Complete list of all completed admission fee payments';
      case 'Paid Monthly Fees':
        return 'Complete list of all completed monthly fee payments';
      default:
        return '';
    }
  }
}
