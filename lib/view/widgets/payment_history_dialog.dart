import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controller/fees_controller.dart';

class PaymentHistoryDialog extends StatefulWidget {
  final Map<String, dynamic> fee;

  const PaymentHistoryDialog({super.key, required this.fee});

  @override
  State<PaymentHistoryDialog> createState() => _PaymentHistoryDialogState();
}

class _PaymentHistoryDialogState extends State<PaymentHistoryDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  final RxList<Map<String, dynamic>> paymentHistory =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
      _loadPaymentHistory();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentHistory() async {
    try {
      final controller = Get.find<FeesController>();
      final history = await controller.getPaymentHistory(widget.fee['id']);
      paymentHistory.value = history;
    } catch (e) {
      print('Error loading payment history: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(0.15),
                  blurRadius: 30.r,
                  offset: Offset(0, 10.h),
                ),
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 60.r,
                  offset: Offset(0, 20.h),
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
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.05),
                        theme.colorScheme.primary.withOpacity(0.02),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.history_rounded,
                          color: theme.colorScheme.primary,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment History',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Detailed payment transactions for this fee',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: Icon(
                          Icons.close_rounded,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Student Details Section
                        Container(
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant.withOpacity(
                              0.3,
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: theme.colorScheme.outline.withOpacity(0.1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_outline_rounded,
                                    color: theme.colorScheme.primary,
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Student Details',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              _buildDetailRow(
                                'Roll No',
                                widget.fee['roll'] ?? '',
                              ),
                              _buildDetailRow(
                                'Student Name',
                                widget.fee['student_name'] ?? '',
                              ),
                              _buildDetailRow(
                                'Father Name',
                                widget.fee['father_name'] ?? '',
                              ),
                              _buildDetailRow(
                                'Account No',
                                widget.fee['account_number'] ?? '',
                              ),
                              _buildDetailRow(
                                'Fee Type',
                                (widget.fee['fee_type'] ?? '').toUpperCase(),
                              ),
                              _buildDetailRow(
                                'Total Fees',
                                'Rs. ${widget.fee['amount'] ?? ''}',
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24.h),

                        // Payment History Section
                        Row(
                          children: [
                            Icon(
                              Icons.receipt_long_rounded,
                              color: theme.colorScheme.primary,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Payment Transactions',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        Obx(() {
                          if (isLoading.value) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(48.w),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (paymentHistory.isEmpty) {
                            return Container(
                              padding: EdgeInsets.all(48.w),
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.payment_rounded,
                                    size: 48.sp,
                                    color: theme.colorScheme.onSurfaceVariant
                                        .withOpacity(0.5),
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'No payment transactions found',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.colorScheme.outline.withOpacity(
                                  0.2,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowColor: MaterialStateProperty.all(
                                  theme.colorScheme.surfaceVariant.withOpacity(
                                    0.5,
                                  ),
                                ),
                                dataRowColor: MaterialStateProperty.resolveWith(
                                  (states) {
                                    if (states.contains(
                                      MaterialState.selected,
                                    )) {
                                      return theme.colorScheme.primary
                                          .withOpacity(0.1);
                                    }
                                    if (states.contains(
                                      MaterialState.hovered,
                                    )) {
                                      return theme.colorScheme.primary
                                          .withOpacity(0.05);
                                    }
                                    return null;
                                  },
                                ),
                                border: TableBorder(
                                  horizontalInside: BorderSide(
                                    color: theme.colorScheme.outline
                                        .withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                columnSpacing: 24.w,
                                columns: const [
                                  DataColumn(label: Text('Payment Date')),
                                  DataColumn(label: Text('Paid Amount')),
                                  DataColumn(label: Text('Remaining Amount')),
                                  DataColumn(label: Text('Payment Mode')),
                                ],
                                rows: paymentHistory.map((payment) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          payment['payment_date'] ?? '',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          'Rs. ${payment['amount'] ?? ''}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          'Rs. ${payment['remaining_after_payment'] ?? ''}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color:
                                                (payment['remaining_after_payment'] ??
                                                        '0') ==
                                                    '0.00'
                                                ? Colors.green
                                                : theme.colorScheme.error,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8.w,
                                            vertical: 4.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                payment['payment_mode'] ==
                                                    'cash'
                                                ? Colors.green.withOpacity(0.1)
                                                : Colors.blue.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              12.r,
                                            ),
                                          ),
                                          child: Text(
                                            (payment['payment_mode'] ?? '')
                                                .toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  payment['payment_mode'] ==
                                                      'cash'
                                                  ? Colors.green.shade700
                                                  : Colors.blue.shade700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                // Footer
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20.r),
                      bottomRight: Radius.circular(20.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 12.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Close',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
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

  Widget _buildDetailRow(String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
