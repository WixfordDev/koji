import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../constants/app_color.dart';

class CustomPinCodeTextField extends StatelessWidget {
  final TextEditingController? textEditingController;

  const CustomPinCodeTextField({super.key, this.textEditingController});

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      backgroundColor: AppColor.backgroundColor,
      cursorColor: AppColor.primaryColor,
      controller: textEditingController,
      textStyle:  TextStyle(color: AppColor.borderColor162238),
      autoFocus: false,
      appContext: context,
      length: 6,
      pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(10),
          selectedColor: AppColor.primaryColor,
          activeFillColor: AppColor.primaryColor,
          selectedFillColor: AppColor.primaryColor,
          inactiveFillColor: AppColor.primaryColor,
          fieldHeight: 55.h,
          fieldWidth: 48.w,
          inactiveColor: AppColor.borderColor162238,
          activeColor: AppColor.primaryColor),
      obscureText: false,
      keyboardType: TextInputType.number,
      onChanged: (value) {},
      onCompleted: (value) {
        textEditingController?.text = value;
      },
    );
  }
}