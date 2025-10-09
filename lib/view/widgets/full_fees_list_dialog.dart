import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controller/fees_controller.dart';
import 'pay_fee_dialog.dart';

class FullFeesListDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<Map<String, dynamic>> fees;
  final bool isPending;

  const FullFeesListDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.fees,
    this.isPending = true,
  });

  @override
  State<FullFeesListDialog> createState() => _FullFeesListDialogState();
}

class _FullFeesListDialogState extends State<FullFeesListDialog>
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
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.9,
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(24.w),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              widget.subtitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: Icon(Icons.close, size: 24.sp),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.surfaceVariant
                              .withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24.w),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.shadow.withOpacity(0.08),
                            blurRadius: 20.r,
                            offset: Offset(0, 8.h),
                          ),
                        ],
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(
                            theme.colorScheme.surfaceVariant.withOpacity(0.5),
                          ),
                          dataRowColor: MaterialStateProperty.resolveWith((
                            states,
                          ) {
                            if (states.contains(MaterialState.selected)) {
                              return theme.colorScheme.primary.withOpacity(0.1);
                            }
                            if (states.contains(MaterialState.hovered)) {
                              return theme.colorScheme.primary.withOpacity(
                                0.05,
                              );
                            }
                            return null;
                          }),
                          border: TableBorder(
                            horizontalInside: BorderSide(
                              color: theme.colorScheme.outline.withOpacity(0.2),
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
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
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
                                          ? theme.colorScheme.primary
                                                .withOpacity(0.1)
                                          : theme.colorScheme.secondary
                                                .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Text(
                                      (fee['fee_type'] ?? '').toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: fee['fee_type'] == 'admission'
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.secondary,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    'Rs. ${fee['amount'] ?? ''}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    'Rs. ${fee['paid_amount'] ?? '0'}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: (fee['paid_amount'] ?? '0') != '0'
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    'Rs. ${fee['remaining_amount'] ?? fee['amount'] ?? ''}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: widget.isPending
                                          ? theme.colorScheme.error
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
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                            ),
                                          ),
                                          child: const Text('Pay Fees'),
                                        )
                                      : IconButton(
                                          onPressed: () {
                                            Get.snackbar(
                                              'Fee Details',
                                              'Detailed fee information will be shown in the next phase',
                                              snackPosition:
                                                  SnackPosition.BOTTOM,
                                              backgroundColor:
                                                  theme.colorScheme.secondary,
                                              colorText:
                                                  theme.colorScheme.onSecondary,
                                            );
                                          },
                                          icon: Icon(
                                            Icons.visibility_outlined,
                                            size: 20.sp,
                                            color: theme.colorScheme.secondary,
                                          ),
                                          style: IconButton.styleFrom(
                                            backgroundColor: theme
                                                .colorScheme
                                                .secondary
                                                .withOpacity(0.1),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                            ),
                                          ),
                                          tooltip: 'View Fee Details',
                                        ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
