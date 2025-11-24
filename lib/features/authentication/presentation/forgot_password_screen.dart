import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:koji/controller/auth_controller.dart';
import 'package:koji/helpers/toast_message_helper.dart';
import 'package:koji/shared_widgets/custom_auth_text_field.dart';
import 'package:koji/shared_widgets/custom_button.dart';
import 'package:koji/shared_widgets/custom_text.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final AuthController authController = Get.put(AuthController());
  TextEditingController emailCtrl = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = GoRouterState.of(context);
    final extras = state.extra as Map<String, dynamic>?;
    if (extras != null && emailCtrl.text.isEmpty) {
      emailCtrl.text = extras["email"] ?? '';
    }
  }

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

            Image.asset('assets/images/forgot.png', height: 192.h),

            CustomText(
              text: "Forgot Password",
              fontSize: 22.h,
              fontWeight: FontWeight.w700,
              top: 12.h,
              bottom: 12.h,
            ),

            CustomText(
              maxline: 2,
              text:
                  "Enter your registered email to get password reset instructions",
              fontWeight: FontWeight.w400,
              textAlign: TextAlign.center,
              bottom: 40.h,
            ),

            SizedBox(height: 20.h),

            CustomAuthTextField(
              controller: emailCtrl,
              hintText: "Enter your email",
              keyboardType: TextInputType.emailAddress,
            ),

            SizedBox(height: 200.h),
            Obx(
              () => CustomButton(
                title: "Continue",
                loading: authController.forgotLoading.value,
                onpress: () async {
                  if (emailCtrl.text.isEmpty) {
                    ToastMessageHelper.showToastMessage(
                      "Please enter your email",
                      title: 'Error',
                    );
                    return;
                  }

                  await authController.handleForgot(
                    emailCtrl.text,
                    "forgot",
                    context: context,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
