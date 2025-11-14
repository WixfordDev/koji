import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koji/controller/auth_controller.dart';
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
  final AuthController authController = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xffFCFCFC),
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
            Obx(
              () => CustomButton(
                loading: authController.setPasswordLoading.value,
                title: "Update Password",
                onpress: () {
                  final pass = passwordCtrl.text.trim();
                  final confirm = confirmPassCtrl.text.trim();
                  if (pass.isEmpty || confirm.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter and confirm password'),
                      ),
                    );
                    return;
                  }
                  if (pass != confirm) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Passwords do not match')),
                    );
                    return;
                  }

                  authController.setPassword(pass, confirm, context: context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
