import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koji/controller/auth_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:koji/helpers/toast_message_helper.dart';
import 'package:koji/shared_widgets/custom_auth_text_field.dart';
import 'package:koji/shared_widgets/custom_button.dart';
import 'package:koji/shared_widgets/custom_text.dart';

import '../../../../constants/app_color.dart';
import 'custom_pin_text_field.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final AuthController authController = Get.put(AuthController());
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController otpCtrl = TextEditingController();
  String? email;
  String? screenType;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = GoRouterState.of(context);
    final extras = state.extra as Map<String, dynamic>?;
    if (extras != null) {
      if (email == null) {
        email = extras['email'];
        screenType = extras['screenType'];
        emailCtrl.text = email ?? '';
      }
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

            Image.asset('assets/images/otp.png', height: 192.h),

            CustomText(
              text: "OTP Verification",
              fontSize: 22.h,
              fontWeight: FontWeight.w700,
              top: 12.h,
              bottom: 12.h,
            ),
            CustomText(
              maxline: 2,
              text: "Onetime OTP has been sent to your registered email",
              fontWeight: FontWeight.w400,
              textAlign: TextAlign.center,
              bottom: 40.h,
            ),
            CustomPinCodeTextField(textEditingController: otpCtrl),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CustomText(text: "Didn't receive a code? "),
                const Spacer(),
                Obx(
                  () => Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: isCountingDown.value
                          ? null
                          : () async {
                              if (email == null || email!.isEmpty) {
                                ToastMessageHelper.showToastMessage(
                                  "Email not found",
                                  title: 'Error',
                                );
                                return;
                              }
                              await authController.handleResendOtp(
                                email: email!,
                                context: context,
                              );
                              startCountdown();
                            },
                      child: CustomText(
                        text: isCountingDown.value
                            ? 'Resend in ${countdown.value}s'
                            : 'Resend code',
                        color: isCountingDown.value
                            ? Colors.red
                            : AppColor.primaryColor,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 180.h),
            Obx(
              () => CustomButton(
                title: "Verify",
                loading: authController.verfyLoading.value,
                onpress: () {
                  if (otpCtrl.text.isEmpty) {
                    ToastMessageHelper.showToastMessage(
                      "Please enter verification code",
                      title: 'Error',
                    );
                    return;
                  }
                  authController.verfyEmail(
                    email: email ?? '',
                    code: otpCtrl.text,
                    screenType: screenType ?? '',
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

  final RxInt countdown = 60.obs;
  final RxBool isCountingDown = false.obs;

  void startCountdown() {
    isCountingDown.value = true;
    countdown.value = 60;

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        timer.cancel();
        isCountingDown.value = false;
      }
    });
  }
}
