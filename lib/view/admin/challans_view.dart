import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChallansView extends StatelessWidget {
  const ChallansView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Center(
        child: Text(
          'Challans View',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
