import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controller/auth/login_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeLeft;
  late final Animation<Offset> _slideLeft;
  late final Animation<double> _fadeRight;
  late final Animation<Offset> _slideRight;

  final RxBool _hoveringLogin = false.obs;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
    _fadeLeft = CurvedAnimation(parent: _animController, curve: const Interval(0.0, 0.7, curve: Curves.easeOut));
    _slideLeft = Tween<Offset>(begin: const Offset(-0.04, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic)));
    _fadeRight = CurvedAnimation(parent: _animController, curve: const Interval(0.2, 1.0, curve: Curves.easeOut));
    _slideRight = Tween<Offset>(begin: const Offset(0.06, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic)));
    // Delay a frame to ensure ScreenUtil is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) => _animController.forward());
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: color, width: 1.2),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final LoginController controller = Get.find<LoginController>();

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              // Left 60%
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.15),
                        theme.colorScheme.primaryContainer.withOpacity(0.25),
                      ],
                    ),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 640.w),
                      child: FadeTransition(
                        opacity: _fadeLeft,
                        child: SlideTransition(
                          position: _slideLeft,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Bright Model School',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontSize: 42.sp,
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                'Learning at its best',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: 18.sp,
                                  color: theme.colorScheme.onSurface.withOpacity(0.75),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Right 40%
              Expanded(
                flex: 2,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 520.w),
                    child: FadeTransition(
                      opacity: _fadeRight,
                      child: SlideTransition(
                        position: _slideRight,
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 24.r,
                                offset: Offset(0, 12.h),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 28.h),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text('Welcome back', style: theme.textTheme.titleLarge),
                              SizedBox(height: 8.h),
                              Text('Please sign in to continue', style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
                              SizedBox(height: 24.h),
                              FocusTraversalGroup(
                                child: Column(
                                  children: [
                                    Obx(() => _AnimatedTextField(
                                          controller: controller.emailController,
                                          label: 'Email or Username',
                                          keyboardType: TextInputType.emailAddress,
                                          borderBuilder: _inputBorder,
                                          errorText: controller.emailError.value.isEmpty ? null : controller.emailError.value,
                                        )),
                                    SizedBox(height: 8.h),
                                    Obx(() => _AnimatedTextField(
                                          controller: controller.passwordController,
                                          label: 'Password',
                                          obscureText: controller.isPasswordObscured.value,
                                          borderBuilder: _inputBorder,
                                          errorText: controller.passwordError.value.isEmpty ? null : controller.passwordError.value,
                                          suffix: IconButton(
                                            onPressed: () => controller.isPasswordObscured.toggle(),
                                            icon: Icon(
                                              controller.isPasswordObscured.value ? Icons.visibility_off : Icons.visibility,
                                            ),
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                              SizedBox(height: 22.h),
                              Obx(() => MouseRegion(
                                    onEnter: (_) => _hoveringLogin.value = true,
                                    onExit: (_) => _hoveringLogin.value = false,
                                    cursor: SystemMouseCursors.click,
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 180),
                                      curve: Curves.easeOut,
                                      transform: _hoveringLogin.value
                                          ? (Matrix4.identity()..translate(0.0, -1.5))
                                          : Matrix4.identity(),
                                      decoration: BoxDecoration(
                                        color: controller.isLoading.value
                                            ? theme.colorScheme.primary.withOpacity(0.6)
                                            : theme.colorScheme.primary,
                                        borderRadius: BorderRadius.circular(12.r),
                                        boxShadow: _hoveringLogin.value
                                            ? [
                                                BoxShadow(
                                                  color: theme.colorScheme.primary.withOpacity(0.24),
                                                  blurRadius: 18.r,
                                                  offset: Offset(0, 10.h),
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          splashColor: Colors.white24,
                                          highlightColor: Colors.transparent,
                                          borderRadius: BorderRadius.circular(12.r),
                                          onTap: controller.isLoading.value ? null : controller.login,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(vertical: 14.h),
                                            child: Center(
                                              child: controller.isLoading.value
                                                  ? SizedBox(
                                                      height: 18.h,
                                                      width: 18.w,
                                                      child: const CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                                                    )
                                                  : Text(
                                                      'Login',
                                                      style: theme.textTheme.bodyLarge?.copyWith(
                                                        color: theme.colorScheme.onPrimary,
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 16.sp,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )),
                              SizedBox(height: 12.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final OutlineInputBorder Function(Color color) borderBuilder;
  final String? errorText;
  final Widget? suffix;

  const _AnimatedTextField({
    required this.controller,
    required this.label,
    required this.borderBuilder,
    this.obscureText = false,
    this.keyboardType,
    this.errorText,
    this.suffix,
  });

  @override
  State<_AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<_AnimatedTextField> {
  late final FocusNode _focusNode;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isFocused = _focusNode.hasFocus;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.text,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: _hovering ? (Matrix4.identity()..translate(0.0, -0.5)) : Matrix4.identity(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: (isFocused || _hovering)
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    blurRadius: 14.r,
                    offset: Offset(0, 8.h),
                  ),
                ]
              : [],
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          decoration: InputDecoration(
            labelText: widget.label,
            filled: true,
            fillColor: theme.colorScheme.surface,
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            border: widget.borderBuilder(theme.dividerColor.withOpacity(0.6)),
            enabledBorder: widget.borderBuilder(theme.dividerColor.withOpacity(0.6)),
            focusedBorder: widget.borderBuilder(theme.colorScheme.primary),
            hoverColor: Colors.transparent,
            errorText: widget.errorText,
            errorStyle: TextStyle(fontSize: 12.sp),
            suffixIcon: widget.suffix,
          ),
        ),
      ),
    );
  }
}


