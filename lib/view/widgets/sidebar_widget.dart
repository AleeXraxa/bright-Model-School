import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controller/sidebar_controller.dart';
import '../../service/auth_service.dart';
import '../../utils/custom_dialog.dart';
import '../../utils/constants/app_routes.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final SidebarController controller = Get.put(SidebarController());

    return Obx(() {
      final bool collapsed = controller.isCollapsed.value;
      final double width = collapsed ? 76.w : 220.w;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOutCubic,
        width: width,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16.r),
            bottomRight: Radius.circular(16.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20.r,
              offset: Offset(0, 10.h),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with collapse button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              child: Row(
                children: [
                  if (!collapsed)
                    Expanded(
                      child: Text(
                        'Bright SMS',
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  _CollapseButton(
                    collapsed: collapsed,
                    onTap: controller.toggleCollapse,
                  ),
                ],
              ),
            ),

            SizedBox(height: 4.h),

            // Menu items
            Expanded(
              child: ListView.separated(
                itemCount: controller.menuLabels.length,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                separatorBuilder: (_, __) => SizedBox(height: 4.h),
                itemBuilder: (context, index) {
                  return _SidebarItem(
                    index: index,
                    label: controller.menuLabels[index],
                    icon: controller.menuIcons[index],
                    collapsed: collapsed,
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Divider(height: 1.h),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 10.h),
              child: _LogoutButton(collapsed: collapsed),
            ),
            SizedBox(height: 4.h),
          ],
        ),
      );
    });
  }
}

class _CollapseButton extends StatefulWidget {
  final bool collapsed;
  final VoidCallback onTap;
  const _CollapseButton({required this.collapsed, required this.onTap});

  @override
  State<_CollapseButton> createState() => _CollapseButtonState();
}

class _CollapseButtonState extends State<_CollapseButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: _hover
              ? theme.colorScheme.primary.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10.r),
          onTap: widget.onTap,
          child: Padding(
            padding: EdgeInsets.all(8.w),
            child: AnimatedRotation(
              turns: widget.collapsed ? 0.0 : 0.5,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              child: Icon(Icons.chevron_left_rounded, size: 20.sp),
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final int index;
  final String label;
  final IconData icon;
  final bool collapsed;
  const _SidebarItem({
    required this.index,
    required this.label,
    required this.icon,
    required this.collapsed,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final SidebarController controller = Get.find<SidebarController>();

    return Obx(() {
      final bool active = controller.activeIndex.value == widget.index;
      return MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => controller.setActive(widget.index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: active
                  ? theme.colorScheme.primary.withOpacity(0.12)
                  : (_hover
                        ? theme.colorScheme.primary.withOpacity(0.06)
                        : Colors.transparent),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  size: 20.sp,
                  color: active
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                if (!widget.collapsed) ...[
                  SizedBox(width: 10.w),
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 180),
                      style: TextStyle(
                        color: active
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.8),
                        fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 14.sp,
                      ),
                      child: Text(
                        widget.label,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _LogoutButton extends StatefulWidget {
  final bool collapsed;
  const _LogoutButton({required this.collapsed});

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final Color base = Colors.red;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        transform: _hover
            ? (Matrix4.identity()..translate(0.0, -1.0))
            : Matrix4.identity(),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: _hover ? base.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () async {
            // Collapse sidebar if open
            final SidebarController c = Get.find<SidebarController>();
            if (!c.isCollapsed.value) c.toggleCollapse();

            // Show loader dialog
            Get.dialog(const _LogoutLoaderDialog(), barrierDismissible: false);
            try {
              await AuthService().logout();
              await Future<void>.delayed(const Duration(seconds: 1));
              Get.offAllNamed(AppRoutes.login);
            } catch (e) {
              Get.back();
              Get.dialog(
                CustomDialog(
                  title: 'Logout Failed',
                  message: 'Please try again. Error: $e',
                  onConfirm: () => Get.back(),
                ),
              );
            }
          },
          child: Row(
            children: [
              Icon(Icons.logout_rounded, size: 20.sp, color: base),
              if (!widget.collapsed) ...[
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Logout',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: base,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutLoaderDialog extends StatelessWidget {
  const _LogoutLoaderDialog();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 300.w),
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 20.r,
                  offset: Offset(0, 10.h),
                ),
              ],
            ),
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator(strokeWidth: 2.2),
                ),
                SizedBox(width: 12.w),
                Text('Logging out...', style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
