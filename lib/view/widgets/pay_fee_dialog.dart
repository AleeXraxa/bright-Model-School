import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controller/fees_controller.dart';
import 'payment_success_dialog.dart';

class PayFeeDialog extends StatefulWidget {
  final Map<String, dynamic> fee;

  const PayFeeDialog({super.key, required this.fee});

  @override
  State<PayFeeDialog> createState() => _PayFeeDialogState();
}

class _PayFeeDialogState extends State<PayFeeDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  final TextEditingController _amountController = TextEditingController();
  final RxString _selectedPaymentMode = 'cash'.obs;
  final RxBool _isProcessing = false.obs;

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

    // Pre-fill total amount
    _amountController.text = widget.fee['amount'] ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _amountController.dispose();
    super.dispose();
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
            width: 500.w,
            constraints: BoxConstraints(maxHeight: 0.8.sh),
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
            child: SingleChildScrollView(
              padding: EdgeInsets.all(32.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.payment_rounded,
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
                              'Process Payment',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Complete fee payment for this student',
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

                  SizedBox(height: 32.h),

                  // Student Details Section
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
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
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        _buildDetailRow('Roll No', widget.fee['roll'] ?? ''),
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
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Payment Section
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.05),
                          theme.colorScheme.primary.withOpacity(0.02),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.credit_card_rounded,
                              color: theme.colorScheme.primary,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Payment Details',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),

                        // Total Fees (Read-only)
                        _buildPaymentField(
                          label: 'Total Fees',
                          value: 'Rs. ${widget.fee['amount'] ?? ''}',
                          isReadOnly: true,
                          icon: Icons.attach_money_rounded,
                        ),

                        SizedBox(height: 16.h),

                        // Amount to Pay
                        _buildPaymentField(
                          label: 'Amount to Pay',
                          controller: _amountController,
                          hint: 'Enter payment amount',
                          icon: Icons.edit_rounded,
                          keyboardType: TextInputType.number,
                        ),

                        SizedBox(height: 16.h),

                        // Payment Mode
                        Text(
                          'Payment Mode',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Obx(
                          () => Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.colorScheme.outline.withOpacity(
                                  0.3,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedPaymentMode.value,
                                isExpanded: true,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 4.h,
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'cash',
                                    child: Row(
                                      children: [
                                        Icon(Icons.money_rounded, size: 20),
                                        SizedBox(width: 8),
                                        Text('Cash'),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'online',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.account_balance_rounded,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text('Online'),
                                      ],
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    _selectedPaymentMode.value = value;
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 12.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Obx(
                        () => ElevatedButton(
                          onPressed: _isProcessing.value
                              ? null
                              : _processPayment,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 32.w,
                              vertical: 12.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 2,
                            shadowColor: theme.colorScheme.primary.withOpacity(
                              0.3,
                            ),
                          ),
                          child: _isProcessing.value
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline_rounded,
                                      size: 18.sp,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Process Payment',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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

  Widget _buildPaymentField({
    required String label,
    String? value,
    TextEditingController? controller,
    String? hint,
    IconData? icon,
    bool isReadOnly = false,
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(12.r),
            color: isReadOnly
                ? theme.colorScheme.surfaceVariant.withOpacity(0.3)
                : theme.colorScheme.surface,
          ),
          child: TextField(
            controller: controller,
            readOnly: isReadOnly,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: icon != null
                  ? Icon(icon, color: theme.colorScheme.primary, size: 20.sp)
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
            ),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _processPayment() async {
    final amount = _amountController.text.trim();
    if (amount.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter payment amount',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final paymentAmount = double.tryParse(amount);
    if (paymentAmount == null || paymentAmount <= 0) {
      Get.snackbar(
        'Error',
        'Please enter a valid payment amount',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final totalAmount = double.tryParse(widget.fee['amount'] ?? '0') ?? 0;
    if (paymentAmount > totalAmount) {
      Get.snackbar(
        'Error',
        'Payment amount cannot exceed total fees',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    _isProcessing.value = true;

    try {
      final controller = Get.find<FeesController>();
      await controller.payFee(
        widget.fee['id'],
        paymentAmount: amount,
        paymentMode: _selectedPaymentMode.value,
      );

      Get.back(); // Close dialog

      final isFullPayment = paymentAmount >= totalAmount;
      final remainingAmount = (totalAmount - paymentAmount).toStringAsFixed(2);

      Get.dialog(
        PaymentSuccessDialog(
          fee: widget.fee,
          paymentAmount: paymentAmount.toStringAsFixed(2),
          remainingAmount: remainingAmount,
          isFullPayment: isFullPayment,
        ),
        barrierDismissible: false,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to process payment. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isProcessing.value = false;
    }
  }
}
