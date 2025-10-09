import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../view/admin/dashboard_view.dart';
import '../view/admin/students_view.dart';
import '../view/admin/classes_view.dart';
import '../view/admin/fees_view.dart';
import '../view/admin/challans_view.dart';
import '../view/admin/attendance_view.dart';
import '../view/admin/expenses_view.dart';

class SidebarController extends GetxController {
  final RxInt activeIndex = 0.obs;
  final RxBool isCollapsed = false.obs;

  final List<String> menuLabels = [
    'Dashboard',
    'Students',
    'Classes',
    'Fees',
    'Challans',
    'Attendance',
    'Expenses',
  ];

  final List<IconData> menuIcons = [
    Icons.grid_view_rounded,
    Icons.school_rounded,
    Icons.meeting_room_rounded,
    Icons.account_balance_wallet_rounded,
    Icons.receipt_long_rounded,
    Icons.checklist_rounded,
    Icons.account_balance_wallet_rounded,
  ];

  final List<Widget> screens = [
    const DashboardView(),
    StudentsView(),
    const ClassesView(),
    const FeesView(),
    const ChallansView(),
    const AttendanceView(),
    const ExpensesView(),
  ];

  Widget get currentScreen => screens[activeIndex.value];

  void setActive(int index) => activeIndex.value = index;
  void toggleCollapse() => isCollapsed.toggle();
}
