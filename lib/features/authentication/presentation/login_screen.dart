import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:koji/controller/auth_controller.dart';
import 'package:koji/routes/route_helper.dart';
import 'package:koji/shared_widgets/custom_auth_text_field.dart';
import 'package:koji/shared_widgets/custom_button.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  AuthController authController = Get.find<AuthController>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFCFCFC),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 50.h),

                  // Logo
                  Center(
                    child: Image.asset(
                      'assets/images/splash.png',
                      height: 100.h,
                    ),
                  ),

                  SizedBox(height: 30.h),

                  // Welcome Text
                  Text(
                    "Welcome Back!",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // Email Field
                  CustomAuthTextField(
                    controller: emailCtrl,
                    hintText: 'Enter Email',
                    keyboardType: TextInputType.emailAddress,

                  ),

                  SizedBox(height: 16.h),

                  // Password Field
                  CustomAuthTextField(
                    controller: passwordCtrl,
                    hintText: "Enter Password",
                    obscureText: true,
                    isPasswordField: true,
                  ),

                  SizedBox(height: 10.h),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Add forgot password logic
                        RouteHelper.goToForgotPassword(
                          context,
                          email: emailCtrl.text,
                        );
                      },
                      child: Text(
                        'Forgot Password',
                        style: TextStyle(fontSize: 14.sp, color: Colors.blue),
                      ),
                    ),
                  ),

                  SizedBox(height: 60.h),

                  // Log In Button
                  Obx(
                    () => CustomButton(
                      loading: authController.logInLoading.value,
                      title: "Login",
                      onpress: () {
                        print("tapped login");

                        if (formKey.currentState!.validate()) {
                          authController.handleLogIn(
                            emailCtrl.text,
                            passwordCtrl.text,
                            context: context,
                          );

                          // if (emailCtrl.text == "admin@gmail.com") {
                          //   context.push("/adminBottomNavBar");
                          // } else {
                          //   context.push('/bottomNavBar');
                          // }
                        }
                      },
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Sign Up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don’t Have An Account? ",
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.push('/sign-up');
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
