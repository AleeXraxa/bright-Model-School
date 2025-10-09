import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/widgets.dart';

class ScreenUtilHelper {
  static const Size desktopDesignSize = Size(1440, 900);

  static double desktopPadding(double value) => value.w;
  static double desktopGap(double value) => value.h;
  static double desktopFont(double value) => value.sp;
}


