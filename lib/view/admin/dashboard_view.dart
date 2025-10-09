import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/stat_card.dart';
import '../widgets/reactive_stat_card.dart';
import '../../controller/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top bar placeholder
          Container(
            height: 56.h,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 18.r,
                  offset: Offset(0, 8.h),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            alignment: Alignment.centerLeft,
            child: Text(
              'Welcome to Bright Model School',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(height: 16.h),

          // Responsive grid of stat cards
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double maxW = constraints.maxWidth;
                final double spacing = 12.w;
                final int columns = maxW >= 1200 ? 3 : (maxW >= 800 ? 2 : 1);
                final double itemW =
                    (maxW - (spacing * (columns - 1))) / columns;

                final List<Widget> cards = <Widget>[
                  ReactiveStatCard(
                    icon: Icons.people_alt_rounded,
                    accent: const Color(0xFF6C63FF),
                    title: 'Students',
                    value: controller.totalStudents,
                  ),
                  ReactiveStatCard(
                    icon: Icons.class_rounded,
                    accent: const Color(0xFF26C6DA),
                    title: 'Classes',
                    value: controller.totalClasses,
                  ),
                  const StatCard(
                    icon: Icons.payments_rounded,
                    accent: Color(0xFF66BB6A),
                    title: 'Revenue This Month',
                    value: '\$120,000',
                  ),
                  ReactiveStatCard(
                    icon: Icons.how_to_reg_rounded,
                    accent: const Color(0xFF7E57C2),
                    title: 'Admission This Month',
                    value: controller.admissionThisMonth,
                  ),
                  const StatCard(
                    icon: Icons.receipt_rounded,
                    accent: Color(0xFFEF5350),
                    title: 'Remaining Fees This Month',
                    value: '\$18,500',
                  ),
                ];

                return SingleChildScrollView(
                  child: Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: cards
                        .map((c) => SizedBox(width: itemW, child: c))
                        .toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
