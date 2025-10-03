import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:koji/shared_widgets/custom_auth_text_field.dart';
import 'package:koji/shared_widgets/custom_button.dart';
import 'package:koji/shared_widgets/custom_text.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController passwordCtrl = TextEditingController();
  TextEditingController confirmPassCtrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          children: [
            SizedBox(height: 100.h),

            Image.asset('assets/images/reset.png', height: 192.h),

            CustomText(
              text: "Set Your New Password",
              fontSize: 22.h,
              fontWeight: FontWeight.w700,
              top: 12.h,
              bottom: 12.h,
            ),

            SizedBox(height: 20.h),

            CustomAuthTextField(
              controller: passwordCtrl,
              hintText: '************',
              obscureText: true,
              suffixIcon: Icon(Icons.visibility_off),
            ),

            SizedBox(height: 16.h),

            CustomAuthTextField(
              controller: confirmPassCtrl,
              hintText: '************',
              obscureText: true,
              suffixIcon: Icon(Icons.visibility_off),
            ),

            SizedBox(height: 200.h),
            CustomButton(
              title: "Update Password",
              onpress: () {
                context.push('/log-in');
              },
            ),
          ],
        ),
      ),
    );
  }
}
