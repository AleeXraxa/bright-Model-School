import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../service/auth_service.dart';
import '../../utils/constants/app_routes.dart';
import '../../utils/custom_dialog.dart';

class LoginController extends GetxController {
  final RxBool isLoading = false.obs;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  final RxString emailError = ''.obs;
  final RxString passwordError = ''.obs;
  final RxBool isPasswordObscured = true.obs;

  @override
  void onInit() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.onInit();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  bool _validateFields() {
    final String email = emailController.text.trim();
    final String password = passwordController.text;
    String emailErr = '';
    String passErr = '';

    if (email.isEmpty) {
      emailErr = 'Please enter your email or username';
    }
    if (password.isEmpty) {
      passErr = 'Please enter your password';
    }

    emailError.value = emailErr;
    passwordError.value = passErr;

    return emailErr.isEmpty && passErr.isEmpty;
  }

  Future<void> login() async {
    if (isLoading.value) return;
    if (!_validateFields()) return;
    isLoading.value = true;
    try {
      // Artificial delay to show loading state
      await Future<void>.delayed(const Duration(seconds: 2));
      final auth = AuthService();
      final user = await auth.login(
        emailController.text,
        passwordController.text,
      );
      if (user == null) {
        Get.dialog(
          CustomDialog(
            title: 'Login Failed',
            message: 'Invalid username or password',
            onConfirm: () => Get.back(),
          ),
          barrierDismissible: true,
        );
        return;
      }
      switch (user.role) {
        case 'Admin':
          Get.offAllNamed(AppRoutes.admin);
          break;
        case 'Accountant':
          Get.offAllNamed(AppRoutes.accountant);
          break;
        case 'Staff':
          Get.offAllNamed(AppRoutes.staff);
          break;
        default:
          Get.offAllNamed(AppRoutes.login);
      }
    } finally {
      isLoading.value = false;
    }
  }
}
