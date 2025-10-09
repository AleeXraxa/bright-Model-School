import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'utils/theme/app_theme.dart';
import 'utils/constants/app_routes.dart';
import 'view/auth/login_view.dart';
import 'controller/auth/login_controller.dart';
import 'service/auth_service.dart';
import 'view/admin/admin_layout.dart';
import 'controller/sidebar_controller.dart';
import 'controller/dashboard_controller.dart';
import 'controller/fees_controller.dart';
import 'view/dashboard/accountant_dashboard_view.dart';
import 'view/dashboard/staff_dashboard_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1440, 900),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Bright SMS',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          initialRoute: AppRoutes.login,
          initialBinding: BindingsBuilder(() {
            Get.put(AuthService());
            Future.microtask(() => Get.find<AuthService>().initDB());
          }),
          getPages: [
            GetPage(
              name: AppRoutes.login,
              page: () => const LoginView(),
              binding: BindingsBuilder(() {
                Get.put(LoginController());
              }),
            ),
            GetPage(
              name: AppRoutes.admin,
              page: () => const AdminLayout(),
              binding: BindingsBuilder(() {
                Get.put(SidebarController());
                Get.put(DashboardController());
                Get.put(FeesController());
              }),
            ),
            GetPage(
              name: AppRoutes.accountant,
              page: () => const AccountantDashboardView(),
            ),
            GetPage(
              name: AppRoutes.staff,
              page: () => const StaffDashboardView(),
            ),
          ],
        );
      },
    );
  }
}
