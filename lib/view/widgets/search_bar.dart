import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DesktopSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback onSubmit;
  const DesktopSearchBar({
    super.key,
    required this.controller,
    required this.hint,
    required this.onSubmit,
  });

  @override
  State<DesktopSearchBar> createState() => _DesktopSearchBarState();
}

class _DesktopSearchBarState extends State<DesktopSearchBar> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          gradient: _hover
              ? LinearGradient(
                  colors: [
                    theme.colorScheme.surface,
                    theme.colorScheme.surfaceVariant.withOpacity(0.1),
                  ],
                )
              : null,
          boxShadow: _hover
              ? [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.12),
                    blurRadius: 20.r,
                    offset: Offset(0, 10.h),
                  ),
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.08),
                    blurRadius: 40.r,
                    offset: Offset(0, 20.h),
                  ),
                ]
              : [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.06),
                    blurRadius: 16.r,
                    offset: Offset(0, 8.h),
                  ),
                ],
          border: Border.all(
            color: _hover
                ? theme.colorScheme.primary.withOpacity(0.2)
                : theme.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.search_rounded,
                color: _hover ? theme.colorScheme.primary : theme.hintColor,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: TextField(
                controller: widget.controller,
                onSubmitted: (_) => widget.onSubmit(),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
            if (widget.controller.text.isNotEmpty)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12.r),
                  onTap: () {
                    widget.controller.clear();
                    setState(() {});
                  },
                  child: Padding(
                    padding: EdgeInsets.all(8.w),
                    child: Icon(
                      Icons.close_rounded,
                      size: 20.sp,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
