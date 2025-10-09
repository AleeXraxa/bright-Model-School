import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../model/student_model.dart';

class StudentDetailsCard extends StatefulWidget {
  final StudentModel student;

  const StudentDetailsCard({super.key, required this.student});

  @override
  State<StudentDetailsCard> createState() => _StudentDetailsCardState();
}

class _StudentDetailsCardState extends State<StudentDetailsCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

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

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 600.w,
              constraints: BoxConstraints(maxHeight: 0.8.sh),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 40.r,
                    offset: Offset(0, 20.h),
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
                          Icons.person,
                          color: theme.colorScheme.primary,
                          size: 32.sp,
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Text(
                            'Student Details',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _closeCard(),
                          icon: Icon(
                            Icons.close,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            size: 24.sp,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(32.w),
                      child: Column(
                        children: [
                          _buildInfoSection(
                            title: 'Basic Information',
                            icon: Icons.info,
                            children: [
                              _buildInfoRow('Roll No', widget.student.roll),
                              _buildInfoRow('GR No', widget.student.grNo),
                              _buildInfoRow('Name', widget.student.name),
                              _buildInfoRow(
                                'Father Name',
                                widget.student.fatherName,
                              ),
                              _buildInfoRow(
                                'Admission Date',
                                widget.student.admissionDate,
                              ),
                            ],
                          ),
                          SizedBox(height: 24.h),
                          _buildInfoSection(
                            title: 'Birth Details',
                            icon: Icons.cake,
                            children: [
                              _buildInfoRow(
                                'Date of Birth (Figures)',
                                widget.student.dateOfBirthFigures,
                              ),
                              _buildInfoRow(
                                'Date of Birth (Words)',
                                widget.student.dateOfBirthWords,
                              ),
                              _buildInfoRow(
                                'Place of Birth',
                                widget.student.placeOfBirth,
                              ),
                              _buildInfoRow('Caste', widget.student.caste),
                            ],
                          ),
                          SizedBox(height: 24.h),
                          _buildInfoSection(
                            title: 'Personal Details',
                            icon: Icons.person_outline,
                            children: [
                              _buildInfoRow('Gender', widget.student.gender),
                              _buildInfoRow(
                                'Religion',
                                widget.student.religion,
                              ),
                              _buildInfoRow(
                                'Father Contact',
                                widget.student.fatherContact,
                              ),
                              _buildInfoRow(
                                'Mother Contact',
                                widget.student.motherContact,
                              ),
                              _buildInfoRow(
                                'Address',
                                widget.student.address,
                                maxLines: 3,
                              ),
                            ],
                          ),
                          SizedBox(height: 24.h),
                          _buildInfoSection(
                            title: 'Academic Details',
                            icon: Icons.school,
                            children: [
                              _buildInfoRow(
                                'Class',
                                widget.student.studentClass,
                              ),
                              _buildInfoRow('Section', widget.student.section),
                            ],
                          ),
                          SizedBox(height: 24.h),
                          _buildInfoSection(
                            title: 'Fees & Account',
                            icon: Icons.attach_money,
                            children: [
                              _buildInfoRow(
                                'Admission Fees',
                                widget.student.admissionFees,
                              ),
                              _buildInfoRow(
                                'Monthly Fees',
                                widget.student.monthlyFees,
                              ),
                              _buildInfoRow(
                                'Account No',
                                widget.student.accountNumber,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Footer with Close Button
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
                        ElevatedButton(
                          onPressed: () => _closeCard(),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 32.w,
                              vertical: 12.h,
                            ),
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'Close',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
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
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
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
              Icon(icon, color: theme.colorScheme.primary, size: 20.sp),
              SizedBox(width: 12.w),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {int maxLines = 1}) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150.w,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not provided' : value,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _closeCard() {
    _animationController.reverse().then((_) => Get.back());
  }
}
