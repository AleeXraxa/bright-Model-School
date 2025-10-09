import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FilterRow extends StatelessWidget {
  final List<String> filters;
  final int activeIndex;
  final ValueChanged<int> onSelected;
  const FilterRow({
    super.key,
    required this.filters,
    required this.activeIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < filters.length; i++) ...[
            _Pill(
              label: filters[i],
              active: i == activeIndex,
              onTap: () => onSelected(i),
            ),
            SizedBox(width: 8.w),
          ],
        ],
      ),
    );
  }
}

class _Pill extends StatefulWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Pill({required this.label, required this.active, required this.onTap});

  @override
  State<_Pill> createState() => _PillState();
}

class _PillState extends State<_Pill> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: _hover
            ? (Matrix4.identity()..translate(0.0, -2.0))
            : Matrix4.identity(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: widget.active
              ? theme.colorScheme.primary.withOpacity(0.15)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: widget.active
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
            width: widget.active ? 2 : 1,
          ),
          gradient: widget.active
              ? LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.1),
                    theme.colorScheme.primary.withOpacity(0.05),
                  ],
                )
              : null,
          boxShadow: _hover
              ? [
                  BoxShadow(
                    color:
                        (widget.active
                                ? theme.colorScheme.primary
                                : theme.colorScheme.shadow)
                            .withOpacity(0.2),
                    blurRadius: 16.r,
                    offset: Offset(0, 8.h),
                  ),
                  BoxShadow(
                    color:
                        (widget.active
                                ? theme.colorScheme.primary
                                : theme.colorScheme.shadow)
                            .withOpacity(0.1),
                    blurRadius: 32.r,
                    offset: Offset(0, 16.h),
                  ),
                ]
              : widget.active
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.15),
                    blurRadius: 12.r,
                    offset: Offset(0, 6.h),
                  ),
                ]
              : [],
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            color: widget.active
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withOpacity(0.8),
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }
}
