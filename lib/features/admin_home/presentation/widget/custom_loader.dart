import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../../constants/app_color.dart';




class CustomLoader extends StatelessWidget {
  final double? top;
  final double? bottom;
  const CustomLoader({super.key, this.top, this.bottom});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.only(top: top ?? 0, bottom: bottom ?? 0),
      child: SpinKitCircle(
          color: AppColor.primaryColor,
          size: 48.h
      ),
    );
  }
}