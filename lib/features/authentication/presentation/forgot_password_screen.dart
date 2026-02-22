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
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        // title: CustomText(
        //   text: "ForgetScreen",
        //   fontWeight: FontWeight.bold,
        //   fontSize: 20.sp,
        // ),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xffFCFCFC),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Form(
          key: formKey,
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
                inputType: AuthInputType.email,
              ),

              SizedBox(height: 200.h),
              Obx(
                () => CustomButton(
                  title: "Continue",
                  loading: authController.forgotLoading.value,
                  onpress: () async {
                    if (formKey.currentState!.validate()) {
                      await authController.handleForgot(
                        emailCtrl.text.trim(),
                        "forgot",
                        context: context,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
