import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/sidebar_controller.dart';
import '../widgets/sidebar_widget.dart';

class AdminLayout extends StatelessWidget {
  const AdminLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final SidebarController controller = Get.find<SidebarController>();

    return Scaffold(
      body: Row(
        children: [
          const Sidebar(),
          Expanded(child: Obx(() => controller.currentScreen)),
        ],
      ),
    );
  }
}
